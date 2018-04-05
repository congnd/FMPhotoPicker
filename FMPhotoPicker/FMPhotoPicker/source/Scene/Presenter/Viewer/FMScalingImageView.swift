//
//  FMScalingImageView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/29.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}


class FMScalingImageView: UIScrollView {
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        return imageView
    }()
    
    var image: UIImage? {
        didSet {
            if let image = image {
                updateImage(image)
            }
        }
    }
    
    var eclipsePreviewEnabled = false
    
    override var frame: CGRect {
        didSet {
            updateZoomScale()
            centerScrollViewContents()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.layer.masksToBounds = true
        setupImageScrollView()
        updateZoomScale()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImageScrollView()
        updateZoomScale()
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        centerScrollViewContents()
    }
    
    private func setupImageScrollView() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false;
        bouncesZoom = true;
        decelerationRate = UIScrollViewDecelerationRateFast;
    }
    
    func centerScrollViewContents() {
        var horizontalInset: CGFloat = 0;
        var verticalInset: CGFloat = 0;
        
        if (contentSize.width < bounds.width) {
            horizontalInset = (bounds.width - contentSize.width) * 0.5;
        }
        
        if (self.contentSize.height < bounds.height) {
            verticalInset = (bounds.height - contentSize.height) * 0.5;
        }
        
        if (window?.screen.scale < 2.0) {
            horizontalInset = floor(horizontalInset);
            verticalInset = floor(verticalInset);
        }
        
        // Use `contentInset` to center the contents in the scroll view. Reasoning explained here: http://petersteinberger.com/blog/2013/how-to-center-uiscrollview/
        self.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
    }
    
    private func updateImage(_ image: UIImage) {
        imageView.transform = CGAffineTransform.identity
        imageView.image = image
        imageView.frame = CGRect(origin: CGPoint.zero, size: image.size)
        self.contentSize = image.size
        
        updateZoomScale()
        centerScrollViewContents()
        
        if eclipsePreviewEnabled {
            imageView.layer.cornerRadius = image.size.width / 2
        }
    }
    
    private func updateZoomScale() {
        if let image = imageView.image {
            let scrollViewFrame = self.bounds
            let scaleWidth = scrollViewFrame.size.width / image.size.width
            let scaleHeight = scrollViewFrame.size.height / image.size.height
            let minimumScale = min(scaleWidth, scaleHeight)
            
            self.minimumZoomScale = minimumScale
            
            if minimumScale > 1 {
                self.maximumZoomScale = minimumScale
            } else {
                self.maximumZoomScale = min(1, minimumScale * 3)
            }
            
            self.zoomScale = minimumZoomScale
            
            // scrollView.panGestureRecognizer.enabled is on by default and enabled by
            // viewWillLayoutSubviews in the container controller so disable it here
            // to prevent an interference with the container controller's pan gesture.
            //
            // This is enabled in scrollViewWillBeginZooming so panning while zoomed-in
            // is unaffected.
            self.panGestureRecognizer.isEnabled = false
        }
    }
}
