//
//  AudioEditorViewController.swift
//  RecordProject
//
//  Created by Yosei Yamagishi on 2020/08/30.
//  Copyright © 2020 Yosei Yamagishi. All rights reserved.
//

import UIKit

class AudioEditorViewController: UIViewController {
    enum CollectionType: Int, CaseIterable {
        case decibel
        case time
    }
    var collectionTypes: [CollectionType] = CollectionType.allCases
    
    // MARK: 時間
    @IBOutlet weak var minuteTimeLabel: UILabel!
    @IBOutlet weak var secondTimeLabel: UILabel!
    @IBOutlet weak var millisecondTimeLabel: UILabel!
    @IBOutlet weak var totalTimeLabel: UILabel!
    
    // MARK: デシベル
    
    @IBOutlet weak var waveCollectionView: UICollectionView! {
        didSet {
            waveCollectionView.tag = CollectionType.decibel.rawValue
            waveCollectionView.dataSource = self
            waveCollectionView.delegate = self
            waveCollectionView.showsHorizontalScrollIndicator = false
            waveCollectionView.registerNib(cellType: WaveWithMeterCollectionViewCell.self)
        }
    }
    
    // MARK: 時間表記

    @IBOutlet weak var timeCollectionView: UICollectionView! {
        didSet {
            timeCollectionView.tag = CollectionType.time.rawValue
            timeCollectionView.dataSource = self
            timeCollectionView.delegate = self
            timeCollectionView.showsHorizontalScrollIndicator = false
            timeCollectionView.isScrollEnabled = false
            timeCollectionView.registerNib(cellType: TimeCollectionViewCell.self)
        }
    }
    
    // MARK: 最前面の範囲のバーを表示するスクロールビュー
    
    @IBOutlet weak var editBarScrollView: UIScrollView! {
        didSet {
            editBarScrollView.delegate = self
            editBarScrollView.showsHorizontalScrollIndicator = false
        }
    }
    @IBOutlet weak var frontScroollContentView: UIView!
    @IBOutlet weak var frontScrollContentViewWidth: NSLayoutConstraint! {
        didSet {
            // 波形のコンテンツの横幅 + ヘッダー + フッター
            frontScrollContentViewWidth.constant = waveContentViewWidth + spaceWidth * 2
        }
    }
    
    // 中心
    @IBOutlet weak var centerLineView: UIView!
    
    // 左のバー
    @IBOutlet weak var leftEditBarLeading: NSLayoutConstraint! {
        didSet {
            leftEditBarLeading.constant = spaceWidth
        }
    }
    // 右のバー
    @IBOutlet weak var rightEditBarTrailing: NSLayoutConstraint! {
        didSet {
            rightEditBarTrailing.constant = spaceWidth - meterWidth
        }
    }
    
    // MARK: 最背面の範囲のViewを表示するスクロールビュー
    
    @IBOutlet weak var editEreaScrollView: UIScrollView! {
        didSet {
            editEreaScrollView.delegate = self
            editEreaScrollView.showsHorizontalScrollIndicator = false
        }
    }
    @IBOutlet weak var backScroollContentView: UIView!
    @IBOutlet weak var backScrollContentViewWidth: NSLayoutConstraint! {
        didSet {
            // 波形のコンテンツの横幅 + ヘッダー + フッター
            backScrollContentViewWidth.constant = waveContentViewWidth + spaceWidth * 2
        }
    }
    
    // 波形表示部分の背景色をつけるためのViewの調整
    @IBOutlet weak var backContentViewLeading: NSLayoutConstraint! {
        didSet {
            backContentViewLeading.constant = spaceWidth
        }
    }
    // 波形表示部分の背景色をつけるためのViewの調整
    @IBOutlet weak var backContentViewTrailing: NSLayoutConstraint! {
           didSet {
               backContentViewTrailing.constant = spaceWidth
           }
       }
    
    // 編集エリアビューのLeadingの制約
    @IBOutlet weak var editAreaViewLeading: NSLayoutConstraint! {
        didSet {
            editAreaViewLeading.constant = spaceWidth
        }
    }
    // 編集エリアビューのTrailingの制約
    @IBOutlet weak var editAreaViewTrailing: NSLayoutConstraint! {
        didSet {
            editAreaViewTrailing.constant = spaceWidth - meterWidth
        }
    }
    
    // MARK: 編集エリアの設定
    
