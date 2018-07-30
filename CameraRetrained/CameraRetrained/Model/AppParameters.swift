//
//  AppParameters.swift
//  CameraRetrained
//
//  Created by Marcin on 30.07.2018.
//  Copyright © 2018 Marcin. All rights reserved.
//

import Foundation
import CoreGraphics

struct AppParameters {
    let predictionTimeInterval: TimeInterval
    let imageSizeForPrediction: CGSize
    let minPredictionValue: Float
    let maxPredictionsCount: Int
    let model: old_polish_cars_resnet50_95acc
    
    static func defaultParameters() -> AppParameters {
        return AppParameters(
            predictionTimeInterval: 0.2,
            imageSizeForPrediction: CGSize(width: 224.0, height: 224.0),
            minPredictionValue: 10.0,
            maxPredictionsCount: 3,
            model: old_polish_cars_resnet50_95acc()
        )
    }
}
