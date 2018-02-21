//
//  FMPlaybackControlView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/19.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
import AVKit

class FMPlaybackControlView: UIView {
    
    let progressMarginLeft: CGFloat = 8.0
    let progressMarginTop: CGFloat = 6.0
    let progressHeight: CGFloat = 50
    
    public var playbackProgressView: FMPlaybackProgressView
    private let currentTimeLabel: UILabel!
    private let totalTimeLabel:UILabel!
    
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
        super.init(frame: .zero)
        
        self.addSubview(playbackProgressView)
        self.addSubview(currentTimeLabel)
        self.addSubview(totalTimeLabel)
        
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
        
        totalTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        totalTimeLabel.rightAnchor.constraint(equalTo: playbackProgressView.rightAnchor,
                                             constant: -(playbackProgressView.thumbWidth - playbackProgressView.thumbIconWidth) / 2).isActive = true
        totalTimeLabel.topAnchor.constraint(equalTo: playbackProgressView.bottomAnchor, constant: 2).isActive = true
        totalTimeLabel.font = UIFont.systemFont(ofSize: 13)
        totalTimeLabel.textColor = .white
        totalTimeLabel.text = "0:00"
        
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func resetPlaybackControl(cgImages: [CGImage], duration: TimeInterval) {
        playbackProgressView.resetPlaybackControl(cgImages: cgImages)
        currentTimeLabel.text = "0:00"
        totalTimeLabel.text = duration.stringTime
    }
    
    public func updateFrames() {
        self.playbackProgressView.updateLayerFrames()
    }
}
