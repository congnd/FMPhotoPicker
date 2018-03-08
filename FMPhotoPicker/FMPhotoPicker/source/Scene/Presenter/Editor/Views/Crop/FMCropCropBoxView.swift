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
    
    override var frame: CGRect {
        didSet {
            
        }
    }
    
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
    
    private var panOriginEdge: FMCropCropBoxEdge = .undefined
    private var panOriginPoint: CGPoint = .zero
    private var panOriginFrame: CGRect = .zero
    private var contentBound: CGRect = .zero
    private let minSize = CGSize(width: 100, height: 100)

    init() {
        super.init(frame: .zero)
        
        isUserInteractionEnabled = false
        
        layer.borderWidth = 6
        layer.borderColor = UIColor.brown.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func handleResizeGestrureRecognizer(recognizer: UIPanGestureRecognizer) {
        let tapPoint = recognizer.location(in: cropView)
        
        if recognizer.state == .began {
            panOriginEdge = self.edge(forPoint: tapPoint)
            panOriginPoint = tapPoint
            panOriginFrame = self.frame
            
            // TODO: It should be here?
            contentBound = cropView.contentBound
            
            cropBoxControlStarted()
        }
        
        if recognizer.state == .ended || recognizer.state == .cancelled {
            cropBoxControlEnded()
        }
        receivedResizeControlTouch(inPoint: tapPoint)
    }
    
    public func receivedResizeControlTouch(inPoint point: CGPoint) {
        let deltaX = (point.x - panOriginPoint.x)
        let deltaY = (point.y - panOriginPoint.y)
        
        var frame = self.frame

        
        switch panOriginEdge {
        case .top:
            frame = applyDriverEdgeTop(toRect: frame, deltaY: deltaY)
        case .right:
            frame = applyDriverEdgeRight(toRect: frame, deltaX: deltaX)
        case .bottom:
            frame = applyDriverEdgeBottom(toRect: frame, deltaY: deltaY)
        case .left:
            frame = applyDriverEdgeLeft(toRect: frame, deltaX: deltaX)
        case .topRight:
            frame = applyDriverEdgeTop(toRect: frame, deltaY: deltaY)
            frame = applyDriverEdgeRight(toRect: frame, deltaX: deltaX)
        case .bottomRight:
            frame = applyDriverEdgeBottom(toRect: frame, deltaY: deltaY)
            frame = applyDriverEdgeRight(toRect: frame, deltaX: deltaX)
        case .bottomLeft:
            frame = applyDriverEdgeBottom(toRect: frame, deltaY: deltaY)
            frame = applyDriverEdgeLeft(toRect: frame, deltaX: deltaX)
        case .topLeft:
            frame = applyDriverEdgeTop(toRect: frame, deltaY: deltaY)
            frame = applyDriverEdgeLeft(toRect: frame, deltaX: deltaX)
        default:
            print("edge: undefined")
            return
        }
        
        self.frame = frame
        cropBoxControlChanged(frame)
    }
    
    private func applyDriverEdgeTop(toRect rect: CGRect, deltaY: CGFloat) -> CGRect {
        var result = rect
        
        let posY = panOriginFrame.origin.y + deltaY
        result.origin.y = min(max(posY, contentBound.minY), result.maxY - minSize.height)
        
        result.size.height = panOriginFrame.height - (result.origin.y - panOriginFrame.origin.y)
        
        return result
    }
    
    private func applyDriverEdgeRight(toRect rect: CGRect, deltaX: CGFloat) -> CGRect {
        var result = rect
        
        let width = panOriginFrame.size.width + deltaX
        result.size.width = max(min(width, contentBound.maxX - panOriginFrame.minX), minSize.width)
        
        return result
    }
    
    private func applyDriverEdgeBottom(toRect rect: CGRect, deltaY: CGFloat) -> CGRect {
        var result = rect
        
        let height = panOriginFrame.size.height + deltaY
        result.size.height = max(min(height, contentBound.maxY - panOriginFrame.minY), minSize.height)
        
        return result
    }
    
    private func applyDriverEdgeLeft(toRect rect: CGRect, deltaX: CGFloat) -> CGRect {
        var result = rect
        
        let posX = panOriginFrame.origin.x + deltaX
        result.origin.x = min(max(posX, contentBound.minX), result.maxX - minSize.width)
        
        result.size.width = panOriginFrame.width - (result.origin.x - panOriginFrame.origin.x)
        
        return result
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
