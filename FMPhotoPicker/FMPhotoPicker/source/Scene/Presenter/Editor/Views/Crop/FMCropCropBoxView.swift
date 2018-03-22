//
//  FMCropCropBoxView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/05.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

enum FMCropCropBoxEdge {
    case topRight
    case bottomRight
    case bottomLeft
    case topLeft
    
    case top
    case left
    case bottom
    case right
    
    case undefined
}

class FMCropCropBoxView: UIView {
    public var cropBoxControlChanged: (CGRect) -> Void = {_ in }
    public var cropBoxControlEnded: () -> Void = {}
    public var cropBoxControlStarted: () -> Void = {}
    
    public weak var cropView: FMCropView! {
        didSet {
            resizeGestureRecognizer = UIPanGestureRecognizer()
            resizeGestureRecognizer.addTarget(self, action: #selector(handleResizeGestrureRecognizer(recognizer:)))
            resizeGestureRecognizer.delegate = self
            cropView.addGestureRecognizer(resizeGestureRecognizer)
            cropView.scrollView.panGestureRecognizer.require(toFail: resizeGestureRecognizer)
        }
    }
    public var resizeGestureRecognizer: UIPanGestureRecognizer!
    public var cropRatio: FMCropRatio?
    
    private var panOriginEdge: FMCropCropBoxEdge = .undefined
    private var panOriginPoint: CGPoint = .zero
    private var panOriginFrame: CGRect = .zero
    private var contentFrame: CGRect = .zero
    private let minSize = CGSize(width: 60, height: 60)
    
    public var isCropping: Bool = false {
        didSet {
            
        }
    }
    
    override var frame: CGRect {
        didSet {
            
        }
    }

    init(cropRatio: FMCropRatio?) {
        self.cropRatio = cropRatio
        
        super.init(frame: .zero)
        
        isUserInteractionEnabled = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleResizeGestrureRecognizer(recognizer: UIPanGestureRecognizer) {
        guard isCropping == true else { return }
        
        let tapPoint = recognizer.location(in: cropView)
        
        if recognizer.state == .began {
            panOriginEdge = self.edge(forPoint: tapPoint)
            panOriginPoint = tapPoint
            panOriginFrame = self.frame
            
            // TODO: It should be here?
            contentFrame = cropView.contentFrame
            
            cropBoxControlStarted()
        }
        
        if recognizer.state == .ended || recognizer.state == .cancelled {
            cropBoxControlEnded()
        }
        receivedResizeControlTouch(inPoint: tapPoint)
    }
    
    public func receivedResizeControlTouch(inPoint point: CGPoint) {
        let deltaX = ceil(point.x - panOriginPoint.x)
        let deltaY = ceil(point.y - panOriginPoint.y)
        
        var frame = self.frame
        let ratio = cropRatio == nil ? nil : (CGFloat(cropRatio!.width) / CGFloat(cropRatio!.height))
        
        switch panOriginEdge {
        case .top:
            frame.size.height = panOriginFrame.height - deltaY
            if let ratio = ratio { frame.size.width = ceil(frame.height * ratio) }
            frame.origin.y = panOriginFrame.maxY - frame.height
            frame.origin.x = panOriginFrame.origin.x + (panOriginFrame.width - frame.width) * 0.5
            
            if frame.minX < contentFrame.minX {
                frame.size.width = (panOriginFrame.midX - contentFrame.minX) * 2
                if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
                frame.origin.y = panOriginFrame.maxY - frame.height
                frame.origin.x = panOriginFrame.origin.x + (panOriginFrame.width - frame.width) * 0.5
            }
            
            if frame.minY < contentFrame.minY {
                frame.size.height = panOriginFrame.maxY - contentFrame.minY
                if let ratio = ratio { frame.size.width = ceil(frame.height * ratio) }
                frame.origin.y = panOriginFrame.maxY - frame.height
                frame.origin.x = panOriginFrame.origin.x + (panOriginFrame.width - frame.width) * 0.5
            }
            
            if frame.maxX > contentFrame.maxX {
                frame.size.width = (contentFrame.maxX - panOriginFrame.midX) * 2
                if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
                frame.origin.y = panOriginFrame.maxY - frame.height
                frame.origin.x = panOriginFrame.origin.x + (panOriginFrame.width - frame.width) * 0.5
            }
            
            var minFrame = CGRect(x: panOriginFrame.minX + (panOriginFrame.width - panOriginFrame.width) * 0.5,
                                  y: panOriginFrame.maxY - minSize.height,
                                  width: panOriginFrame.width,
                                  height: minSize.height)
            if let ratio = ratio {
                minFrame.size.width = ceil(minSize.height * ratio)
                if minFrame.size.width < minSize.width {
                    minFrame.size.width = minSize.width
                    minFrame.size.height = ceil(minFrame.width / ratio)
                }
                minFrame.origin.x = panOriginFrame.minX + (panOriginFrame.width - minFrame.width) * 0.5
                minFrame.origin.y = panOriginFrame.maxY - minFrame.height
            }
            if !frame.contains(minFrame) {
                frame = minFrame
            }
            
        case .right:
            frame.size.width = panOriginFrame.width + deltaX
            if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
            frame.origin.y = panOriginFrame.minY - (frame.height - panOriginFrame.height) * 0.5
            
            if frame.minY < contentFrame.minY {
                frame.size.height = (panOriginFrame.midY - contentFrame.minY) * 2
                if let ratio = ratio { frame.size.width = ceil(frame.height * ratio) }
                frame.origin.y = panOriginFrame.minY - (frame.height - panOriginFrame.height) * 0.5
            }
            
            if frame.maxX > contentFrame.maxX {
                frame.size.width = contentFrame.maxX - panOriginFrame.minX
                if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
                frame.origin.y = panOriginFrame.minY - (frame.height - panOriginFrame.height) * 0.5
            }
            
            if frame.maxY > contentFrame.maxY {
                frame.size.height = (contentFrame.maxY - panOriginFrame.midY) * 2
                if let ratio = ratio { frame.size.width = ceil(frame.height * ratio) }
                frame.origin.y = panOriginFrame.minY - (frame.height - panOriginFrame.height) * 0.5
            }
            
            var minFrame = CGRect(x: panOriginFrame.minX,
                                  y: panOriginFrame.minY + (panOriginFrame.height - panOriginFrame.height) * 0.5,
                                  width: minSize.width,
                                  height: panOriginFrame.height)
            if let ratio = ratio {
                minFrame.size.height = ceil(minSize.width / ratio)
                if minFrame.size.height < minSize.height {
                    minFrame.size.height = minSize.height
                    minFrame.size.width = ceil(minFrame.height * ratio)
                }
                minFrame.origin.y = panOriginFrame.minY + (panOriginFrame.height - minFrame.height) * 0.5
            }
            if !frame.contains(minFrame) {
                frame = minFrame
            }
        case .bottom:
            frame.size.height = panOriginFrame.height + deltaY
            if let ratio = ratio { frame.size.width = ceil(frame.height * ratio) }
            frame.origin.x = panOriginFrame.minX - (frame.width - panOriginFrame.width) * 0.5
            
            if frame.maxX > contentFrame.maxX {
                frame.size.width = (contentFrame.maxX - panOriginFrame.midX) * 2
                if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
                frame.origin.x = panOriginFrame.minX - (frame.width - panOriginFrame.width) * 0.5
            }
            
            if frame.maxY > contentFrame.maxY {
                frame.size.height = contentFrame.maxY - panOriginFrame.minY
                if let ratio = ratio { frame.size.width = ceil(frame.height * ratio) }
                frame.origin.x = panOriginFrame.minX - (frame.width - panOriginFrame.width) * 0.5
            }
            
            if frame.minX < contentFrame.minX {
                frame.size.width = (panOriginFrame.midX - contentFrame.minX) * 2
                if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
                frame.origin.x = panOriginFrame.minX - (frame.width - panOriginFrame.width) * 0.5
            }
            
            var minFrame = CGRect(x: panOriginFrame.minX  + (panOriginFrame.width - panOriginFrame.width) * 0.5,
                                  y: panOriginFrame.minY,
                                  width: panOriginFrame.width,
                                  height: minSize.height)
            if let ratio = ratio {
                minFrame.size.width = ceil(minSize.height * ratio)
                if minFrame.size.width < minSize.width {
                    minFrame.size.width = minSize.width
                    minFrame.size.height = ceil(minFrame.width / ratio)
                }
                minFrame.origin.x = panOriginFrame.minX + (panOriginFrame.width - minFrame.width) * 0.5
            }
            if !frame.contains(minFrame) {
                frame = minFrame
            }
            
        case .left:
            frame.size.width = panOriginFrame.width - deltaX
            if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
            frame.origin.x = panOriginFrame.maxX - frame.width
            frame.origin.y = panOriginFrame.origin.y + (panOriginFrame.height - frame.height) * 0.5
            
            if frame.minX < contentFrame.minX {
                frame.size.width = panOriginFrame.maxX - contentFrame.minX
                if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
                frame.origin.x = panOriginFrame.maxX - frame.width
                frame.origin.y = panOriginFrame.origin.y + (panOriginFrame.height - frame.height) * 0.5
            }
            
            if frame.maxY > contentFrame.maxY {
                frame.size.height = (contentFrame.maxY - panOriginFrame.midY) * 2
                if let ratio = ratio { frame.size.width = ceil(frame.height * ratio) }
                frame.origin.x = panOriginFrame.maxX - frame.width
                frame.origin.y = panOriginFrame.origin.y + (panOriginFrame.height - frame.height) * 0.5
            }
            
            if frame.minY < contentFrame.minY {
                frame.size.height = panOriginFrame.maxY - contentFrame.minY
                if let ratio = ratio { frame.size.width = ceil(frame.height * ratio) }
                frame.origin.x = panOriginFrame.maxX - frame.width
                frame.origin.y = panOriginFrame.origin.y + (panOriginFrame.height - frame.height) * 0.5
            }
            
            var minFrame = CGRect(x: panOriginFrame.maxX - minSize.width,
                                  y: panOriginFrame.minY + (panOriginFrame.height - panOriginFrame.height) * 0.5,
                                  width: minSize.width,
                                  height: panOriginFrame.height)
            if let ratio = ratio {
                minFrame.size.height = ceil(minSize.width / ratio)
                if minFrame.size.height < minSize.height {
                    minFrame.size.height = minSize.height
                    minFrame.size.width = ceil(minFrame.height * ratio)
                }
                minFrame.origin.x = panOriginFrame.maxX - minFrame.width
                minFrame.origin.y = panOriginFrame.minY + (panOriginFrame.height - minFrame.height) * 0.5
            }
            if !frame.contains(minFrame) {
                frame = minFrame
            }
        case .topRight:
            frame.size.width = max(panOriginFrame.width + deltaX, minSize.width)
            frame.size.height = max(panOriginFrame.height - deltaY, minSize.height)
            if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
            frame.origin.y = panOriginFrame.maxY - frame.height
            
            if frame.minY < contentFrame.minY {
                frame.size.height = panOriginFrame.maxY - contentFrame.minY
                if let ratio = ratio { frame.size.width = ceil(frame.height * ratio) }
                frame.origin.y = panOriginFrame.maxY - frame.height
            }
            
            if frame.maxX > contentFrame.maxX {
                frame.size.width = contentFrame.maxX - panOriginFrame.minX
                if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
                frame.origin.y = panOriginFrame.maxY - frame.height
            }
            
            if let ratio = ratio {
                var minFrame = CGRect(x: panOriginFrame.origin.x,
                                      y: panOriginFrame.maxY - minSize.height,
                                      width: minSize.width,
                                      height: minSize.height)
                
                minFrame.size.height = minSize.width / ratio
                if minFrame.size.height < minSize.height {
                    minFrame.size.height = minSize.height
                    minFrame.size.width = ceil(minFrame.height * ratio)
                }
                minFrame.origin.y = panOriginFrame.maxY - minFrame.height
                
                if !frame.contains(minFrame) {
                    frame = minFrame
                }
            }
            
        case .bottomRight:
            frame.size.width = max(panOriginFrame.width + deltaX, minSize.width)
            frame.size.height = max(panOriginFrame.height + deltaY, minSize.height)
            if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
            
            if frame.maxX > contentFrame.maxX {
                frame.size.width = contentFrame.maxX - panOriginFrame.minX
                if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
            }
            
            if frame.maxY > contentFrame.maxY {
                frame.size.height = contentFrame.maxY - panOriginFrame.minY
                if let ratio = ratio { frame.size.width = ceil(frame.height * ratio) }
            }
            
            if let ratio = ratio {
                var minFrame = CGRect(x: panOriginFrame.origin.x,
                                      y: panOriginFrame.origin.y,
                                      width: minSize.width,
                                      height: minSize.height)
                
                minFrame.size.height = minSize.width / ratio
                if minFrame.size.height < minSize.height {
                    minFrame.size.height = minSize.height
                    minFrame.size.width = ceil(minFrame.height * ratio)
                }
                
                if !frame.contains(minFrame) {
                    frame = minFrame
                }
            }
            
        case .bottomLeft:
            frame.size.width = max(panOriginFrame.width - deltaX, minSize.width)
            frame.size.height = max(panOriginFrame.height + deltaY, minSize.height)
            if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
            frame.origin.x = panOriginFrame.maxX - frame.width
            
            if frame.minX < contentFrame.minX {
                frame.size.width = panOriginFrame.maxX - contentFrame.minX
                if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
                frame.origin.x = panOriginFrame.maxX - frame.width
            }
            
            if frame.maxY > contentFrame.maxY {
                frame.size.height = contentFrame.maxY - panOriginFrame.minY
                if let ratio = ratio { frame.size.width = ceil(frame.height * ratio) }
                frame.origin.x = panOriginFrame.maxX - frame.width
            }
            
            if let ratio = ratio {
                var minFrame = CGRect(x: panOriginFrame.maxX - minSize.width,
                                      y: panOriginFrame.origin.y,
                                      width: minSize.width,
                                      height: minSize.height)
                
                minFrame.size.height = ceil(minSize.width / ratio)
                if minFrame.size.height < minSize.height {
                    minFrame.size.height = minSize.height
                    minFrame.size.width = ceil(minFrame.height * ratio)
                }
                minFrame.origin.x = panOriginFrame.maxX - minFrame.width
                
                if !frame.contains(minFrame) {
                    frame = minFrame
                }
            }
        case .topLeft:
            frame.size.width = max(panOriginFrame.width - deltaX, minSize.width)
            frame.size.height = max(panOriginFrame.height - deltaY, minSize.height)
            if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
            frame.origin.x = panOriginFrame.maxX - frame.width
            frame.origin.y = panOriginFrame.maxY - frame.height
            
            if frame.minX < contentFrame.minX {
                frame.size.width = panOriginFrame.maxX - contentFrame.minX
                if let ratio = ratio { frame.size.height = ceil(frame.width / ratio) }
                frame.origin.x = panOriginFrame.maxX - frame.width
                frame.origin.y = panOriginFrame.maxY - frame.height
            }
            
            if frame.minY < contentFrame.minY {
                frame.size.height = panOriginFrame.maxY - contentFrame.minY
                if let ratio = ratio { frame.size.width = ceil(frame.height * ratio) }
                frame.origin.x = panOriginFrame.maxX - frame.width
                frame.origin.y = panOriginFrame.maxY - frame.height
            }
            
            if let ratio = ratio {
                var minFrame = CGRect(x: panOriginFrame.maxX - minSize.width,
                                      y: panOriginFrame.maxY - minSize.height,
                                      width: minSize.width,
                                      height: minSize.height)
                
                minFrame.size.height = ceil(minSize.width / ratio)
                if minFrame.size.height < minSize.height {
                    minFrame.size.height = minSize.height
                    minFrame.size.width = ceil(minFrame.height * ratio)
                }
                minFrame.origin.x = panOriginFrame.maxX - minFrame.width
                minFrame.origin.y = panOriginFrame.maxY - minFrame.height
                
                if !frame.contains(minFrame) {
                    frame = minFrame
                }
            }
            
        default:
            print("edge: undefined")
            return
        }
        
        self.frame = frame
        cropBoxControlChanged(frame)
    }
    
    public func edge(forPoint point: CGPoint) -> FMCropCropBoxEdge {
        let frame = self.frame.insetBy(dx: -32, dy: -32)
        
        let topLeftRect = CGRect(origin: frame.origin, size: CGSize(width: 64, height: 64))
        if topLeftRect.contains(point) { return .topLeft }
        
        let topRightRect = CGRect(origin: CGPoint(x: frame.maxX - 64, y: topLeftRect.origin.y), size: topLeftRect.size)
        if topRightRect.contains(point) { return .topRight }
        
        let bottomLeftRect = CGRect(origin: CGPoint(x: topLeftRect.origin.x, y: frame.maxY - 64), size: topLeftRect.size)
        if bottomLeftRect.contains(point) { return .bottomLeft }
        
        let bottomRightRect = CGRect(origin: CGPoint(x: topRightRect.origin.x, y: bottomLeftRect.origin.y), size: topLeftRect.size)
        if bottomRightRect.contains(point) { return .bottomRight }
        
        let topRect = CGRect(origin: frame.origin, size: CGSize(width: frame.width, height: 64))
        if topRect.contains(point) { return .top }
        
        let bottomRect = CGRect(origin: bottomLeftRect.origin, size: topRect.size)
        if bottomRect.contains(point) { return .bottom }
        
        let leftRect = CGRect(origin: topLeftRect.origin, size: CGSize(width: 64, height: frame.height))
        if leftRect.contains(point) { return .left }
        
        let rightRect = CGRect(origin: topRightRect.origin, size: leftRect.size)
        if rightRect.contains(point) { return .right }
        
        return .undefined
    }
}

extension FMCropCropBoxView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer != resizeGestureRecognizer { return true }
        
        let tapPoint = gestureRecognizer.location(in: self)
        
        let innerBound = bounds.insetBy(dx: 22, dy: 22)
        let outerBound = bounds.insetBy(dx: -22, dy: -22)
        
        if innerBound.contains(tapPoint) || !outerBound.contains(tapPoint) {
            return false
        }
        return true
    }
}
