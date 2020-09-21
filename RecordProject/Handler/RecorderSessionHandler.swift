//
//  RecorderSessionHandler.swift
//  RecordProject
//
//  Created by Yosei Yamagishi on 2020/09/18.
//  Copyright © 2020 Yosei Yamagishi. All rights reserved.
//

import AVFoundation

class RecorderSessionHandler {
    let session = AVAudioSession.sharedInstance()
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        session.requestRecordPermission { granted in
            completion(granted)
        }
    }
    
    func setActive() {
        try! session.setCategory(.playAndRecord)
        try! session.setActive(true, options: [])
    }
}
