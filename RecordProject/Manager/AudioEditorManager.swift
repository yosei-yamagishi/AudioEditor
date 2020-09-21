//
//  AudioEditorManager.swift
//  RecordProject
//
//  Created by Yosei Yamagishi on 2020/08/31.
//  Copyright © 2020 Yosei Yamagishi. All rights reserved.
//

import AVFoundation
class AudioEditorManager {
    let editFileName = "editedAudio.m4a" // 編集後のファイル名
    var editFileUrl: URL? // 編集後のファイルURLを保持するため
    let originalUrl: URL // 収録したオリジナルファイル
    var amplitudes: [Float] // 取得した波形
    
    var audioPlayer = AudioPlayer()
    var fileManager = RecorderFileHandler()
    var editHandler = AudioEditorHandler()
    
    // 取得した振幅のタイムインターバル
    let timeInterval: Double = 0.1
    // 1秒の横幅
    let oneSecoundWidth: CGFloat = 20
    // 収録時間
    var totalTime: Double {
        Double(amplitudes.count) * timeInterval
    }
    // 収録時間のtext
    var totalTimeText: String {
        let time = timeText(time: totalTime)
        return "/ " + time.minute + time.second + time.millisecond
    }
    
    var isPlaying: Bool { audioPlayer.isPlaying }
    
    init(amplitudes: [Float], originalUrl: URL) {
        self.originalUrl = originalUrl
        self.amplitudes = amplitudes
        audioPlayer.setupPlayer(with: originalUrl)
    }
    
    // 編集バーで指定した時間を編集する
    func edit(
        leftTime: Double, // 左バーの編集時間
        rightime: Double, // 右バーの編集時間
        completion: @escaping (Result<Range<Int>, Error>) -> Void
    ) {
        
        // 0.1秒ごとに波形を取得してるのでまるめる
        // ex) leftTime: 15.175 → 15.2
        //     rightTime: 18.20 → 18.2
        let roundedLeft = round(leftTime * 10) / 10
        let roundedRight = round(rightime * 10) / 10
        
        // 時間範囲(左)
        // ex) 0 から 152 / 10
        let leftTimeRange = CMTimeRangeFromTimeToTime(
            start: CMTime(value: Int64(0*10), timescale: 10),
            end: CMTime(value: Int64(roundedLeft*10), timescale: 10)
        )
        // 時間範囲(右)
        // ex) 182 / 10 から 収録時間
        let rightTimeRange = CMTimeRangeFromTimeToTime(
            start: CMTime(value: Int64(roundedRight*10), timescale: 10),
            end: CMTime(value: Int64(totalTime*10), timescale: 10)
        )
        
        // エクスポートするファイルを用意する
        fileManager.removeFile(fileName: editFileName)
        let exportFileUrl = fileManager.fileUrl(fileName: editFileName)!
        
        // 指定された時間範囲を編集する
        editHandler.edit(
            originUrl: originalUrl, exportFileUrl: exportFileUrl,
            timeRanges: [leftTimeRange, rightTimeRange]
        ) { result in
            switch result {
            case let .success(url):
                self.editFileUrl = url
                // 編集後のファイルをプレイヤーに再設定
                self.audioPlayer.setupPlayer(with: url)
                // 編集範囲
                let removeRange = Int(roundedLeft * 10)..<Int(roundedRight * 10)
                // 編集範囲を取り除く、UIにも取り除いた編集範囲を反映させる
                self.amplitudes.removeSubrange(removeRange)
                completion(.success(removeRange))
            case let .failure(error):
                completion(.failure(error))
            }
        }
        
    }
    
    func play(currentTime: Double) {
        audioPlayer.play(currentTime: currentTime)
    }
    
    func pause() {
        audioPlayer.pause()
    }
    
    // メーターの時間
    func meterTime(index: Int) -> String {
        let time = Float(index * 5)
        let minute = Int(time / 60)
        let second = Int(time.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", minute, second)
    }
    
    // 現在時刻
    func timeText(time: Double) -> (minute: String, second: String, millisecond: String) {
        let minute = Int(time / 60)
        let second = Int(time.truncatingRemainder(dividingBy: 60))
        let millisecond = Int((time - Double(minute * 60) - Double(second)) * 100.0)
        return (
            minute: String(format: "%02d:", minute),
            second: String(format: "%02d.", second),
            millisecond: String(format: "%02d", millisecond)
        )
    }
}
