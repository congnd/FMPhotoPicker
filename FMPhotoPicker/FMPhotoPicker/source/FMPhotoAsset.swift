//
//  FMPhotoAsset.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/25.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import Foundation
import Photos

public class FMPhotoAsset {
    var asset: PHAsset
    var key: String
//    var isSelected = false
    var thumb: UIImage?
    var fullSizePhoto: UIImage?
    var selectIndex = 0
    
    init(asset: PHAsset, key: String) {
        self.asset = asset
        self.key = "1"
    }
    
    func requestThumb(_ complete: @escaping (UIImage?) -> Void) -> PHImageRequestID? {
        if let thumb = self.thumb {
            complete(thumb)
            return nil
        } else {
            let requestId = Helper.getPhoto(by: self.asset, in: CGSize(width: 300, height: 300)) { image in
                self.thumb = image
                complete(image)
            }
            return requestId
        }
    }
    
    func requestFullSizePhoto(complete: @escaping (UIImage?) -> Void) -> PHImageRequestID? {
        if let fullSizePhoto = self.fullSizePhoto {
            complete(fullSizePhoto)
            return nil
        } else {
            let requestId = Helper.getFullSizePhoto(by: self.asset) { image in
                self.fullSizePhoto = image
                complete(self.fullSizePhoto)
            }
            return requestId
        }
    }
}
