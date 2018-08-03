//
//  CarTypePredictionsProvider.swift
//  CameraRetrained
//
//  Created by Marcin on 03.08.2018.
//  Copyright © 2018 Marcin. All rights reserved.
//

import Foundation
import CoreGraphics.CGImage

typealias Completion = (([CarTypePrediction]?) -> Void)

protocol CarTypePredictionsProvider {
    func providePredictionsFromImage(image: CGImage, completion: Completion?) throws
}
