//
//  FMCropView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/05.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMCropView: UIView {

    public let scrollView: FMCropScrollView
    private let cropBoxView: FMCropCropBoxView
    public let foregroundView: FMCropForegroundView
    
    private let translucencyView: FMCropTranslucencyView
    
    lazy public var contentFrame: CGRect = {
        return bounds.insetBy(dx: 20, dy: 60)
    }()
    
    private var centerCropBoxTimer: Timer?
    private let cornersView: FMCropCropBoxCornersView
    
    public var cropName: FMCropName = .ratioOrigin {
        didSet {
            moveCroppedContentToCenterAnimated()
            cropBoxView.cropName = cropName
        }
    }
    
    private var image: UIImage
    
    override var frame: CGRect {
        didSet {
            if frame.equalTo(scrollView.frame) { return }
            scrollView.frame = frame
            foregroundView.frame = scrollView.convert(scrollView.imageView.frame, to: self)
            cropBoxView.frame = foregroundView.frame
            cornersView.frame = foregroundView.frame
            matchForegroundToBackground()
        }
    }

    init() {
        image = UIImage(named: "file0001176452626.jpg", in: Bundle(for: FMCropView.self), compatibleWith: nil)!
        
        scrollView = FMCropScrollView(image: image)
        cropBoxView = FMCropCropBoxView(cropName: cropName)
        foregroundView = FMCropForegroundView(image: image)
        translucencyView = FMCropTranslucencyView(effect: UIBlurEffect(style: .light))
        
        cornersView = FMCropCropBoxCornersView()
        
        super.init(frame: .zero)
        
        cropBoxView.cropView = self
        cropBoxView.cropBoxControlChanged = { [unowned self] rect in
            self.cropboxViewFrameDidChange(rect: rect)
        }
        cropBoxView.cropBoxControlEnded = { [unowned self] in
            self.cropBoxControlDidEnd()
        }
        cropBoxView.cropBoxControlStarted = { [unowned self] in
            self.cropBoxControlDidStart()
        }
        
        addSubview(scrollView)
        scrollView.delegate = self
        
        scrollView.touchesBegan = { [unowned self] in
            self.translucencyView.safetyHide()
        }
        
        scrollView.touchesEnded = { [unowned self] in
            self.translucencyView.scheduleShowing()
        }
        
        scrollView.touchesCancelled = { [unowned self] in
            self.translucencyView.scheduleShowing()
        }
        
        translucencyView.insert(toView: self)
        translucencyView.isUserInteractionEnabled = false
        
        addSubview(foregroundView)
        addSubview(cropBoxView)
        addSubview(cornersView)
        
        self.backgroundColor = .white
        
        let btn = UIButton(frame: CGRect(x: 0, y: 40, width: 160, height: 40))
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(testMove), for: .touchUpInside)
        btn.setTitle("Show/Hide Blur", for: .normal)
        self.addSubview(btn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func matchForegroundToBackground() {
        foregroundView.imageView.frame = scrollView.convert(scrollView.imageView.frame, to: foregroundView)
    }
    
    @objc private func testMove() {
        translucencyView.isHidden = !translucencyView.isHidden
    }
    
    public func moveCropBoxToAspectFillContentFrame() {
        // correct minimumZoomScale before moving
        scrollView.minimumZoomScale *= min(contentFrame.width / cropBoxView.frame.width, contentFrame.height / cropBoxView.frame.height)
        
        moveCroppedContentToCenterAnimated()
    }
    
    private func moveCroppedContentToCenterAnimated() {
        var cropFrame = cropBoxView.frame
        let cropRatio = cropName.ratio()
        
        //The scale we need to scale up the crop box to fit full screen
        let cropBoxScale = min(contentFrame.width / cropFrame.width, contentFrame.height / cropFrame.height)
        
        // center point of cropBoxView in CropView coordination system
        let originFocusPointInCropViewCoordination = CGPoint(x: cropBoxView.frame.midX, y: cropBoxView.frame.midY)
        
        if cropName == .ratioOrigin {
            let ratio = image.size.height / image.size.width
            
            // correct ratio only
            cropFrame.size.height = cropFrame.size.width * ratio
        } else if let cropRatio = cropRatio {
            let ratio = CGFloat(cropRatio.height) / CGFloat(cropRatio.width)
            
            // correct ratio only
            cropFrame.size.height = cropFrame.size.width * ratio
        }
        
        // calculate new cropFrame that is translated to center of contentBound
        cropFrame.size.width = ceil(cropFrame.size.width * cropBoxScale)
        cropFrame.size.height = ceil(cropFrame.size.height * cropBoxScale)
        cropFrame.origin.x = contentFrame.origin.x + ceil(contentFrame.size.width - cropFrame.size.width) * 0.5
        cropFrame.origin.y = contentFrame.origin.y + ceil(contentFrame.size.height - cropFrame.size.height) * 0.5
        
        let scrollViewScale = min(cropBoxScale, scrollView.maximumZoomScale / scrollView.zoomScale)
        
        let originForcusPointInScrollContentViewCoordination = CGPoint(x: originFocusPointInCropViewCoordination.x + scrollView.contentOffset.x,
                                                                       y: originFocusPointInCropViewCoordination.y + scrollView.contentOffset.y)
        let targetForcusPointInScrollContentViewCoordination = CGPoint(x: originForcusPointInScrollContentViewCoordination.x * scrollViewScale,
                                                                       y: originForcusPointInScrollContentViewCoordination.y * scrollViewScale)
        
        let targetOffset = CGPoint(x: targetForcusPointInScrollContentViewCoordination.x - contentFrame.midX,
                             y: targetForcusPointInScrollContentViewCoordination.y - contentFrame.midY)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.scrollView.zoomScale *= scrollViewScale
                        self.scrollView.contentOffset = targetOffset
                        self.cropBoxView.frame = cropFrame
                        self.cropboxViewFrameDidChange(rect: cropFrame)
        },
                       completion: { _ in
                        self.translucencyView.safetyShow()
        })
    }
    
    private func cropboxViewFrameDidChange(rect: CGRect) {
        foregroundView.frame = rect
        cornersView.frame = rect
        matchForegroundToBackground()
        
        scrollView.contentInset = UIEdgeInsets(top: rect.minY, left: rect.minX, bottom: self.bounds.maxY - rect.maxY, right: self.bounds.maxX - rect.maxX)
        
        let scale = max(rect.size.height / image.size.height, rect.size.width / image.size.width);
        scrollView.minimumZoomScale = scale;
        
//        var size = scrollView.contentSize
//        size.width = floor(size.width)
//        size.height = floor(size.height)
//        scrollView.contentSize = size
        
        // Forece scrollview to update its content after changing the minimumZoomScale
        scrollView.zoomScale = self.scrollView.zoomScale
    }
    
    private func cropBoxControlDidEnd() {
        resetCropBoxTimer()
    }
    
    private func cropBoxControlDidStart() {
        invalidateCropBoxTimer()
        translucencyView.safetyHide()
    }
    
    // MARK: - Timer
    private func resetCropBoxTimer() {
        invalidateCropBoxTimer()
        startCropBoxTimer()
    }
    
    private func startCropBoxTimer() {
        centerCropBoxTimer = Timer.scheduledTimer(timeInterval: 0.8,
                                                  target: self,
                                                  selector: #selector(timerTrigged),
                                                  userInfo: nil,
                                                  repeats: false)
    }
    
    private func invalidateCropBoxTimer() {
        centerCropBoxTimer?.invalidate()
        centerCropBoxTimer = nil
    }
    
    @objc private func timerTrigged() {
        moveCroppedContentToCenterAnimated()
    }
}

extension FMCropView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scrollView.imageView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        matchForegroundToBackground()
        translucencyView.safetyHide()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        matchForegroundToBackground()
        translucencyView.safetyHide()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        translucencyView.scheduleShowing()
    }

    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            translucencyView.scheduleShowing()
        }
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        translucencyView.scheduleShowing()
    }
}
