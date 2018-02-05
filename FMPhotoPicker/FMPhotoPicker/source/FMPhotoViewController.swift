//
//  FMPhotoViewController.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/29.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
import Photos

class FMPhotoViewController: UIViewController {
    open var scalingImageView: FMScalingImageView!
    
    open var photo: FMPhotoAsset
    
    private var imageRequestId: PHImageRequestID?
    
    public init(withPhoto photo: FMPhotoAsset) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        if let imageRequestId = self.imageRequestId {
           PHImageManager.default().cancelImageRequest(imageRequestId)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scalingImageView = FMScalingImageView(frame: self.view.frame)
        self.scalingImageView.delegate = self

        self.scalingImageView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.scalingImageView.clipsToBounds = true

        self.view.addSubview(self.scalingImageView)

        self.imageRequestId = self.photo.requestThumb() { image in
            self.scalingImageView.image = image
            self.imageRequestId = self.photo.requestFullSizePhoto() { fullSizeImage in
                self.scalingImageView.image = fullSizeImage
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    open override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scalingImageView.frame = view.bounds
    }
}

extension FMPhotoViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.scalingImageView.imageView
    }
}
