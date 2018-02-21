//
//  FMPlaybackProgressTrackLayer.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/19.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
import QuartzCore

class FMPlaybackProgressTrackLayer: CALayer {
    weak var rangeSlider: FMPlaybackProgressView?
    public var cgImages: [CGImage] = []
    
    override func draw(in ctx: CGContext) {
        if let slider = rangeSlider {
            let subLayerWidth = self.frame.width / CGFloat(cgImages.count)
            for (index, cgImage) in cgImages.enumerated() {
                let imageLayer = CALayer()
                imageLayer.frame = CGRect(x: CGFloat(index) * subLayerWidth, y: 0, width: subLayerWidth, height: self.frame.height)
                imageLayer.contents = cgImage
                imageLayer.contentsScale = UIScreen.main.scale
                imageLayer.contentsGravity = kCAGravityResizeAspectFill
                imageLayer.masksToBounds = true
                self.addSublayer(imageLayer)
            }
        }
    }
}

