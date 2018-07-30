//
//  ViewController.swift
//  CameraRetrained
//
//  Created by Marcin on 26.06.2018.
//  Copyright © 2018 Marcin. All rights reserved.
//

import UIKit
import CoreML
import Vision
import ImageIO
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet private weak var cameraPreviewView: PreviewView!
    @IBOutlet private weak var predictionsTableContainerView: UIView!
    @IBOutlet private weak var predictionAreaView: UIView!
    
    private var lastFrameDate: Date?
    private let appParameters = AppParameters.defaultParameters()
    private var cameraDeviceCoordinator: CameraDeviceCoordinator?
    
    private var predictionsTableViewController: PredictionsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        registerApplicationStateObservers()
        preparePredictionsTableViewController()
        preparePredictionAreaView()
        lastFrameDate = Date()
        prepareCameraDeviceCoordinator()
    }
    
    private func prepareCameraDeviceCoordinator() {
        do {
            let cameraDeviceCoordinator = CameraDeviceCoordinator()
            cameraDeviceCoordinator.outputSampleBufferDelegate = self
            try cameraDeviceCoordinator.setup(for: cameraPreviewView)
            cameraDeviceCoordinator.startRunning()
            self.cameraDeviceCoordinator = cameraDeviceCoordinator
        } catch {
            presentAlert(withTitle: "Error", message: error.localizedDescription)
        }
    }
    
    private func preparePredictionAreaView() {
        let imageSize = appParameters.imageSizeForPrediction
        let multiplier = imageSize.width / imageSize.height
        let aspectConstraint = NSLayoutConstraint(
            item: predictionAreaView,
            attribute: .width,
            relatedBy: .equal,
            toItem: predictionAreaView,
            attribute: .height,
            multiplier: multiplier,
            constant: 0
        )
        predictionAreaView.addConstraint(aspectConstraint)
        NSLayoutConstraint.activate([aspectConstraint])
        predictionAreaView.layoutIfNeeded()
    }
    
    private func preparePredictionsTableViewController() {
        let predictionsTableViewController = PredictionsViewController.create()
        
        let view: UIView = predictionsTableViewController.view
        view.frame = predictionsTableContainerView.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        predictionsTableContainerView.addSubview(view)
        self.predictionsTableViewController = predictionsTableViewController
    }
    
    private func presentAlert(withTitle title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated:true)
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        connection.videoOrientation = .portrait

        let currentDate = Date()
        let predictionTimeInterval = appParameters.predictionTimeInterval
        if currentDate.timeIntervalSince(lastFrameDate!) > predictionTimeInterval {
            lastFrameDate = currentDate
            
            let imageCreator = ImageCreator(
                imageSampleBuffer: sampleBuffer,
                orientation: connection.videoOrientation,
                requiredSize: appParameters.imageSizeForPrediction
            )
            if let image = imageCreator.createImage() {
                updateClassifications(for: image)
            }
        }
    }
}

// MARK: - Image Classification
extension ViewController {
    func updateClassifications(for image: CGImage) {
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                let model = self.appParameters.model
                let output = try model.prediction(_0: image.getPixelBuffer()!)
                
                let provider = CarTypePredictionsProvider()
                if let carTypePredictions = try? provider.providePredictionsFromModelPredictionOutput(output: output) {
                    let predictionsProcessor = CarTypePredictionsProcessor()
                    let processedPredictions = predictionsProcessor.getTopPredictions(
                        from: carTypePredictions,
                        minPredictionValue: self.appParameters.minPredictionValue,
                        maxCount: self.appParameters.maxPredictionsCount
                    )
                    
                    DispatchQueue.main.async {
                        self.predictionsTableViewController?.predictions = processedPredictions
                    }
                }
            } catch {
                self.presentAlert(withTitle: "Error", message: error.localizedDescription)
            }
        }
    }
}

// MARK: - Application state observation
extension ViewController {
    private func registerApplicationStateObservers() {
        NotificationCenter.default.addObserver(
            self, selector:
            #selector(applicationDidEnterForeground),
            name: .UIApplicationDidEnterBackground,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector:
            #selector(applicationDidEnterBackground),
            name: .UIApplicationWillEnterForeground,
            object: nil
        )
    }
    
    @objc private func applicationDidEnterForeground() {
        cameraDeviceCoordinator?.stopRunning()
    }
    
    @objc private func applicationDidEnterBackground() {
        cameraDeviceCoordinator?.startRunning()
    }
}
