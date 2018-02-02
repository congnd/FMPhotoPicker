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
    open var scalingImageView: FMScalingImageView?
    
    open var photo: FMPhotoAsset
    
    private var imageView: UIImageView!
    
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
        
        self.imageView = UIImageView(frame: self.view.frame)
        self.imageView.contentMode = .scaleAspectFit
        self.imageView.clipsToBounds = true
        self.view.addSubview(self.imageView)
        
        self.imageRequestId = self.photo.requestThumb() { image in
            self.imageView.image = image
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.imageRequestId = self.photo.requestFullSizePhoto() { fullSizeImage in
            self.imageView.image = fullSizeImage
        }
    }
}
