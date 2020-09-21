//
//  AudioEditorHandler.swift
//  RecordProject
//
//  Created by Yosei Yamagishi on 2020/09/05.
//  Copyright © 2020 Yosei Yamagishi. All rights reserved.
//

import AVFoundation
class AudioEditorHandler {
    // オリジナルから指定した時間を編集して、編集後のURLを返却
    func edit(
        originUrl: URL, // 収録したファイル
        exportFileUrl: URL, // 編集後のエクスポートするファイル
        timeRanges: [CMTimeRange], // 削除部分以外の時間範囲
        fileType: AVFileType = .m4a, // ファイルタイプ
        completion: @escaping (Result<URL, Error>) -> Void
    ) {
        
        // 収録ファイルのTrackを取得
        let originAsset = AVURLAsset(url: originUrl)
        let originTrack = originAsset.tracks(withMediaType: .audio).first!
        
        // 新しいTrackを用意
        let composition = AVMutableComposition()
        let editTrack = composition.addMutableTrack(
            withMediaType: .audio,
            preferredTrackID: kCMPersistentTrackID_Invalid
        )!
        
        // 収録トラックから削除部分以外を新しいトラックに追加
        var nextStartTime: CMTime = .zero
        timeRanges.forEach { timeRange in
            try! editTrack.insertTimeRange(
                timeRange, of: originTrack, at: nextStartTime
            )
            nextStartTime = timeRange.end
        }
        
        // exportSessionを用意して編集後のファイルをエクスポート
        let exportSession = AVAssetExportSession(
            asset: composition,
            presetName: AVAssetExportPresetAppleM4A
        )!
        exportSession.outputURL = exportFileUrl
        exportSession.outputFileType = fileType
        exportSession.exportAsynchronously {
            switch exportSession.status {
            case .completed:
                completion(.success(exportFileUrl))
            default:
                completion(.failure(exportSession.error!))
            }
        }
    }
}
