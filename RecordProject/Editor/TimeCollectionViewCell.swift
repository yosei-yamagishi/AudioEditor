//
//  TimeCollectionViewCell.swift
//  RecordProject
//
//  Created by Yosei Yamagishi on 2020/08/30.
//  Copyright © 2020 Yosei Yamagishi. All rights reserved.
//

import UIKit

class TimeCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var timeLabel: UILabel!
    
    func draw(time: String) {
        timeLabel.text = time
    }
}
