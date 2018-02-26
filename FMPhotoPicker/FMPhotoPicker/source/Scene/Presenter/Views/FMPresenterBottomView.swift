//
//  FMPresenterBottomView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/19.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
import AVKit

class FMPresenterBottomView: UIView {
    // should be false when the view is hidden
    private var shouldReceiveUpdate = true
    
    public var playbackControlView: FMPlaybackControlView
    public var touchBegan: () -> Void = {} {
        didSet { self.playbackControlView.touchBegan = self.touchBegan }
    }
    public var touchEnded: () -> Void = {} {
        didSet { self.playbackControlView.touchEnded = self.touchEnded }
    }
    
    public var playerProgressDidChange: ((Double) -> Void)?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    init() {
        playbackControlView = FMPlaybackControlView()
        super.init(frame: .zero)
        
        self.addSubview(playbackControlView)
        playbackControlView.translatesAutoresizingMaskIntoConstraints = false
        playbackControlView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        playbackControlView.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        playbackControlView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        playbackControlView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        
        playerProgressDidChange = { [unowned self] percent in
            self.playbackControlView.playerProgressDidChange(value: percent)
        }
    }
    
    public func resetPlaybackControl(cgImages: [CGImage], duration: TimeInterval) {
        if shouldReceiveUpdate {
            playbackControlView.resetPlaybackControl(cgImages: cgImages, duration: duration)
        }
    }
    
    public func show() {
        self.isHidden = false
        self.shouldReceiveUpdate = true
        resetPlaybackControl(cgImages: [], duration: 0)
    }
    
    public func hide() {
        self.isHidden = true
        self.shouldReceiveUpdate = false
    }
    
    public func updateFrames() {
        playbackControlView.updateFrames()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchBegan()
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchEnded()
        super.touchesEnded(touches, with: event)
    }
}
