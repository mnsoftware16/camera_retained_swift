//
//  CameraDeviceCoordinator.swift
//  CameraRetrained
//
//  Created by Marcin on 20.07.2018.
//  Copyright © 2018 Marcin. All rights reserved.
//

import Foundation
import AVFoundation

class CameraDeviceCoordinator: NSObject {
    weak var outputSampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate?
    
    var isCameraRunning: Bool {
        return captureSession.isRunning
    }
    
    private weak var cameraPreviewView: PreviewView?
    private let captureSession = AVCaptureSession()
    private var captureDevice: AVCaptureDevice?
    
    func setup(for previewView: PreviewView) throws {
        cameraPreviewView = previewView
        
        let deviceDiscovery = AVCaptureDevice.DiscoverySession(
            deviceTypes: [AVCaptureDevice.DeviceType.builtInWideAngleCamera],
            mediaType: AVMediaType.video,
            position: AVCaptureDevice.Position.back
        )
        let devices = deviceDiscovery.devices
        
        guard let captureDevice = devices.first else {
            throw CameraDeviceCoordinatorError.noCameraAvailable
        }
        
        self.captureDevice = captureDevice
        cameraPreviewView?.session = captureSession
        
        let captureDeviceInput = try AVCaptureDeviceInput(device: captureDevice)
        captureSession.addInput(captureDeviceInput)
        captureSession.sessionPreset = .photo
        
        let videoOutput = AVCaptureVideoDataOutput()
        videoOutput.alwaysDiscardsLateVideoFrames = true
        videoOutput.setSampleBufferDelegate(outputSampleBufferDelegate, queue: DispatchQueue(label: "sample buffer"))
        guard self.captureSession.canAddOutput(videoOutput) else { return }
        captureSession.addOutput(videoOutput)
    }
    
    func startCameraRunning() {
        captureSession.startRunning()
    }
    
    func stopCameraRunning() {
        captureSession.stopRunning()
    }
}
