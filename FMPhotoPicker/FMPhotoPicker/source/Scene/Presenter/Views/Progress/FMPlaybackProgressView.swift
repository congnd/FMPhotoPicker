//
//  FMPlaybackProgressView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/19.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore
import AVKit

class FMPlaybackProgressView: UIControl {
    public var touchBegan: () -> Void = {}
    public var touchEnded: () -> Void = {}
    
    var minimumValue = 0.0
    var maximumValue = 1.0
    var thumbValue = 0.0
    
    var previousLocation = CGPoint()
    
    let trackLayer = FMPlaybackProgressTrackLayer()
    let thumbLayer = FMPlaybackProgressThumbLayer()
    
    var thumbHeight: CGFloat {
        return CGFloat(bounds.height)
    }
    
    var thumbWidth: CGFloat = 30.0
    
    var trackHeight: CGFloat = 38.0
    
    override var frame: CGRect {
        didSet {
            updateLayerFrames()
        }
    }
    
    var trackHighlightTintColor = UIColor(red: 0.0, green: 0.45, blue: 0.94, alpha: 1.0)
    var thumbTintColor = UIColor.white
    var curvaceousness: CGFloat = 1.0
    var thumbIconWidth: CGFloat = 6.0
    
    private var shouldUpdateThumbPosition = true
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        trackLayer.rangeSlider = self
        trackLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(trackLayer)
        
        thumbLayer.rangeSlider = self
        thumbLayer.contentsScale = UIScreen.main.scale
        layer.addSublayer(thumbLayer)

        updateLayerFrames()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    public func resetPlaybackControl(cgImages: [CGImage]) {
        self.trackLayer.cgImages = cgImages
        thumbValue = 0
        
        updateLayerFrames()
    }
    
    func updateLayerFrames() {
        updateTrackLayer()
        updateThumbLayer()
    }
    
    func updateTrackLayer() {
        trackLayer.frame = CGRect(x: (thumbWidth - thumbIconWidth) / 2,
                                  y: (frame.height - trackHeight) / 2,
                                  width: frame.width - (thumbWidth - thumbIconWidth),
                                  height: trackHeight)
        trackLayer.setNeedsDisplay()
    }
    
    func updateThumbLayer() {
        let lowerThumbCenter = CGFloat(positionForValue(value: thumbValue))
        
        thumbLayer.frame = CGRect(x: lowerThumbCenter - thumbWidth / 2.0, y: 0.0,
                                       width: thumbWidth, height: thumbHeight)
        thumbLayer.setNeedsDisplay()
    }
    
    func positionForValue(value: Double) -> Double {
        return Double(bounds.width - thumbWidth) * (value - minimumValue) / (maximumValue - minimumValue) + Double(thumbWidth / 2.0)
    }
    
    override func beginTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        self.touchBegan()
        previousLocation = touch.location(in: self)
        
        // Hit test the thumb layers
        if thumbLayer.frame.contains(previousLocation) {
            shouldUpdateThumbPosition = false
            thumbLayer.highlighted = true
            NotificationCenter.default.post(name: .player_seek_began, object: nil)
            return true
        }
        self.touchEnded()
        return false
    }
    
    func boundValue(value: Double, toLowerValue lowerValue: Double, upperValue: Double) -> Double {
        return min(max(value, lowerValue), upperValue)
    }
    
    override func continueTracking(_ touch: UITouch, with event: UIEvent?) -> Bool {
        let location = touch.location(in: self)
        
        let nextValue = Double((location.x - ((thumbWidth - thumbIconWidth) / 2)) / (frame.width - (thumbWidth - thumbIconWidth)))
        
        thumbValue = boundValue(value: nextValue, toLowerValue: minimumValue, upperValue: maximumValue)
        
        // 3. Update the UI
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        updateThumbLayer()
        CATransaction.commit()
        
        NotificationCenter.default.post(name: .player_seek_to, object: nil, userInfo: ["percent": nextValue])
        return true
    }
    
    override func endTracking(_ touch: UITouch?, with event: UIEvent?) {
        self.touchEnded()
        thumbLayer.highlighted = false
        shouldUpdateThumbPosition = true
        NotificationCenter.default.post(name: .player_seek_ended, object: nil)
    }
    
    override func cancelTracking(with event: UIEvent?) {
        self.touchEnded()
    }
    
    public func playerProgressDidChange(value: Double) {
        if shouldUpdateThumbPosition {
            thumbValue = value
            updateThumbLayer()
        }
    }
}

