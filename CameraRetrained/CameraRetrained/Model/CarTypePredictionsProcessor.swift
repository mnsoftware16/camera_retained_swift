//
//  CarTypePredictionsProcessor.swift
//  CameraRetrained
//
//  Created by Marcin on 20.07.2018.
//  Copyright © 2018 Marcin. All rights reserved.
//

import Foundation

struct CarTypePredictionsProcessor {
    func processPredictions(predictions: [CarTypePrediction]) -> String {
        var resultString: String
        if predictions.isEmpty {
            resultString = "Nothing recognized."
        } else {
            let topPredictions = self.getTopPredictions(from: predictions, count: 3)
            let descriptions = topPredictions.map { prediction in
                return String(format: "  (%.2f) %@", prediction.predictionValue, prediction.carType)
            }
            resultString = descriptions.joined(separator: "\n")
        }
        
        return resultString
    }
    
    private func getTopPredictions(from predictions: [CarTypePrediction], count: Int) -> [CarTypePrediction] {
        let sortedPredictions = predictions.sorted { $0.predictionValue > $1.predictionValue }
        return [CarTypePrediction](sortedPredictions.prefix(count))
    }
}
