//
//  FMImageViewController.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/21.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMImageViewController: FMPhotoViewController {
    // MARK: - Public
    public var scalingImageView: FMScalingImageView!
    public var smallImage: UIImage?
    
    // the full size image with filter applied
    public var filteredImage: UIImage?
    
    // MARK: - Private
    lazy private(set) var doubleTapGestureRecognizer: UITapGestureRecognizer = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(FMImageViewController.handleDoubleTapWithGestureRecognizer(_:)))
        gesture.numberOfTapsRequired = 2
        return gesture
    }()

    deinit {
        self.photo.cancelAllRequest()
    }
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scalingImageView = FMScalingImageView(frame: self.view.frame)
        self.scalingImageView.delegate = self
        
        self.scalingImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scalingImageView.clipsToBounds = true
        self.scalingImageView.eclipsePreviewEnabled = config.eclipsePreviewEnabled
        
        self.view.addSubview(self.scalingImageView)
        
        self.photo.requestThumb() { image in
            self.smallImage = image
            self.scalingImageView.image = image
        }
        
        view.addGestureRecognizer(doubleTapGestureRecognizer)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        reloadPhoto() {}
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.photo.cancelAllRequest()
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scalingImageView.frame = view.bounds
    }
    
    // MARK: - Scroll delegate
    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.panGestureRecognizer.isEnabled = true
    }
    
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // There is a bug, especially prevalent on iPhone 6 Plus, that causes zooming to render all other gesture recognizers ineffective.
        // This bug is fixed by disabling the pan gesture recognizer of the scroll view when it is not needed.
        if (scrollView.zoomScale == scrollView.minimumZoomScale) {
            scrollView.panGestureRecognizer.isEnabled = false;
        }
    }
    
    // MARK: - Logic
    @objc private func handleDoubleTapWithGestureRecognizer(_ recognizer: UITapGestureRecognizer) {
        let pointInView = recognizer.location(in: scalingImageView.imageView)
        var newZoomScale = scalingImageView.maximumZoomScale
        
        if scalingImageView.zoomScale >= scalingImageView.maximumZoomScale || abs(scalingImageView.zoomScale - scalingImageView.maximumZoomScale) <= 0.01 {
            newZoomScale = scalingImageView.minimumZoomScale
        }
        
        let scrollViewSize = scalingImageView.bounds.size
        let width = scrollViewSize.width / newZoomScale
        let height = scrollViewSize.height / newZoomScale
        let originX = pointInView.x - (width / 2.0)
        let originY = pointInView.y - (height / 2.0)
        
        let rectToZoom = CGRect(x: originX, y: originY, width: width, height: height)
        scalingImageView.zoom(to: rectToZoom, animated: true)
    }
    
    override func viewToSnapshot() -> UIView {
        return self.scalingImageView.imageView
    }
    
    override func displayingImage() -> UIImage? {
        return self.scalingImageView.image
    }

    override func getFilteredImage() -> UIImage? {
        return filteredImage
    }
    
    override func thumbImage() -> UIImage? {
        return self.smallImage
    }
    
    override func reloadPhoto(complete: @escaping () -> Void) {
        self.photo.requestFullSizePhoto(cropState: .edited, filterState: .edited) { [weak self] image in
            guard let strongSelf = self,
                let image = image else { return complete() }
            strongSelf.scalingImageView.image = image
            complete()
        }
        
        // get filtered image
        // prepare to show in edit screen
        self.photo.requestFullSizePhoto(cropState: .original, filterState: .edited) { [weak self] image in
            guard let strongSelf = self,
                let image = image else { return }
            
            strongSelf.filteredImage = image
        }
    }
}

extension FMImageViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scalingImageView.imageView
    }
}
