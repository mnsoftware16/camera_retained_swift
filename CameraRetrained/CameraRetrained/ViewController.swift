//
//  ViewController.swift
//  CameraRetrained
//
//  Created by Marcin on 26.06.2018.
//  Copyright © 2018 Marcin. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
    @IBOutlet private weak var cameraPreviewView: PreviewView!
    
    private let captureSession = AVCaptureSession()
    private let cameraPreview = UIView(frame: .zero)
    private var captureDevice: AVCaptureDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            try setupCaptureSession()
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
        self.captureSession.addOutput(videoOutput)
    }
    
    func presentAlert(withTitle title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated:true)
    }
}

extension ViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        
    }
}
