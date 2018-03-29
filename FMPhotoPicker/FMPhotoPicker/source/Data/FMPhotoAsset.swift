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
    let asset: PHAsset?
    let sourceImage: UIImage?
    
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
    
    init(asset: PHAsset, forceCropType: FMCroppable?) {
        self.asset = asset
        self.mediaType = FMMediaType(withPHAssetMediaType: asset.mediaType)
        self.sourceImage = nil
        
        if let fmCropRatio = forceCropType?.ratio() {
            let assetRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
            let cropRatio = fmCropRatio.width / fmCropRatio.height
            var scaleW, scaleH: CGFloat
            if assetRatio > cropRatio {
                scaleH = 1.0
                scaleW = cropRatio / assetRatio
            } else {
                scaleW = 1.0
                scaleH = assetRatio / cropRatio
            }
            let cropArea = FMCropArea(scaleX: (1 - scaleW) / 2,
                                      scaleY: (1 - scaleH) / 2,
                                      scaleW: scaleW,
                                      scaleH: scaleH)
            self.editor.cropArea = cropArea
            self.editor.crop = FMCrop.ratioSquare
        }
    }
    
    init(sourceImage: UIImage) {
        self.sourceImage = sourceImage
        self.mediaType = .image
        self.asset = nil
    }
    
    func requestVideoFrames(_ complete: @escaping ([CGImage]) -> Void) {
        if let videoFrames = self.videoFrames {
            complete(videoFrames)
        } else {
            if let asset = asset {
                Helper.generateVideoFrames(from: asset) { cgImages in
                    self.videoFrames = cgImages
                    complete(cgImages)
                }
            } else {
                complete([])
            }
        }
    }
    
    func requestThumb(_ complete: @escaping (UIImage?) -> Void) {
        if let thumb = self.thumb {
            complete(thumb)
        } else {
            if let asset = asset {
                self.thumbRequestId = Helper.getPhoto(by: asset, in: CGSize(width: 150, height: 150)) { image in
                    self.thumbRequestId = nil
                    self.originalThumb = image
                    
                    guard let image = image else { return complete(nil) }
                    let edited = self.editor.reproduce(source: image, cropState: .edited, filterState: .edited)
                    self.thumb = edited
                    complete(edited)
                }
            } else {
                guard let image = sourceImage else { return complete(nil) }
                let edited = self.editor.reproduce(source: image, cropState: .edited, filterState: .edited)
                complete(edited)
            }
        }
    }
    
    func requestImage(in desireSize: CGSize, _ complete: @escaping (UIImage?) -> Void) {
        if let asset = asset {
            _ = Helper.getPhoto(by: asset, in: desireSize) { image in
                guard let image = image else { return complete(nil) }
                let edited = self.editor.reproduce(source: image, cropState: .edited, filterState: .edited)
                complete(edited)
            }
        } else {
            guard let image = sourceImage?.resize(toSize: desireSize) else { return complete(nil) }
            let edited = self.editor.reproduce(source: image, cropState: .edited, filterState: .edited)
            complete(edited)
        }
    }
    
    func requestFullSizePhoto(cropState: FMImageEditState, filterState: FMImageEditState, complete: @escaping (UIImage?) -> Void) {
        if let asset = asset {
            self.fullSizePhotoRequestId = Helper.getFullSizePhoto(by: asset) { image in
                self.fullSizePhotoRequestId = nil
                if self.canceledFullSizeRequest {
                    self.canceledFullSizeRequest = false
                    complete(nil)
                } else {
                    guard let image = image else { return complete(nil) }
                    let result = self.editor.reproduce(source: image, cropState: cropState, filterState: filterState)
                    complete(result)
                }
            }
        } else {
            guard let image = sourceImage else { return complete(nil) }
            let result = self.editor.reproduce(source: image, cropState: cropState, filterState: filterState)
            complete(result)
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
    
    public func getAppliedFilter() -> FMFilterable {
        return editor.filter
    }
    
    public func getAppliedCrop() -> FMCroppable {
        return editor.crop
    }
    
    public func getAppliedCropArea() -> FMCropArea {
        return editor.cropArea
    }
    
    public func apply(filter: FMFilterable, crop: FMCroppable, cropArea: FMCropArea) {
        editor.filter = filter
        editor.crop = crop
        editor.cropArea = cropArea
        
        if let source = originalThumb {
            thumb = editor.reproduce(source: source, cropState: .edited, filterState: .edited)
            if thumb != nil {
                thumbChanged(thumb!)
            }
        }
    }
    
    public func isEdited() -> Bool {
        if editor.filter as? FMFilter != FMFilter.None { return true }
        if !editor.cropArea.isApproximatelyEqualToOriginal() { return true }
        
        return false
    }
}
