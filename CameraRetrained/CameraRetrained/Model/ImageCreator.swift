//
//  ImageCreator.swift
//  CameraRetrained
//
//  Created by Marcin on 19.07.2018.
//  Copyright © 2018 Marcin. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit.UIImage

struct ImageCreator {
    let imageSampleBuffer: CMSampleBuffer
    let orientation: AVCaptureVideoOrientation
    let requiredSize: CGSize
    
    init(
        imageSampleBuffer: CMSampleBuffer,
        orientation: AVCaptureVideoOrientation,
        requiredSize: CGSize
        ) {
        self.imageSampleBuffer = imageSampleBuffer
        self.orientation = orientation
        self.requiredSize = requiredSize
    }
    
    func createImage() -> CGImage? {
        guard let imageBuffer = CMSampleBufferGetImageBuffer(imageSampleBuffer) else {
            return nil
        }
        let ciImage = CIImage(cvImageBuffer: imageBuffer)
        let cgImage = convertCIImageToCGImage(inputImage: ciImage)
        //let rotatedImage = cgImage?.rotated(imageRef: cgImage, orientation: orientation)
        let croppedImage = cgImage?.croppToCenterSquare()
        let resizedImage = croppedImage?.resized(to: requiredSize)
        
        return resizedImage
    }
    
    func convertCIImageToCGImage(inputImage: CIImage) -> CGImage? {
        let context = CIContext(options: nil)
        if let cgImage = context.createCGImage(inputImage, from: inputImage.extent) {
            return cgImage
        }
        return nil
    }
}




extension CGImage {
    func resized(to newSize: CGSize) -> CGImage? {
        let cgImage = self
        let width = newSize.width
        let height = newSize.height
        let bitsPerComponent = cgImage.bitsPerComponent
        let bytesPerRow = cgImage.bytesPerRow
        let colorSpace = cgImage.colorSpace
        let bitmapInfo = cgImage.bitmapInfo
        
        guard let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: bitsPerComponent, bytesPerRow: bytesPerRow, space: colorSpace!, bitmapInfo: bitmapInfo.rawValue) else {
            return nil
        }
        context.interpolationQuality = .high
        let rect = CGRect(origin: CGPoint.zero, size: CGSize(width: CGFloat(width), height: CGFloat(height)))
        context.draw(cgImage, in: rect)
            
        return context.makeImage()
    }
    
    func croppToCenterSquare() -> CGImage? {
        let position = CGPoint(x: 0, y: (height - width) / 2)
        let size = CGSize(width: width, height: width)
        
        return cropping(to: CGRect(origin: position, size: size))
    }
    
    func getPixelBuffer() -> CVPixelBuffer? {
        let frameSize = CGSize(width: width, height: height)
        var pixelBuffer:CVPixelBuffer? = nil
        let status = CVPixelBufferCreate(kCFAllocatorDefault, Int(frameSize.width), Int(frameSize.height), kCVPixelFormatType_32BGRA , nil, &pixelBuffer)
        
        if status != kCVReturnSuccess {
            return nil
        }
        
        CVPixelBufferLockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags.init(rawValue: 0))
        let data = CVPixelBufferGetBaseAddress(pixelBuffer!)
        let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGBitmapInfo.byteOrder32Little.rawValue | CGImageAlphaInfo.premultipliedFirst.rawValue)
        let context = CGContext(data: data, width: Int(frameSize.width), height: Int(frameSize.height), bitsPerComponent: 8, bytesPerRow: CVPixelBufferGetBytesPerRow(pixelBuffer!), space: rgbColorSpace, bitmapInfo: bitmapInfo.rawValue)
        context?.draw(self, in: CGRect(x: 0, y: 0, width: self.width, height: self.height))
        CVPixelBufferUnlockBaseAddress(pixelBuffer!, CVPixelBufferLockFlags(rawValue: 0))
        
        return pixelBuffer
    }
}
