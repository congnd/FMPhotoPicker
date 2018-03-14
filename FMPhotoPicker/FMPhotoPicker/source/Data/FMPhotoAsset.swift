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
    var mediaType: FMMediaType
    var thumb: UIImage?
    var thumbRequestId: PHImageRequestID?
    
    var originalThumb: UIImage?
    
    var videoFrames: [CGImage]?
    
    var thumbChanged: (UIImage) -> Void = { _ in }
    
    private var fullSizePhotoRequestId: PHImageRequestID?
    private var editor = FMImageEditor()
    /**
     Indicates whether the request for the full size image was canceled.
     A workaround for this issue:
     https://stackoverflow.com/questions/48657304/phimagemanagers-cancelimagerequest-does-not-work-as-expected?noredirect=1#comment84332723_48657304
     */
    private var canceledFullSizeRequest = false
    
    init(asset: PHAsset) {
        self.asset = asset
        self.mediaType = FMMediaType(withPHAssetMediaType: asset.mediaType)
    }
    
    func requestVideoFrames(_ complete: @escaping ([CGImage]) -> Void) {
        if let videoFrames = self.videoFrames {
            complete(videoFrames)
        } else {
            Helper.generateVideoFrames(from: self.asset) { cgImages in
                self.videoFrames = cgImages
                complete(cgImages)
            }
        }
    }
    
    func requestThumb(_ complete: @escaping (UIImage?) -> Void) {
        if let thumb = self.thumb {
            complete(thumb)
        } else {
            self.thumbRequestId = Helper.getPhoto(by: self.asset, in: CGSize(width: 150, height: 150)) { image in
                self.thumbRequestId = nil
                self.thumb = image
                self.originalThumb = image
                
                guard let image = image else { return complete(nil) }
                let edited = self.editor.reproduce(source: image)
                complete(edited)
            }
        }
    }
    
    func requestImage(in desireSize: CGSize, _ complete: @escaping (UIImage?) -> Void) {
        _ = Helper.getPhoto(by: self.asset, in: desireSize) { image in
            guard let image = image else { return complete(nil) }
            let edited = self.editor.reproduce(source: image)
            complete(edited)
        }
    }
    
    func requestFullSizePhoto(complete: @escaping (UIImage?) -> Void) {
        self.fullSizePhotoRequestId = Helper.getFullSizePhoto(by: self.asset) { image in
            self.fullSizePhotoRequestId = nil
            if self.canceledFullSizeRequest {
                self.canceledFullSizeRequest = false
                complete(nil)
            } else {
                guard let image = image else { return complete(nil) }
                let edited = self.editor.reproduce(source: image)
                complete(edited)
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
            self.canceledFullSizeRequest = true
        }
    }
    
    public func getAppliedFilter() -> FMFilterable? {
        return editor.filter
    }
    
    public func apply(filter: FMFilterable?, crop: FMCroppable?) {
        editor.filter = filter
        editor.crop = crop
        if let source = originalThumb {
            thumb = editor.reproduce(source: source)
            if thumb != nil {
                thumbChanged(thumb!)
            }
        }
    }
}
