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
    private var chaseTime = kCMTimeZero
    private var playerCurrentItemStatus: AVPlayerItemStatus = .unknown
    
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
        playIcon.setImage(UIImage(named: "icon_play", in: Bundle(for: self.classForCoder), compatibleWith: nil), for: .normal)
        playIcon.addTarget(self, action: #selector(playButtonHandler), for: .touchUpInside)
        self.view.addSubview(playIcon)
        
        
        photo.requestThumb { image in
            self.thumbImageView.image = image
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        photo.requestFullSizePhoto() { fullSizeImage in
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
        guard (playerController == nil) else { return }
        
        Helper.requestAVAsset(asset: photo.asset) { avAsset in
            // Do not run on main thread for better perf
            DispatchQueue.global(qos: .userInitiated).async {
                guard self.shouldUpdateView,
                    let avURLAsset = avAsset as? AVURLAsset else { return }
                self.player = AVPlayer(url: avURLAsset.url)
                
                self.playerTimeObserver = self.player?.addPeriodicTimeObserver(forInterval: CMTimeMakeWithSeconds(0.1, 1000), queue: .main, using: { time in
                    let time = CMTimeGetSeconds(time)
                    let progress = (time / self.photo.asset.duration)
                    self.playerProgressDidChange?(progress)
                })
                
                self.playerController = AVPlayerViewController()
                self.playerController?.player = self.player
                
                DispatchQueue.main.async {
                    self.playerController?.view.frame = self.view.frame
                    self.playerController?.showsPlaybackControls = false
                }
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
        player?.seek(to: CMTimeMakeWithSeconds(0, 1000))
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
            self.addChildViewController(playerController)
            self.view.addSubview(playerController.view)
            self.view.bringSubview(toFront: thumbImageView)
            self.view.bringSubview(toFront: playIcon)
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
            let player = self.player
            else { return }
        let cmTime = CMTimeMakeWithSeconds(Double(photo.asset.duration) * percent, 1000)
        player.seek(to: cmTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
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
            } else {
                print("rejected")
            }
        }
    }
    
    func trySeekToChaseTime() {
        if playerCurrentItemStatus == .unknown {
            // wait until item becomes ready (KVO player.currentItem.status)
        }
        else if playerCurrentItemStatus == .readyToPlay {
            actuallySeekToTime()
        }
    }
    
    func actuallySeekToTime() {
        isSeekInProgress = true
        let seekTimeInProgress = chaseTime
        player!.seek(to: seekTimeInProgress, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero, completionHandler: { isFinished in
            if CMTimeCompare(seekTimeInProgress, self.chaseTime) == 0 {
                self.isSeekInProgress = false
            } else {
                self.trySeekToChaseTime()
            }
        })
    }
}
