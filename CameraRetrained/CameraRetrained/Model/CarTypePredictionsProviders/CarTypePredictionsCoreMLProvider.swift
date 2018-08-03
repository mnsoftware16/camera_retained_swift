//
//  CarTypePredictionsCoreMLProvider.swift
//  CameraRetrained
//
//  Created by Marcin on 01.08.2018.
//  Copyright © 2018 Marcin. All rights reserved.
//

import Foundation
import UIKit.UIImage
import CoreML
import Vision

class CarTypePredictionsCoreMLProvider: CarTypePredictionsProvider {
    typealias Completion = (([CarTypePrediction]?) -> Void)
    
    let model = old_polish_cars_93acc()
    var completion: Completion?
    
    private lazy var classificationRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: self.model.model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processClassifications(for: request, error: error)
            })
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }
    }()
    
    func providePredictionsFromImage(image: CGImage, completion: Completion?) throws {
        self.completion = completion
        
        let handler = VNImageRequestHandler.init(cgImage: image)
        try handler.perform([self.classificationRequest])
    }
    
    private func processClassifications(for request: VNRequest, error: Error?) {
        var resultPredictions: [CarTypePrediction]?
        guard let results = request.results, error == nil else {
            completion?(nil)
            return
        }
        let classifications = results as! [VNClassificationObservation]
        
        if !classifications.isEmpty {
            resultPredictions = classifications.map { classification in
                return CarTypePrediction(carType: classification.identifier, predictionValue: classification.confidence)
            }
        }
        
        completion?(resultPredictions)
    }
}
