//
//  CameraDeviceCoordinatorError.swift
//  CameraRetrained
//
//  Created by Marcin on 20.07.2018.
//  Copyright © 2018 Marcin. All rights reserved.
//

import Foundation

enum CameraDeviceCoordinatorError: Error {
    case noCameraAvailable
    
    var localizedDescription: String {
        switch self {
        case .noCameraAvailable:
            return "No camera available"
        }
    }
}
