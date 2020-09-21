//
//  RecorderHandler.swift
//  RecordProject
//
//  Created by Yosei Yamagishi on 2020/09/18.
//  Copyright © 2020 Yosei Yamagishi. All rights reserved.
//

import AVFoundation

class RecorderHandler {
    private var recorder: AVAudioRecorder?
    // 収録中かどうかのフラグ
    var isRecording: Bool { recorder?.isRecording ?? false }
    // 現在時刻
    var currentTime: Float { Float(self.recorder?.currentTime ?? 0) }
    // 収録開始
    func record() { recorder?.record() }
    // 収録一時停止
    func pause() { recorder?.pause() }
    // 収録停止
    func stop() { recorder?.stop() }
    
    
    func setup(url: URL) {
        self.recorder = try! AVAudioRecorder(url: url, settings: settings)
        recorder?.isMeteringEnabled = true // デシベルを抽出を有効にする
        recorder?.prepareToRecord() // レコーダーに収録準備させる
    }
    
    func amplitude() -> Float {
        self.recorder?.updateMeters()
        // 指定されたチャネルの平均パワーをデシベル単位で返却
        // averagePowerは 0dB:最大電力 -160dB:最小電力(ほぼ無音)
        let decibel = recorder?.averagePower(forChannel: 0) ?? 0
        // デシベルから振幅を取得する
        let amp = pow(10, decibel / 20)
        return max(0, min(amp, 1)) // 0...1の間の値
    }
    
    private let settings: [String: Any] = [
        // MPEG-4 AACコーデックを指定するキー
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        // サンプルレート変換品質
        AVEncoderAudioQualityKey: AVAudioQuality.medium.rawValue,
        // モノラル
        AVNumberOfChannelsKey: 1,
        // サンプルレート
        AVSampleRateKey: 44100
    ]
}
