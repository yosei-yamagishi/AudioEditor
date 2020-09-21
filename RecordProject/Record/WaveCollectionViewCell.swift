//
//  WaveCollectionViewCell.swift
//  RecordProject
//
//  Created by Yosei Yamagishi on 2020/09/05.
//  Copyright © 2020 Yosei Yamagishi. All rights reserved.
//

import UIKit

class WaveCollectionViewCell: UICollectionViewCell {
    @IBOutlet var waveHeight: NSLayoutConstraint!
    @IBOutlet var waveView: UIView!

    func draw(height: CGFloat, index: Int) {
        // 振幅の高さ
        waveHeight.constant = height
        // セル間のスペースを取るために偶数の波形は表示する
        waveView.isHidden = index % 2 != 0
    }
}

