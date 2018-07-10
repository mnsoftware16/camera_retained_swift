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
    @IBOutlet private weak var classificationLabel: UILabel!
    
    private let captureSession = AVCaptureSession()
    private let cameraPreview = UIView(frame: .zero)
    private var captureDevice: AVCaptureDevice?
    private var lastFrameDate: Date?
    private let predictionTimeInterval: TimeInterval = 0.2
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        classificationLabel.text = "Initializing..."
        do {
            try setupCaptureSession()
            lastFrameDate = Date()
        } catch {
            let errorMessage = String(describing: error)
            presentAlert(withTitle: "Error", message: errorMessage)
        }
    }
    
    private func setupCaptureSession() throws {
        let deviceDiscovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: AVCaptureDevice.Position.back
        )
        let devices = deviceDiscovery.devices
        
        guard let captureDevice = devices.first else {
            let errorMessage = "No camera available"
            presentAlert(withTitle: "Error", message: errorMessage)
            return
        }
        
        self.captureDevice = captureDevice
        cameraPreviewView.session = captureSession
        
        let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
        captureSession.addInput(captureDeviceInput)
        captureSession.sessionPreset = .photo
        captureSession.startRunning()
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue(label: "sample buffer"))
        guard self.captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
    }
    
    func presentAlert(withTitle title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated:true)
    }
    
    // MARK: - Image Classification
    
    lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: old_polish_cars().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            request.imageCropAndScaleOption = .centerCrop
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    func updateClassifications(for image: UIImage) {
        let orientation = CGImagePropertyOrientation(image.imageOrientation)
        guard let ciImage = image.ciImage else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInitiated).async {
            let handler = VNImageRequestHandler(ciImage: ciImage, orientation: orientation)
            do {
                try handler.perform([self.classificationRequest])
            } catch {
                print("Failed to perform classification.\n\(error.localizedDescription)")
            }
        }
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results, error == nil else {
                self.classificationLabel.text = "Unable to classify image.\n"
                return
            }
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.classificationLabel.text = "Nothing recognized."
            } else {
                let topClassifications = classifications.prefix(3)
                let descriptions = topClassifications.map { classification in
                    return String(format: "  (%.2f) %@", classification.confidence, classification.identifier)
                }
                self.classificationLabel.text = descriptions.joined(separator: "\n")
            }
        }
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        let currentDate = Date()
        if currentDate.timeIntervalSince(lastFrameDate!) > predictionTimeInterval {
            lastFrameDate = currentDate
            
            if let imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) {
                let ciImage = CIImage(cvImageBuffer: imageBuffer)
                let uiImage = UIImage(ciImage: ciImage, scale: 1.0, orientation: .up)
                updateClassifications(for: uiImage)
            }
        }
    }
}
