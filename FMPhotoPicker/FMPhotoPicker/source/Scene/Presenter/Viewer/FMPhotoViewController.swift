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
    // MARK: - Public
    public var photo: FMPhotoAsset
    
    public var dataSource: FMPhotosDataSource!
    
    // MARK: - Init
    public init(withPhoto photo: FMPhotoAsset) {
        self.photo = photo
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        self.photo.cancelAllRequest()
    }
    
    public func viewToSnapshot() -> UIView {
        return self.view
    }
}
