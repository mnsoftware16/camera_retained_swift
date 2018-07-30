//
//  PredictionCell.swift
//  CameraRetrained
//
//  Created by Marcin on 30.07.2018.
//  Copyright © 2018 Marcin. All rights reserved.
//

import UIKit

class PredictionCell: UICollectionViewCell {

    static var nibName: String {
        return String(describing: self)
    }
    
    @IBOutlet weak var percentValueLabel: UILabel!
    @IBOutlet weak var predictionNameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        percentValueLabel.layer.cornerRadius = 10.0
        predictionNameLabel.layer.cornerRadius = 10.0
    }
}
