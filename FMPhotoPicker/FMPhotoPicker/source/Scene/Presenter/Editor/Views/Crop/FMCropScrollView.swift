//
//  FMCropScrollView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/05.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMCropScrollView: UIScrollView {
//    public let backgroundView: FMCropBackgroundView
    
    public let imageView: UIImageView
    public var touchesBegan: () -> Void = {}
    public var touchesEnded: () -> Void = {}
    public var touchesCancelled: () -> Void = {}
    
    override var frame: CGRect {
        didSet {
            updateZoomScale()
            centerScrollViewContents()
        }
    }
    
    public var isCropping: Bool = false {
        didSet {
            panGestureRecognizer.isEnabled = isCropping
            pinchGestureRecognizer?.isEnabled = isCropping
        }
    }
    
    lazy private(set) var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTapWithGestureRecognizer(_:)))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()
    
    init(image: UIImage) {
        imageView = UIImageView()
        super.init(frame: .zero)
        
        let size = image.size
        imageView.image = image
        imageView.frame = CGRect(origin: .zero, size: size)
        self.addSubview(imageView)
        
        self.contentSize = size
        self.zoomScale = 0.5
        
        self.addGestureRecognizer(doubleTapGestureRecognizer)
        
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false;
        bouncesZoom = true;
        decelerationRate = UIScrollView.DecelerationRate.fast;
        
        if #available(iOS 11.0, *) {
            contentInsetAdjustmentBehavior = .never
        }
        
        backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func updateZoomScale() {
        if let image = imageView.image {
            let scrollViewFrame = self.bounds
            let scaleWidth = scrollViewFrame.size.width / image.size.width
            let scaleHeight = scrollViewFrame.size.height / image.size.height
            let minimumScale = min(scaleWidth, scaleHeight)
            
//            self.minimumZoomScale = minimumScale
//            self.maximumZoomScale = max(minimumScale, self.maximumZoomScale)
            
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
//            self.panGestureRecognizer.isEnabled = false
        }
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
        
        if let window = window, window.screen.scale < 2.0 {
            horizontalInset = floor(horizontalInset);
            verticalInset = floor(verticalInset);
        }
        
        // Use `contentInset` to center the contents in the scroll view. Reasoning explained here: http://petersteinberger.com/blog/2013/how-to-center-uiscrollview/
        self.contentInset = UIEdgeInsets(top: verticalInset, left: horizontalInset, bottom: verticalInset, right: horizontalInset);
    }
    
    // MARK: - Logic
    @objc private func handleDoubleTapWithGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
        guard isCropping == true else { return }
        
        let pointInView = recognizer.location(in: self.imageView)
        var newZoomScale = self.maximumZoomScale
        
        if self.zoomScale >= self.maximumZoomScale || abs(self.zoomScale - self.maximumZoomScale) <= 0.01 {
            newZoomScale = self.minimumZoomScale
        }
        
        let scrollViewSize = self.bounds.size
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let originX = pointInView.x - (width / 2.0)
        let originY = pointInView.y - (height / 2.0)
        
        let rectToZoom = CGRect(x: originX, y: originY, width: width, height: height)
        self.zoom(to: rectToZoom, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesBegan()
        super.touchesBegan(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesEnded()
        super.touchesEnded(touches, with: event)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        touchesCancelled()
        super.touchesCancelled(touches, with: event)
    }
}
