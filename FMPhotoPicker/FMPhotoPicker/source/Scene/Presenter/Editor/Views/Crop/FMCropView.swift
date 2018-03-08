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
    
    lazy public var contentBound: CGRect = { return bounds.insetBy(dx: 30, dy: 70) }()
    
    private var testImageSize: CGSize
    
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
        
        super.init(frame: .zero)
        
        cropBoxView.cropView = self
        cropBoxView.cropBoxDidChange = { [unowned self] rect in
            self.cropboxViewFrameDidChange(rect: rect)
        }
        addSubview(scrollView)
        scrollView.delegate = self
        
        translucencyView.insert(toView: self)
        translucencyView.isUserInteractionEnabled = false
        
        addSubview(foregroundView)
        addSubview(cropBoxView)
        
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
        let scale = min(contentBound.width / cropFrame.width, contentBound.height / cropFrame.height)
        
        // center point of cropBoxView in CropView coordination system
        let originFocusPointInCropViewCoordination = CGPoint(x: cropBoxView.frame.midX, y: cropBoxView.frame.midY)
        
        // calculate new cropFrame that is translated to center of contentBound
        cropFrame.size.width = ceil(cropFrame.size.width * scale)
        cropFrame.size.height = ceil(cropFrame.size.height * scale)
        cropFrame.origin.x = contentBound.origin.x + ceil(contentBound.size.width - cropFrame.size.width) * 0.5
        cropFrame.origin.y = contentBound.origin.y + ceil(contentBound.size.height - cropFrame.size.height) * 0.5
        
        
        let originForcusPointInScrollContentViewCoordination = CGPoint(x: originFocusPointInCropViewCoordination.x + scrollView.contentOffset.x,
                                                                       y: originFocusPointInCropViewCoordination.y + scrollView.contentOffset.y)
        let targetForcusPointInScrollContentViewCoordination = CGPoint(x: originForcusPointInScrollContentViewCoordination.x * scale,
                                                                       y: originForcusPointInScrollContentViewCoordination.y * scale)
        
        let targetOffset = CGPoint(x: targetForcusPointInScrollContentViewCoordination.x - contentBound.midX,
                             y: targetForcusPointInScrollContentViewCoordination.y - contentBound.midY)
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 1.0,
                       options: .beginFromCurrentState,
                       animations: {
                        self.scrollView.zoomScale *= scale
                        self.scrollView.contentOffset = targetOffset
                        self.cropBoxView.frame = cropFrame
                        self.foregroundView.frame = cropFrame
                        self.matchForegroundToBackground()
        },
                       completion: { complete in
                        self.cropboxViewFrameDidChange(rect: cropFrame)
        })
    }
    
    private func cropboxViewFrameDidChange(rect: CGRect) {
        foregroundView.frame = rect
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
}

extension FMCropView: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scrollView.imageView
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        matchForegroundToBackground()
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        matchForegroundToBackground()
    }
    
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        
    }
}
