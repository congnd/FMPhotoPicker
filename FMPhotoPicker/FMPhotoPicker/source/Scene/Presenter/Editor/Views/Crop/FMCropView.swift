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
    
    private let translucencyView: UIVisualEffectView
    
    lazy public var contentBound: CGRect = { return bounds.insetBy(dx: 20, dy: 60) }()
    
    private var testImageSize: CGSize
    private var centerCropBoxTimer: Timer?
    private let cornersView: FMCropCropBoxCornersView
    
    override var frame: CGRect {
        didSet {
            scrollView.frame = frame
            foregroundView.frame = scrollView.convert(scrollView.imageView.frame, to: self)
            cropBoxView.frame = foregroundView.frame
            matchForegroundToBackground()
        }
    }

    init() {
        let testImage = UIImage(named: "file0001176452626.jpg", in: Bundle(for: FMCropView.self), compatibleWith: nil)!
        testImageSize = testImage.size
        
        scrollView = FMCropScrollView(image: testImage)
        cropBoxView = FMCropCropBoxView()
        foregroundView = FMCropForegroundView(image: testImage)
        translucencyView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        
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
        
        translucencyView.insert(toView: self)
        translucencyView.isUserInteractionEnabled = false
        
        addSubview(foregroundView)
        addSubview(cropBoxView)
        addSubview(cornersView)
        
        self.backgroundColor = .white
        
        let btn = UIButton(frame: CGRect(x: 0, y: 40, width: 100, height: 40))
        btn.backgroundColor = .red
        btn.addTarget(self, action: #selector(testMove), for: .touchUpInside)
        btn.setTitle("test move", for: .normal)
        self.addSubview(btn)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func matchForegroundToBackground() {
        foregroundView.imageView.frame = scrollView.convert(scrollView.imageView.frame, to: foregroundView)
    }
    
    @objc private func testMove() {
        moveCroppedContentToCenterAnimated()
    }
    
    private func moveCroppedContentToCenterAnimated() {
        var cropFrame = cropBoxView.frame
        
        //The scale we need to scale up the crop box to fit full screen
        let cropBoxScale = min(contentBound.width / cropFrame.width, contentBound.height / cropFrame.height)
        
        // center point of cropBoxView in CropView coordination system
        let originFocusPointInCropViewCoordination = CGPoint(x: cropBoxView.frame.midX, y: cropBoxView.frame.midY)
        
        // calculate new cropFrame that is translated to center of contentBound
        cropFrame.size.width = ceil(cropFrame.size.width * cropBoxScale)
        cropFrame.size.height = ceil(cropFrame.size.height * cropBoxScale)
        cropFrame.origin.x = contentBound.origin.x + ceil(contentBound.size.width - cropFrame.size.width) * 0.5
        cropFrame.origin.y = contentBound.origin.y + ceil(contentBound.size.height - cropFrame.size.height) * 0.5
        
        let scrollViewScale = min(cropBoxScale, scrollView.maximumZoomScale / scrollView.zoomScale)
        
        let originForcusPointInScrollContentViewCoordination = CGPoint(x: originFocusPointInCropViewCoordination.x + scrollView.contentOffset.x,
                                                                       y: originFocusPointInCropViewCoordination.y + scrollView.contentOffset.y)
        let targetForcusPointInScrollContentViewCoordination = CGPoint(x: originForcusPointInScrollContentViewCoordination.x * scrollViewScale,
                                                                       y: originForcusPointInScrollContentViewCoordination.y * scrollViewScale)
        
        let targetOffset = CGPoint(x: targetForcusPointInScrollContentViewCoordination.x - contentBound.midX,
                             y: targetForcusPointInScrollContentViewCoordination.y - contentBound.midY)
        
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
                        self.showTranslucentView()
        })
    }
    
    private func cropboxViewFrameDidChange(rect: CGRect) {
        foregroundView.frame = rect
        cornersView.frame = rect
        matchForegroundToBackground()
        
        scrollView.contentInset = UIEdgeInsets(top: rect.minY, left: rect.minX, bottom: self.bounds.maxY - rect.maxY, right: self.bounds.maxX - rect.maxX)
        
        let scale = max(rect.size.height / testImageSize.height, rect.size.width / testImageSize.width);
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
        hideTranslucentView()
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
    }
    
    @objc private func timerTrigged() {
        moveCroppedContentToCenterAnimated()
    }
    
    // MARK: - show/hide translucent view
    private func showTranslucentView() {
        self.translucencyView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.375, animations: {
            self.translucencyView.alpha = 1
        })
    }
    
    private func hideTranslucentView() {
        self.translucencyView.layer.removeAllAnimations()
        UIView.animate(withDuration: 0.2, animations: {
            self.translucencyView.alpha = 0.5
        })
    }
}

extension FMCropView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scrollView.imageView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        matchForegroundToBackground()
        hideTranslucentView()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        matchForegroundToBackground()
        hideTranslucentView()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        showTranslucentView()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        showTranslucentView()
    }
}
