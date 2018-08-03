//
//  CarTypePredictionsProcessor.swift
//  CameraRetrained
//
//  Created by Marcin on 20.07.2018.
//  Copyright © 2018 Marcin. All rights reserved.
//

import Foundation

struct CarTypePredictionsProcessor {
    func getTopPredictions(from predictions: [CarTypePrediction], count: Int) -> [CarTypePrediction] {
        let sortedPredictions = predictions.sorted { $0.predictionValue > $1.predictionValue }
        return [CarTypePrediction](sortedPredictions.prefix(count))
    }
    
    func getTopPredictions(from predictions: [CarTypePrediction], minPredictionValue: Float, maxCount: Int) -> [CarTypePrediction] {
        let resultPredictions = predictions
            .filter { $0.predictionValue > minPredictionValue }
            .sorted { $0.predictionValue > $1.predictionValue }
            .prefix(maxCount)
        
        return [CarTypePrediction](resultPredictions)
    }
}
