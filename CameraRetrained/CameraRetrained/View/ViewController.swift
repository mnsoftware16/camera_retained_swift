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
    @IBOutlet weak var predictionsTableContainerView: UIView!
    
    private var lastFrameDate: Date?
    private let predictionTimeInterval: TimeInterval = 0.2
    private var cameraDeviceCoordinator: CameraDeviceCoordinator?
    private let model = old_polish_cars_resnet50_95acc()
    
    private var predictionsTableViewController: PredictionsViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        preparePredictionsTableViewController()
        lastFrameDate = Date()
        do {
            try prepareCameraDeviceCoordinator()
        } catch {
            presentAlert(withTitle: "Error", message: error.localizedDescription)
        }
    }
    
    private func prepareCameraDeviceCoordinator() throws {
        let cameraDeviceCoordinator = CameraDeviceCoordinator()
        cameraDeviceCoordinator.outputSampleBufferDelegate = self
        try cameraDeviceCoordinator.setup(for: cameraPreviewView)
        self.cameraDeviceCoordinator = cameraDeviceCoordinator
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
        if currentDate.timeIntervalSince(lastFrameDate!) > predictionTimeInterval {
            lastFrameDate = currentDate
            
            let imageCreator = ImageCreator(
                imageSampleBuffer: sampleBuffer,
                orientation: connection.videoOrientation,
                requiredSize: CGSize(width: 224, height: 224)
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
                let output = try self.model.prediction(_0: image.getPixelBuffer()!)
                
                let provider = CarTypePredictionsProvider()
                if let carTypePredictions = try? provider.providePredictionsFromModelPredictionOutput(output: output) {
                    let predictionsProcessor = CarTypePredictionsProcessor()
                    let processedPredictions = predictionsProcessor.getTopPredictions(
                        from: carTypePredictions,
                        minPredictionValue: 10.0,
                        maxCount: 3
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
