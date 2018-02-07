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

    var thumb: UIImage?
    var thumbRequestId: PHImageRequestID?
    
    private var fullSizePhoto: UIImage?
    private var fullSizePhotoRequestId: PHImageRequestID?
    
    init(asset: PHAsset, key: String) {
        self.asset = asset
        self.key = "1"
    }
    
    func requestThumb(_ complete: @escaping (UIImage?) -> Void) {
        if let thumb = self.thumb {
            complete(thumb)
        } else {
            self.thumbRequestId = Helper.getPhoto(by: self.asset, in: CGSize(width: 150, height: 150)) { image in
                self.thumbRequestId = nil
                self.thumb = image
                complete(image)
            }
        }
    }
    
    func requestFullSizePhoto(complete: @escaping (UIImage?) -> Void) {
        if let fullSizePhoto = self.fullSizePhoto {
            complete(fullSizePhoto)
        } else {
            self.fullSizePhotoRequestId = Helper.getFullSizePhoto(by: self.asset) { image in
                self.fullSizePhotoRequestId = nil
                self.fullSizePhoto = image
                complete(self.fullSizePhoto)
            }
        }
    }
    
    public func cancelAllRequest() {
        self.cancelThumbRequest()
        self.cancelFullSizePhotoRequest()
    }
    
    public func cancelThumbRequest() {
        if let thumbRequestId = self.thumbRequestId {
            PHImageManager.default().cancelImageRequest(thumbRequestId)
        }
    }
    
    public func cancelFullSizePhotoRequest() {
        if let fullSizePhotoRequestId = self.fullSizePhotoRequestId {
            PHImageManager.default().cancelImageRequest(fullSizePhotoRequestId)
        }
    }
}
