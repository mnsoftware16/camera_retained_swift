//
//  CarTypePredictionsCreatorError.swift
//  CameraRetrained
//
//  Created by Marcin on 20.07.2018.
//  Copyright © 2018 Marcin. All rights reserved.
//

import Foundation

enum CarTypePredictionsCreatorError: Error {
    case missingCarTypesFile
    case inconsistenSizeOfThePredictionsAndCarTypesArray
    
    var localizedDescription: String {
        switch self {
        case .missingCarTypesFile:
            return "Could not find a car types file"
        case .inconsistenSizeOfThePredictionsAndCarTypesArray:
            return "Size of the predictions and car types array has to be the same."
        }
    }
}
