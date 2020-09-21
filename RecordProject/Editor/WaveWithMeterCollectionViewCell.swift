//
//  WaveWithMeterCollectionViewCell.swift
//  RecordProject
//
//  Created by Yosei Yamagishi on 2020/08/29.
//  Copyright © 2020 Yosei Yamagishi. All rights reserved.
//

import UIKit

class WaveWithMeterCollectionViewCell: UICollectionViewCell {
    @IBOutlet var waveHeight: NSLayoutConstraint!
    @IBOutlet var waveView: UIView!
    @IBOutlet weak var meterHeight: NSLayoutConstraint!
    @IBOutlet weak var meterView: UIView!
    
    func draw(height: CGFloat, index: Int) {
        waveHeight.constant = height
        waveView.isHidden = index % 2 != 0
        // メーター表示
        meterView.isHidden = index % 2 != 0
        // 5秒おきに高さを変更
        meterHeight.constant = index % 50 == 0 ? 10 : 5
        // 1秒おきに色を変更
        meterView.backgroundColor = index % 10 == 0 ? .lightGray : .black
    }
}
