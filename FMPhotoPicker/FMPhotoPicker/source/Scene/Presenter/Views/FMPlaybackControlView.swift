//
//  FMPlaybackControlView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/19.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
import AVKit

public extension Notification.Name {
    static let controller_play = Notification.Name("controller_play")
    static let controller_pause = Notification.Name("controller_pause")
    static let player_pause = Notification.Name("player_pause")
    static let player_play = Notification.Name("player_play")
    static let player_seek_to = Notification.Name("player_seek_to")
    static let player_seek_began = Notification.Name("player_seek_began")
    static let player_seek_ended = Notification.Name("player_seek_ended")
    static let player_current_position_updated = Notification.Name("player_current_position_updated")
}

class FMPlaybackControlView: UIView {
    
    let progressMarginLeft: CGFloat = 8.0
    let progressMarginTop: CGFloat = 6.0
    let progressHeight: CGFloat = 50
    
    public var playbackProgressView: FMPlaybackProgressView
    private let currentTimeLabel: UILabel!
    private let totalTimeLabel:UILabel!
    private let playButton: UIButton!
    
    private var duration: TimeInterval?
    private var isPlaying = false
    
    public var touchBegan: () -> Void = {} {
        didSet {
            self.playbackProgressView.touchBegan = self.touchBegan
        }
    }
    public var touchEnded: () -> Void = {} {
        didSet {
            self.playbackProgressView.touchEnded = self.touchEnded
        }
    }
    
    init() {
        playbackProgressView = FMPlaybackProgressView(frame: .zero)
        currentTimeLabel = UILabel()
        totalTimeLabel = UILabel()
        playButton = UIButton()
        super.init(frame: .zero)
        
        self.addSubview(playbackProgressView)
        self.addSubview(currentTimeLabel)
        self.addSubview(totalTimeLabel)
        self.addSubview(playButton)
        
        playbackProgressView.translatesAutoresizingMaskIntoConstraints = false
        playbackProgressView.topAnchor.constraint(equalTo: self.topAnchor, constant: progressMarginTop).isActive = true
        playbackProgressView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: progressMarginLeft).isActive = true
        playbackProgressView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -progressMarginLeft).isActive = true
        playbackProgressView.heightAnchor.constraint(equalToConstant: progressHeight).isActive = true
        
        currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        currentTimeLabel.leftAnchor.constraint(equalTo: playbackProgressView.leftAnchor,
                                             constant: (playbackProgressView.thumbWidth - playbackProgressView.thumbIconWidth) / 2).isActive = true
        currentTimeLabel.topAnchor.constraint(equalTo: playbackProgressView.bottomAnchor, constant: 2).isActive = true
        currentTimeLabel.font = UIFont.systemFont(ofSize: 13)
        currentTimeLabel.textColor = .white
        currentTimeLabel.text = "0:00"
        currentTimeLabel.textColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        
        totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        totalTimeLabel.rightAnchor.constraint(equalTo: playbackProgressView.rightAnchor,
                                             constant: -(playbackProgressView.thumbWidth - playbackProgressView.thumbIconWidth) / 2).isActive = true
        totalTimeLabel.topAnchor.constraint(equalTo: playbackProgressView.bottomAnchor, constant: 2).isActive = true
        totalTimeLabel.font = UIFont.systemFont(ofSize: 13)
        totalTimeLabel.textColor = .white
        totalTimeLabel.text = "0:00"
        totalTimeLabel.textColor = UIColor(red: 65/255, green: 65/255, blue: 65/255, alpha: 1)
        
        playButton.translatesAutoresizingMaskIntoConstraints = false
        playButton.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        playButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        playButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        playButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        playButton.setImage(UIImage(named: "icon_play_small", in: .current, compatibleWith: nil), for: .normal)
        playButton.addTarget(self, action: #selector(onTapPlayButton), for: .touchUpInside)
        playButton.isHidden = true
        
        self.backgroundColor = kTransparentBackgroundColor
        addPlayerObservers()
        
        // top border view
        let topBorder = UIView(frame: .zero)
        topBorder.backgroundColor = kBorderColor
        addSubview(topBorder)
        
        topBorder.translatesAutoresizingMaskIntoConstraints = false
        topBorder.topAnchor.constraint(equalTo: topAnchor).isActive = true
        topBorder.leftAnchor.constraint(equalTo: leftAnchor).isActive = true
        topBorder.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        topBorder.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func resetPlaybackControl(cgImages: [CGImage], duration: TimeInterval) {
        self.duration = duration
        playbackProgressView.resetPlaybackControl(cgImages: cgImages)
        currentTimeLabel.text = "0:00"
        totalTimeLabel.text = duration.stringTime
        playButton.isHidden = true
    }
    
    public func updateFrames() {
        self.playbackProgressView.updateLayerFrames()
    }
    
    public func playerProgressDidChange(value: Double) {
        guard let duration = duration else { return }
        currentTimeLabel.text = (duration * value).stringTime
        playbackProgressView.playerProgressDidChange(value: value)
    }
    
    @objc private func onTapPlayButton() {
        isPlaying = !isPlaying
        updatePlayButton()
        if isPlaying {
            NotificationCenter.default.post(name: .controller_play, object: nil)
        } else {
            NotificationCenter.default.post(name: .controller_pause, object: nil)
        }
    }
    
    private func updatePlayButton() {
        if isPlaying {
            playButton.isHidden = false
            playButton.setImage(UIImage(named: "icon_pause_small", in: .current, compatibleWith: nil), for: .normal)
        } else {
            playButton.isHidden = false
            playButton.setImage(UIImage(named: "icon_play_small", in: .current, compatibleWith: nil), for: .normal)
        }
    }
    
    @objc private func player_play() {
        isPlaying = true
        updatePlayButton()
    }
    
    @objc private func player_pause() {
        isPlaying = false
        updatePlayButton()
    }
    
    private func addPlayerObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(player_play), name: .player_play, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(player_pause), name: .player_pause, object: nil)
    }
    
    private func removePlayerObservers() {
        NotificationCenter.default.removeObserver(self, name: .player_play, object: nil)
        NotificationCenter.default.removeObserver(self, name: .player_pause, object: nil)
    }
    
    deinit {
        removePlayerObservers()
    }
}
