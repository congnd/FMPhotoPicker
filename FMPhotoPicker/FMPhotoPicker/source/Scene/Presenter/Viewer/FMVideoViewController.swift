//
//  FMVideoViewController.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/21.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
import AVKit

class FMVideoViewController: FMPhotoViewController {
    
    public var playerProgressDidChange: ((Double) -> Void)?
   
    private var thumbImageView: UIImageView!
    private var playIcon: UIButton!
    
    private var playerController: AVPlayerViewController?
    public var player: AVPlayer?
    private var playerTimeObserver: Any?
    
    private var shouldUpdateView = true
    private var isPlayingBeforeSeek = false
    
    private var isSeekInProgress = false
    private var chaseTime = CMTime.zero
    
    deinit {
        removeVideoControlObservers()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.thumbImageView = UIImageView(frame: self.view.frame)
        self.thumbImageView.contentMode = .scaleAspectFit
        self.view.addSubview(self.thumbImageView)
        
        playIcon = UIButton(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        playIcon.center = self.view.center
        playIcon.setImage(UIImage(named: "icon_play", in: .current, compatibleWith: nil), for: .normal)
        playIcon.addTarget(self, action: #selector(playButtonHandler), for: .touchUpInside)
        self.view.addSubview(playIcon)
        
        
        photo.requestThumb { image in
            self.thumbImageView.image = image
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        photo.requestFullSizePhoto(cropState: .edited, filterState: .edited) { fullSizeImage in
            if self.shouldUpdateView == false { return }
            if let fullSizeImage = fullSizeImage {
                self.thumbImageView.image = fullSizeImage
            }
        }
        loadVideoIfNeeded()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.shouldUpdateView = true
        self.setupVideoControlObservers()
        self.playIcon.isHidden = false
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.shouldUpdateView = false
        if self.player?.isPlaying == true {
            self.player?.pause()
        }
        self.removeVideoControlObservers()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func loadVideoIfNeeded() {
        guard (playerController == nil),
            let asset = photo.asset else { return }
        
        Helper.requestAVAsset(asset: asset) { avAsset in
            // Do not run on main thread for better perf
            DispatchQueue.global(qos: .userInitiated).async {
                guard self.shouldUpdateView == true,
                    let avAsset = avAsset else { return }
                
                let playerItem = AVPlayerItem(asset: avAsset)
                self.player = AVPlayer(playerItem: playerItem)
                
                self.playerController = AVPlayerViewController()
                self.playerController?.player = self.player
                
                DispatchQueue.main.async {
                    self.playerController?.view.frame = self.view.frame
                    self.playerController?.showsPlaybackControls = false
                }
                
                self.addPlayerTimeObserverIfNeeded()
            }
        }
    }
    
    // MARK -
    @objc private func playButtonHandler() {
        if player?.isPlaying == true {
            pause()
        } else if player?.isPlaying == false {
            play()
        }
    }
    
    @objc func playerDidFinishPlaying(note: NSNotification){
        thumbImageView.isHidden = false
        playIcon.isHidden = false
        playerController?.view.isHidden = true
        player?.seek(to: CMTimeMakeWithSeconds(0, preferredTimescale: 1000))
        NotificationCenter.default.post(name: .player_pause, object: nil)
    }
    
    public func play() {
        addPlayerViewCotrollerViewIfNeeded()
        playerController?.view.isHidden = false
        thumbImageView.isHidden = true
        playIcon.isHidden = true
        player?.play()
        NotificationCenter.default.post(name: .player_play, object: nil)
    }
    
    private func addPlayerViewCotrollerViewIfNeeded() {
        guard let playerController = self.playerController else { return }
        
        if playerController.view.superview == nil {
            self.addChild(playerController)
            self.view.addSubview(playerController.view)
            self.view.bringSubviewToFront(thumbImageView)
            self.view.bringSubviewToFront(playIcon)
        }
    }
        
    public func pause() {
        addPlayerViewCotrollerViewIfNeeded()
        playerController?.view.isHidden = false
        thumbImageView.isHidden = true
        playIcon.isHidden = false
        player?.pause()
        NotificationCenter.default.post(name: .player_pause, object: nil)
    }
    
    @objc public func controller_request_pause() {
        pause()
    }
    
    @objc public func controller_request_play() {
        play()
    }
    
    @objc public func controller_request_seek_began() {
        guard let player = self.player else { return }
        isPlayingBeforeSeek = player.isPlaying
        pause()
    }
    
    @objc public func controller_request_seek_ended() {
        if isPlayingBeforeSeek {
            play()
        }
    }
    
    @objc public func controller_request_seek_to(notification: NSNotification) {
        guard let percent = notification.userInfo?["percent"] as? Double,
            let player = self.player,
            let currentPlayerItem = player.currentItem
            else { return }
        let cmTime = CMTimeMakeWithSeconds(currentPlayerItem.duration.seconds * percent, preferredTimescale: 1000)
//        player.seek(to: cmTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        seekSmoothlyToTime(newChaseTime: cmTime)
        
    }
    
    // Don't forget to remove observers that you added here
    private func setupVideoControlObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(controller_request_pause), name: .controller_pause, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controller_request_play), name: .controller_play, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controller_request_seek_began), name: .player_seek_began, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controller_request_seek_to(notification:)), name: .player_seek_to, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(controller_request_seek_ended), name: .player_seek_ended, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector:#selector(self.playerDidFinishPlaying(note:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        
        addPlayerTimeObserverIfNeeded()
    }
    
