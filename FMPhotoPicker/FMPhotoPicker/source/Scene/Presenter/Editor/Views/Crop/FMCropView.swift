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
        
        scrollView = FMCropScrollView(image: testImage)
        cropBoxView = FMCropCropBoxView()
        foregroundView = FMCropForegroundView(image: testImage)
        translucencyView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        
        super.init(frame: .zero)
        
        cropBoxView.cropView = self
        cropBoxView.cropBoxDidChange = { [unowned self] rect in
            self.foregroundView.frame = rect
            self.matchForegroundToBackground()
        }
        addSubview(scrollView)
        scrollView.delegate = self
        
        translucencyView.insert(toView: self)
        translucencyView.isUserInteractionEnabled = false
        
        addSubview(foregroundView)
        addSubview(cropBoxView)
        
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func matchForegroundToBackground() {
        foregroundView.imageView.frame = scrollView.convert(scrollView.imageView.frame, to: foregroundView)
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
