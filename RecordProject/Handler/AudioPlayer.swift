//
//  AudioPlayer.swift
//  RecordProject
//
//  Created by Yosei Yamagishi on 2020/09/05.
//  Copyright © 2020 Yosei Yamagishi. All rights reserved.
//

import AVFoundation
class AudioPlayer {
    var audioPlayer: AVAudioPlayer?
    var isPlaying: Bool { audioPlayer?.isPlaying ?? false }
    func setupPlayer(with url: URL) { // プレイヤーを作成
        audioPlayer = try! AVAudioPlayer(contentsOf: url)
        audioPlayer?.prepareToPlay()
    }
    func play(currentTime: Double) { // 再生位置を決めて再生
        audioPlayer?.currentTime = currentTime
        audioPlayer?.play()
    }
    func pause() { // 再生を一時停止
        audioPlayer?.pause()
    }
}

