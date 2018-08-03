//
//  PredictionsTableViewController.swift
//  CameraRetrained
//
//  Created by Marcin on 30.07.2018.
//  Copyright © 2018 Marcin. All rights reserved.
//

import UIKit

class PredictionsViewController: UICollectionViewController {
    var predictions: [CarTypePrediction]? {
        get {
            return _predictions
        }
        set {
            _predictions = newValue
            collectionView?.reloadData()
        }
    }
    
    private var _predictions: [CarTypePrediction]?
    private let cellIdentifier = "Cell"
    
    static func create() -> PredictionsViewController {
        let nibName = String(describing: PredictionsViewController.self)
        return PredictionsViewController.init(nibName: nibName, bundle: .main)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        registerCell()
        prepareBackgroundView()
    }
    
    private func registerCell() {
        let nib = UINib(nibName: PredictionCell.nibName, bundle: .main)
        collectionView?.register(nib, forCellWithReuseIdentifier: cellIdentifier)
    }
    
    private func prepareBackgroundView() {
        collectionView?.backgroundColor = .clear
    }
}

extension PredictionsViewController {
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellIdentifier, for: indexPath) as! PredictionCell
        
        if let prediction = _predictions?[indexPath.row] {
            cell.percentValueLabel.text = String(format: "%0.2f%%", prediction.predictionValue * 100)
            cell.predictionNameLabel.text = " \(prediction.carType)"
        }
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return _predictions?.count ?? 0
    }
}

extension PredictionsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.frame.size.width
        let margin: CGFloat = 10.0
        let itemHeight: CGFloat = 30.0
        let itemWidth = collectionViewWidth - 2 * margin
        
        return CGSize(width: itemWidth, height: itemHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}
