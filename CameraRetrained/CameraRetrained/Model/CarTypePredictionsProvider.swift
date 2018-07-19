//
//  CarTypePredictionsProvider.swift
//  CameraRetrained
//
//  Created by Marcin on 20.07.2018.
//  Copyright © 2018 Marcin. All rights reserved.
//

import Foundation

struct CarTypePredictionsProvider {
    let carTypesFileName: String
    
    init(carTypesFileName: String = "old_polish_cars_resnet50_95acc_classes"
        ) {
        self.carTypesFileName = carTypesFileName
    }
    
    func providePredictionsFromModelPredictionOutput(output: old_polish_cars_resnet50_95accOutput) throws -> [CarTypePrediction] {
        let predictions = getPredictionsFromOutput(output: output)
        return try create(from: predictions)
    }
    
    private func getPredictionsFromOutput(output: old_polish_cars_resnet50_95accOutput) -> [Float] {
        let multiArray: MultiArray = MultiArray<Float>(output._442)
        let numberOfClasses = 10
        var sum: Float = 0.0
        for index in 0..<numberOfClasses {
            let value = multiArray[0, 0, index, 0, 0]
            sum = sum + exp(value)
        }
        
        var predictionsArray = [Float]()
        for index in 0..<numberOfClasses {
            let value = multiArray[0, 0, index, 0, 0]
            let prediction = exp(value)/sum * 100
            predictionsArray.append(prediction)
        }
        
        return predictionsArray
    }
    
    private func create(from predictions: [Float]) throws -> [CarTypePrediction] {
        guard let filePath = Bundle.main.path(forResource: carTypesFileName, ofType: "txt") else {
            throw CarTypePredictionsCreatorError.missingCarTypesFile
        }
        let fileContent = try String(contentsOfFile: filePath)
        let carTypes = fileContent.split(separator: "\n")
        
        guard predictions.count == carTypes.count else {
            throw CarTypePredictionsCreatorError.inconsistenSizeOfThePredictionsAndCarTypesArray
        }
        
        let carTypePredictions: [CarTypePrediction] = carTypes.map {
            let index = carTypes.index(of: $0)!
            return CarTypePrediction(carType: String($0), predictionValue: predictions[index])
        }
        
        return carTypePredictions
    }
}
