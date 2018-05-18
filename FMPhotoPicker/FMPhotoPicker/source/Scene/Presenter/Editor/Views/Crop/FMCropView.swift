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
    
    public var contentFrame: CGRect = .zero
    
    private var centerCropBoxTimer: Timer?
    private let cornersView: FMCropCropBoxCornersView
    private let whiteBackgroundView: UIView
    
    public var crop: FMCroppable {
        didSet {
            moveCroppedContentToCenterAnimated()
            cropBoxView.cropRatio = cropRatio(forCrop: crop)
        }
    }
    
    private var cropArea: FMCropArea?
    lazy private var zoomScale: CGFloat? = {
        guard let cropArea = cropArea else { return nil }
        let contentFrameSizeRatio = contentFrame.width / contentFrame.height
        let cropBoxSizeRatio = cropArea.scaleW / cropArea.scaleH * (image.size.width / image.size.height)
        
        if contentFrameSizeRatio > cropBoxSizeRatio {
            return contentFrame.height / (cropArea.scaleH * image.size.height)
        } else {
            return contentFrame.width / (cropArea.scaleW * image.size.width)
        }
    }()
    
    public var isCropping: Bool = false {
        didSet {
            cropBoxView.isCropping = isCropping
            scrollView.isCropping = isCropping
            if isCropping {
                whiteBackgroundView.isHidden = true
                cornersView.isHidden = false
            } else {
                whiteBackgroundView.isHidden = false
                cornersView.isHidden = true
            }
        }
    }
    
    public var image: UIImage {
        didSet {
            scrollView.imageView.image = image
            foregroundView.imageView.image = image
        }
    }
    
    override var frame: CGRect {
        didSet {
            if frame.equalTo(scrollView.frame) { return }
            scrollView.frame = frame
            foregroundView.frame = scrollView.convert(scrollView.imageView.frame, to: self)
            cropBoxView.frame = foregroundView.frame
            cornersView.frame = foregroundView.frame
            whiteBackgroundView.frame = frame
            matchForegroundToBackground()
        }
    }

    init(image: UIImage, appliedCrop: FMCroppable, appliedCropArea: FMCropArea?) {
        self.image = image

        crop = appliedCrop
        cropArea = appliedCropArea
        
        scrollView = FMCropScrollView(image: image)
        
        cropBoxView = FMCropCropBoxView(cropRatio: nil)
        
        foregroundView = FMCropForegroundView(image: image)
        translucencyView = FMCropTranslucencyView(effect: UIBlurEffect(style: .light))
        
        cornersView = FMCropCropBoxCornersView()
        
        whiteBackgroundView = UIView()
        whiteBackgroundView.backgroundColor = kBackgroundColor
        whiteBackgroundView.isUserInteractionEnabled = false
        
        super.init(frame: .zero)
        
        cropBoxView.cropRatio = cropRatio(forCrop: crop)
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
        
        addSubview(whiteBackgroundView)
        addSubview(foregroundView)
        addSubview(cropBoxView)
        addSubview(cornersView)
        
        self.backgroundColor = .white
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
    
    public func moveCropBoxToAspectFillContentFrame(complete: (() -> Void)? = nil) {
        // correct minimumZoomScale before moving
        scrollView.minimumZoomScale *= min(contentFrame.width / cropBoxView.frame.width, contentFrame.height / cropBoxView.frame.height)
        
        moveCroppedContentToCenterAnimated(complete: complete)
    }
    
    public func restoreFromPreviousEdittingSection() {
        guard let cropArea = cropArea, let zoomScale = zoomScale else { return }
        
        // check for previous section data
        var cropFrame = cropBoxView.frame
        
        // use for first time only
        let scrollViewScale = zoomScale / scrollView.zoomScale
        
        cropFrame.size.width = (scrollView.imageView.frame.width / scrollView.zoomScale * cropArea.scaleW * zoomScale)
        cropFrame.size.height = (scrollView.imageView.frame.height / scrollView.zoomScale * cropArea.scaleH * zoomScale)
        
        //The scale we need to scale up the crop box to fit full screen
        let cropBoxScale = min(contentFrame.width / cropFrame.width, contentFrame.height / cropFrame.height)
        cropFrame.size.width = (cropFrame.size.width * cropBoxScale)
        cropFrame.size.height = (cropFrame.size.height * cropBoxScale)
        
        cropFrame.origin.x = contentFrame.origin.x + (contentFrame.size.width - cropFrame.size.width) * 0.5
        cropFrame.origin.y = contentFrame.origin.y + (contentFrame.size.height - cropFrame.size.height) * 0.5
        
        let targetOffset = CGPoint(x: (scrollView.imageView.frame.width / scrollView.zoomScale * zoomScale * cropArea.scaleX) - cropFrame.minX,
                               y: (scrollView.imageView.frame.height / scrollView.zoomScale * zoomScale * cropArea.scaleY) - cropFrame.minY)
        
        scrollView.zoomScale *= scrollViewScale
        scrollView.contentOffset = targetOffset
        cropBoxView.frame = cropFrame
        cropboxViewFrameDidChange(rect: cropFrame)
    }
    
    private func moveCroppedContentToCenterAnimated(complete: (() -> Void)? = nil) {
        var cropFrame = cropBoxView.frame
        let cropRatio = crop.ratio()
        
        var scrollViewScale: CGFloat
        let targetOffset: CGPoint
        
        // center point of cropBoxView in CropView coordination system
        let originFocusPointInCropViewCoordination = CGPoint(x: cropBoxView.frame.midX, y: cropBoxView.frame.midY)
        
        if (crop as? FMCrop) == .ratioOrigin {
            let ratio = image.size.height / image.size.width
            
            // correct ratio only
            cropFrame.size.height = cropFrame.size.width * ratio
        } else if let cropRatio = cropRatio {
            let ratio = CGFloat(cropRatio.height) / CGFloat(cropRatio.width)
            
            // correct ratio only
            cropFrame.size.height = cropFrame.size.width * ratio
        }
        
        //The scale we need to scale up the crop box to fit full screen
        let cropBoxScale = min(contentFrame.width / cropFrame.width, contentFrame.height / cropFrame.height) 
        
        // calculate new cropFrame that is translated to center of contentBound
        cropFrame.size.width = cropFrame.size.width * cropBoxScale
        cropFrame.size.height = cropFrame.size.height * cropBoxScale
        cropFrame.origin.x = contentFrame.origin.x + (contentFrame.size.width - cropFrame.size.width) * 0.5
        cropFrame.origin.y = contentFrame.origin.y + (contentFrame.size.height - cropFrame.size.height) * 0.5
        
        scrollViewScale = min(cropBoxScale, scrollView.maximumZoomScale / scrollView.zoomScale)

        let originForcusPointInScrollContentViewCoordination = CGPoint(x: originFocusPointInCropViewCoordination.x + scrollView.contentOffset.x,
                                                                       y: originFocusPointInCropViewCoordination.y + scrollView.contentOffset.y)
        let targetForcusPointInScrollContentViewCoordination = CGPoint(x: originForcusPointInScrollContentViewCoordination.x * scrollViewScale,
                                                                       y: originForcusPointInScrollContentViewCoordination.y * scrollViewScale)
        
        targetOffset = CGPoint(x: targetForcusPointInScrollContentViewCoordination.x - contentFrame.midX,
                               y: targetForcusPointInScrollContentViewCoordination.y - contentFrame.midY)
        
        UIView.animate(withDuration: kComplexAnimationDuration,
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
                        complete?()
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
    
    private func cropRatio(forCrop crop: FMCroppable) -> FMCropRatio? {
        if (crop as? FMCrop) == .ratioOrigin {
            return FMCropRatio(width: image.size.width, height: image.size.height)
        }
        return crop.ratio()
    }
    
    public func getCroppedThumbImage() -> UIImage {
        return foregroundView.getViewableCompareView().resize(toSizeInPixel: kFilterPreviewImageSize)
    }
    
    public func resetAll() {
        let imageRatio = image.size.width / image.size.height
        resetCropFrame(to: imageRatio)
    }
    
    public func resetFrameWithoutChangeRatio() {
        guard let fmCropRatio = crop.ratio() else { return }
        let cropRatio = fmCropRatio.width / fmCropRatio.height
        
        resetCropFrame(to: cropRatio)
    }
    
    private func resetCropFrame(to cropRatio: CGFloat) {
        let contentFrameRatio = contentFrame.width / contentFrame.height
        var cropFrame: CGRect = .zero
        if cropRatio > contentFrameRatio {
            cropFrame.size.width = contentFrame.width
            cropFrame.size.height = cropFrame.width / cropRatio
        } else {
            cropFrame.size.height = contentFrame.height
            cropFrame.size.width = cropFrame.height * cropRatio
        }
        cropFrame.origin = CGPoint(x: (contentFrame.width - cropFrame.width) / 2 + contentFrame.origin.x,
                                   y: (contentFrame.height - cropFrame.height) / 2 + contentFrame.origin.y)
        
        let targetZoomScale = max(cropFrame.width / image.size.width, cropFrame.height / image.size.height)
        let targetContentOffset = CGPoint(x: -cropFrame.origin.x + (image.size.width * targetZoomScale - cropFrame.width) / 2,
                                          y: -cropFrame.origin.y + (image.size.height * targetZoomScale - cropFrame.height) / 2)
        
        scrollView.minimumZoomScale = targetZoomScale
        
        UIView.animate(withDuration: kComplexAnimationDuration,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.scrollView.zoomScale = targetZoomScale
                        self.scrollView.contentOffset = targetContentOffset
                        self.cropBoxView.frame = cropFrame
                        self.cropboxViewFrameDidChange(rect: cropFrame)
        },
                       completion: { _ in
                        self.translucencyView.safetyShow()
        })
    }
    
    public func rotate() {
        
    }
    
    public func getCropArea() -> FMCropArea {
        let scaleX = (cropBoxView.frame.minX + scrollView.contentOffset.x) / scrollView.contentSize.width
        let scaleY = (cropBoxView.frame.minY + scrollView.contentOffset.y) / scrollView.contentSize.height
        let scaleW = cropBoxView.frame.width / scrollView.contentSize.width
        let scaleH = cropBoxView.frame.height / scrollView.contentSize.height
        
        return FMCropArea(scaleX: scaleX, scaleY: scaleY, scaleW: scaleW, scaleH: scaleH)
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