    @IBOutlet weak var leftBarButton: UIButton! {
        didSet {
            leftBarButton.allMaskCorner()
            leftBarButton.addTarget(self, action: #selector(moveLeftArea), for: .touchUpInside)
        }
    }
    
     @IBOutlet weak var rightBarButton: UIButton! {
        didSet {
            rightBarButton.allMaskCorner()
            rightBarButton.addTarget(self, action: #selector(moveRightArea), for: .touchUpInside)
        }
    }
    
    // 左の編集バーを移動させる
    // guard rightEditBarTrailing.constant < currentRightEditBarTrailing else { return }
    
    // 左の編集バーを移動させる
    @objc func moveLeftArea() {
        // 現在のスクロール位置
        let currentOffset = editBarScrollView.contentOffset.x
        // 現在のスクロール位置 + ヘッダー幅
        let editBarLeading = currentOffset + spaceWidth
        // 左の編集バーのLeadingを現在のスクロール位置に設定
        leftEditBarLeading.constant = editBarLeading
        // 編集エリアのLeadingを現在のスクロール位置に設定
        editAreaViewLeading.constant = editBarLeading
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    // 右の編集バーを移動させる
    // 右の編集バーが左の編集バーを越えないように制御
    // guard leftEditBarLeading.constant < currentLeftEditBarLeading else { return }
    
    // 右の編集バーを移動させる
    @objc func moveRightArea() {
        // 現在のスクロール位置
        let currentOffset = editBarScrollView.contentOffset.x
        // ContentViewの横幅 - (現在スクロール位置 + フッター幅 + メーター幅)
        let editBarTrailing = contentViewWidth - (currentOffset + spaceWidth + 2)
        // 右の編集バーのTrailingを現在のスクロール位置に設定
        rightEditBarTrailing.constant = editBarTrailing
        // 編集エリアのTrailingを現在のスクロール位置に設定
        editAreaViewTrailing.constant = editBarTrailing
        // アニメーションさせて移動させる
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: 再生
    
    @IBOutlet weak var playButton: UIButton! {
        didSet {
            playButton.allMaskCorner()
            playButton.addTarget(self, action: #selector(play), for: .touchUpInside)
        }
    }
    
    @objc private func play() {
        let isPlaying = editorManager.isPlaying
        // 再生ボタンUI(iOS13以降使用可能なSF Symbolsを使って画像切替)
        let playImage = isPlaying
            ? UIImage(systemName: "play.fill")
            : UIImage(systemName: "pause.fill")
        playButton.setImage(playImage, for: .normal)
        // 現在スクロール位置 / 20px(1秒の横幅)
        let currentTime = editBarScrollView.contentOffset.x / oneSecoundWidth
        let time = max(0, min(Double(currentTime), totalTime))
        // AVAudioPlayerの現在位置から再生と一時停止
        isPlaying
            ? editorManager.pause()
            : editorManager.play(currentTime: time)
        // タイマーをセット
        setupTimer(isPlaying: editorManager.isPlaying)
    }
    
    private func setupTimer(isPlaying: Bool) {
        if !isPlaying {
            playerTimer?.invalidate()
            playerTimer = nil
        } else {
            playerTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                guard self.editorManager.isPlaying else {
                    timer.invalidate()
                    self.playButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
                    return
                }
                // 0.1秒ごとに現在位置にメーター幅足して上げる
                var movePoint = self.editBarScrollView.contentOffset
                movePoint.x += 2
                self.editBarScrollView.setContentOffset(movePoint, animated: false)
            }
        }
    }
    
    // MARK: 編集
    
    @IBOutlet weak var editButton: UIButton! {
        didSet {
            editButton.allMaskCorner()
            editButton.addTarget(self, action: #selector(edit), for: .touchUpInside)
        }
    }
    
    // 音声を編集する
    @objc private func edit() {
        editorManager.edit(leftTime: leftEditBarTime, rightime: rightEditBarTime) { result in
            
            switch result {
            case let .success(removeRange):
                DispatchQueue.main.async {
                    self.waveCollectionView.performBatchUpdates({
                        var removeIndexs: [IndexPath] = []
                        for index in removeRange {
                            removeIndexs.append(IndexPath(item: index, section: 0))
                        }
                        self.waveCollectionView.deleteItems(at: removeIndexs)
                        self.initView()
                    })
                }
            case let .failure(error):
                print(error)
            }
        }
    }
    
    private func initView() {
        // フロントのScrollViewを初期状態に戻す
        frontScrollContentViewWidth.constant = waveContentViewWidth + spaceWidth * 2
        leftEditBarLeading.constant = spaceWidth
        rightEditBarTrailing.constant = spaceWidth - meterWidth
        // バックのScrollViewを初期状態に戻す
        backScrollContentViewWidth.constant = waveContentViewWidth + spaceWidth * 2
        editAreaViewTrailing.constant = spaceWidth - meterWidth
        editAreaViewLeading.constant = spaceWidth
        // トータル時間を修正
        totalTimeLabel.text = editorManager.totalTimeText
        
        // カーソル
        self.editEreaScrollView.setContentOffset(.zero, animated: false)
        self.editBarScrollView.setContentOffset(.zero, animated: false)
        self.waveCollectionView.setContentOffset(.zero, animated: false)
        self.waveCollectionView.reloadData()
        self.timeCollectionView.reloadData()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // 音声編集のマネージャー
    let editorManager: AudioEditorManager
    // 振幅
    var amplitudes: [Float] { editorManager.amplitudes }
    // タイムインターバルの横幅(0.1秒の横幅)
    let meterWidth: CGFloat = 2
    // 1秒の横幅
    let oneSecoundWidth: CGFloat = 20
    // 5秒
    let fiveSecond = 5

    // 波形表示のコンテンツの高さ
    var collectionViewHeight: CGFloat { waveCollectionView.frame.height }
    // ヘッダー・フッターの横幅(画面幅の半分)
    var spaceWidth: CGFloat {
        UIScreen.main.bounds.width / 2
    }
    // 収録した波形を表示するトータルの横幅
    var waveContentViewWidth: CGFloat {
        CGFloat(amplitudes.count) * meterWidth
    }
    // スクロールする全体のwidth
    var contentViewWidth: CGFloat {
        waveContentViewWidth + spaceWidth * 2
    }
    // 収録時間
    var totalTime: Double {
        editorManager.totalTime
    }
    // 左の編集バーの時間
    var leftEditBarTime: Double {
        let leftTime = (leftEditBarLeading.constant - spaceWidth) / oneSecoundWidth
        return max(0, min(Double(leftTime), totalTime))
    }
    // 右の編集バーの時間
    var rightEditBarTime: Double {
        let rightTime = (contentViewWidth - rightEditBarTrailing.constant - spaceWidth - meterWidth) / oneSecoundWidth
        return max(0, min(Double(rightTime), totalTime))
    }
    
    // 再生のタイマー
    var playerTimer: Timer?
    
    init(amplitudes: [Float], originalUrl: URL) {
        self.editorManager = AudioEditorManager(
            amplitudes: amplitudes,
            originalUrl: originalUrl
        )
        
        super.init(nibName: nil, bundle: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        totalTimeLabel.text = editorManager.totalTimeText
    }
    
    func decibelHeight(index: Int) -> CGFloat {
        let height = CGFloat(amplitudes[index]) * collectionViewHeight
        return height < collectionViewHeight ? height : collectionViewHeight
    }

    func setupCurrentTime() {
        // 現在スクロール位置 / 20px(1秒の横幅)
        let currentTime = editBarScrollView.contentOffset.x / oneSecoundWidth
        // 現在時間が収録時間を超えないように制御
        let time = max(0, min(Double(currentTime), totalTime))
        let timeText = editorManager.timeText(time: time)
        minuteTimeLabel.text = timeText.minute
        secondTimeLabel.text = timeText.second
        millisecondTimeLabel.text = timeText.millisecond
    }
}

extension AudioEditorViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionTypes[collectionView.tag] {
        case .decibel: return amplitudes.count
        // ex) 収録時間:11秒 / 5秒 + 1 = 3
        //     表示時間:0:00、00:05、00:10
        case .time: return Int(totalTime / 5.0) + 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch collectionTypes[collectionView.tag] {
        case .decibel:
            let cell = collectionView.dequeueReusableCell(for: indexPath) as WaveWithMeterCollectionViewCell
            cell.draw(
                height: decibelHeight(index: indexPath.row),
                index: indexPath.row
            )
            return cell
        case .time:
            let cell = collectionView.dequeueReusableCell(for: indexPath) as TimeCollectionViewCell
            cell.draw(time: editorManager.meterTime(index: indexPath.row))
            return cell
        }
    }
}

extension AudioEditorViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        switch collectionTypes[collectionView.tag] {
        case .decibel:
            return CGSize(width: meterWidth, height: collectionViewHeight)
        case .time:
            // Cellサイズは0.1秒で2pxなので5秒だと100px
            return CGSize(width: 20 * 5, height: 10)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        .zero
    }
    
    // 水平方向におけるセル間のマージン
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        0
    }

    // 垂直方向におけるセル間のマージン
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        0
    }
    
    // ヘッダーを追加
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        CGSize(width: spaceWidth, height: collectionViewHeight)
    }

    // フッターを追加
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
        CGSize(width: spaceWidth, height: collectionViewHeight)
    }
}

extension AudioEditorViewController: UIScrollViewDelegate {
    // 編集バーScrollViewのスクロールイベント
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // 編集バーのスクロールされた距離
        let contentOffset = scrollView.contentOffset
        // 各ScrollViewと連結
        waveCollectionView.setContentOffset(contentOffset, animated: false)
        timeCollectionView.setContentOffset(contentOffset, animated: false)
        editEreaScrollView.setContentOffset(contentOffset, animated: false)
        // スクロール量に応じて、現在時刻の更新
        setupCurrentTime()
    }
}