    private func addPlayerTimeObserverIfNeeded() {
        if playerTimeObserver == nil {
            self.playerTimeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(1, preferredTimescale: 1000), queue: .main, using: { [weak self] time in
                guard let self = self else { return }
                
                guard let status = self.player?.currentItem?.status,
                    status == .readyToPlay else {
                    return
                }
                    
                let time = CMTimeGetSeconds(time)
                let progress = (time / self.player!.currentItem!.duration.seconds)
                self.playerProgressDidChange?(progress)
            })
        }
    }
    
    private func removeVideoControlObservers() {
        NotificationCenter.default.removeObserver(self, name: .controller_pause, object: nil)
        NotificationCenter.default.removeObserver(self, name: .controller_play, object: nil)
        NotificationCenter.default.removeObserver(self, name: .player_seek_began, object: nil)
        NotificationCenter.default.removeObserver(self, name: .player_seek_to, object: nil)
        NotificationCenter.default.removeObserver(self, name: .player_seek_ended, object: nil)
        NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: nil)
        
        if let playerTimeObserver = self.playerTimeObserver {
            self.player?.removeTimeObserver(playerTimeObserver)
            self.playerTimeObserver = nil
        }
    }
    
    
    // MARK - Seek Smoothly
    // Ref: https://developer.apple.com/library/content/qa/qa1820/_index.html
    func seekSmoothlyToTime(newChaseTime: CMTime) {
        if CMTimeCompare(newChaseTime, chaseTime) != 0 {
            chaseTime = newChaseTime;
            if !isSeekInProgress {
                trySeekToChaseTime()
            }
        }
    }
    
    func trySeekToChaseTime() {
        if self.player?.currentItem?.status == .unknown {
            // wait until item becomes ready (KVO player.currentItem.status)
        }
        else if self.player?.currentItem?.status == .readyToPlay {
            actuallySeekToTime()
        }
    }
    
    func actuallySeekToTime() {
        isSeekInProgress = true
        let seekTimeInProgress = chaseTime
        player!.seek(to: seekTimeInProgress, toleranceBefore: CMTime.zero, toleranceAfter: CMTime.zero, completionHandler: { isFinished in
            if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                self.isSeekInProgress = false
            } else {
                self.trySeekToChaseTime()
            }
        })
    }
}
