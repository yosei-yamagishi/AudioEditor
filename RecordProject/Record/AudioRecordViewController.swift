//
//  AudioRecordViewController.swift
//  RecordProject
//
//  Created by Yosei Yamagishi on 2020/08/29.
//  Copyright © 2020 Yosei Yamagishi. All rights reserved.
//

import UIKit

class AudioRecordViewController: UIViewController {
    @IBOutlet weak var minuteTimeLabel: UILabel!
    @IBOutlet weak var secondTimeLabel: UILabel!
    @IBOutlet weak var millisecondTimeLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView! {
        didSet {
            collectionView.dataSource = self
            collectionView.delegate = self
            collectionView.registerNib(
                cellType: WaveCollectionViewCell.self
            )
        }
    }
    
    @IBOutlet weak var recordButton: UIButton! {
        didSet {
            recordButton.allMaskCorner()
            recordButton.addTarget(self, action: #selector(switchRecord), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var stopButton: UIButton! {
        didSet {
            stopButton.allMaskCorner()
            stopButton.addTarget(self, action: #selector(stop), for: .touchUpInside)
        }
    }
    
    var recorderManager = RecorderManager()
    var timer: Timer?
    var collectionViewHeight: CGFloat {
        collectionView.frame.height
    }
    var screenHalfWidth: CGFloat {
        UIScreen.main.bounds.width / 2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // ナビゲーションの背景色を変更
        navigationController?.navigationBar.barTintColor = UIColor.darkGray
        // ナビゲーションバーのアイテムの色（戻るとか読み込みゲージとか）
        navigationController?.navigationBar.tintColor = UIColor.white
        // レコーダーのセットアップ
        recorderManager.setup()
    }
    
    // 現在時刻を設定
    private func setupCurrentTime() {
        let currentTime = self.recorderManager.currentTime
        self.minuteTimeLabel.text = currentTime.minute
        self.secondTimeLabel.text = currentTime.second
        self.millisecondTimeLabel.text = currentTime.millisecond
    }
    
    @objc func switchRecord() {
        let isRecording = recorderManager.isRecording
        // 収録ボタンの制御
        recordButton.setTitle(isRecording ? "収録開始" : "一時停止", for: .normal)
        // 収録制御
        isRecording ? recorderManager.pause() : recorderManager.record()
        // タイマー制御
        setupTimer(isRecording: isRecording)
    }
    
    func setupTimer(isRecording: Bool) {
        if isRecording {
            timer?.invalidate() // タイマー停止
            timer = nil
        } else {
            timer = Timer.scheduledTimer(
                withTimeInterval: 0.1, // タイマーインターバル
                repeats: true
            ) { timer in
                self.setupCurrentTime() // 現在時刻を更新
                self.recorderManager.updateAmpliude() // デシベルの取得
                self.insertCollectionView() // 取得した波形の表示
            }
        }
    }
    
    private func insertCollectionView() {
        // 取得した波形のIndexPath
        let endIndex = self.recorderManager.amplitudes.count - 1
        let lastIndexPath = IndexPath(row: endIndex, section: 0)
        UIView.performWithoutAnimation { // アニメーションOFF
            // 取得した波形をCollectionViewにinsert
            self.collectionView.performBatchUpdates(
                { self.collectionView.insertItems(at: [lastIndexPath]) },
                completion: { _ in
                    // insert完了後にスクロールする
                    self.collectionView.scrollToItem(
                        at: lastIndexPath, at: .left, animated: false
                    )
                }
            )
        }
    }
    
  
    @objc private func stop() {
        setupTimer(isRecording: true)
        
        recorderManager.stop() // 収録停止
        let audioEditorViewController = AudioEditorViewController(
            amplitudes: recorderManager.amplitudes,
            originalUrl: recorderManager.originalFileUrl!
        )
        navigationController?.pushViewController(
            audioEditorViewController,
            animated: true
        )
    }
    
    // アニメーションさせないでinsertする場合
    func memo() {
        let amplitudeCount = self.recorderManager.amplitudes.count - 1
        let lastIndexPath = IndexPath(row: amplitudeCount, section: 0)
        UIView.performWithoutAnimation {
            self.collectionView.performBatchUpdates(
                { self.collectionView.insertItems(at: [lastIndexPath]) },
                completion: { _ in
                    self.collectionView.scrollToItem(
                        at: lastIndexPath,
                        at: .left,
                        animated: false
                    )
                }
            )
        }
    }
}

extension AudioRecordViewController: UICollectionViewDataSource {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // 取得した波形の数
        recorderManager.amplitudes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(for: indexPath) as WaveCollectionViewCell
        let amplitudes = recorderManager.amplitudes[indexPath.row]
        // 振幅(0..1) * collectionViewの高さ = 波形の高さ
        let waveHeight = CGFloat(amplitudes) * collectionViewHeight
        cell.draw(height: waveHeight, index: indexPath.row)
        return cell
    }
    
}

extension AudioRecordViewController: UICollectionViewDelegateFlowLayout {
    
    // セルのサイズを設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // タイムインターバルの横幅(0.1秒の横幅)
        let meterWidth: CGFloat = 2
        return CGSize(width: meterWidth, height: collectionViewHeight)
    }
    
    // 垂直方向におけるセル間のマージン
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    // 水平方向におけるセル間のマージン
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    // collectionViewのEdgeInsetsは0にする
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }
    
    // ヘッダーのサイズ設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: screenHalfWidth, height: collectionViewHeight)
    }
    // フッターのサイズ設定
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        CGSize(width: screenHalfWidth, height: collectionViewHeight)
    }
    
    
}
