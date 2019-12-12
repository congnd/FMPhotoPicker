//
//  FMPhotoAsset.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/25.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit
import Photos

public class FMPhotoAsset {
    let asset: PHAsset?
    let sourceImage: UIImage?
    
    var mediaType: FMMediaType
    
    // a fully edited thumbnail version of the image
    var editedThumb: UIImage?
    
    // a filterd-only thumbnail version of the image
    var filterdThumb: UIImage?
    
    var thumbRequestId: PHImageRequestID?
    
    var videoFrames: [CGImage]?
    
    var thumbChanged: (UIImage) -> Void = { _ in }
    
    private var fullSizePhotoRequestId: PHImageRequestID?
    private var editor: FMImageEditor!
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
        
        self.editor = self.initializeEditor(for: forceCropType, imageSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight))
    }
    
    init(sourceImage: UIImage, forceCropType: FMCroppable?) {
        self.sourceImage = sourceImage
        self.mediaType = .image
        self.asset = nil
        
        self.editor = self.initializeEditor(for: forceCropType, imageSize: sourceImage.size)
    }
    
    private func initializeEditor(for forceCropType: FMCroppable?, imageSize: CGSize) -> FMImageEditor {
        guard let forceCropType = forceCropType, let fmCropRatio = forceCropType.ratio() else {
            return FMImageEditor()
        }
        
        let imageRatio = CGFloat(imageSize.width) / CGFloat(imageSize.height)
        let cropRatio = fmCropRatio.width / fmCropRatio.height
        var scaleW, scaleH: CGFloat
        if imageRatio > cropRatio {
            scaleH = 1.0
            scaleW = cropRatio / imageRatio
        } else {
            scaleW = 1.0
            scaleH = imageRatio / cropRatio
        }
        let cropArea = FMCropArea(scaleX: (1 - scaleW) / 2,
                                  scaleY: (1 - scaleH) / 2,
                                  scaleW: scaleW,
                                  scaleH: scaleH)
        return FMImageEditor(filter: kDefaultFilter, crop: forceCropType, cropArea: cropArea)
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
    
    func requestThumb(refresh: Bool=false, _ complete: @escaping (UIImage?) -> Void) {
        if let editedThumb = self.editedThumb, !refresh {
            complete(editedThumb)
        } else {
            // It is not absolutely right but it gives much better performance in most cases
            let cropScale = (editor.cropArea.scaleW + editor.cropArea.scaleH) / 2
            let cellSize = UIScreen.main.bounds.width / 3 * UIScreen.main.scale
            let size = CGSize(width: cellSize / cropScale, height: cellSize / cropScale)
            if let asset = asset {
                self.thumbRequestId = Helper.getPhoto(by: asset, in: size) { image in
                    self.thumbRequestId = nil
                    
                    guard let image = image else { return complete(nil) }
                    
                    self.editedThumb    = self.editor.reproduce(source: image, cropState: .edited, filterState: .edited)
                    self.filterdThumb   = self.editor.reproduce(source: image, cropState: .edited, filterState: .original)
                    
                    complete(self.editedThumb)
                }
            } else {
                guard let image = sourceImage else { return complete(nil) }
                let edited = self.editor.reproduce(source: image.resize(toSizeInPixel: size), cropState: .edited, filterState: .edited)
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
            guard let image = sourceImage?.resize(toSizeInPixel: desireSize) else { return complete(nil) }
            let edited = self.editor.reproduce(source: image, cropState: .edited, filterState: .edited)
            complete(edited)
        }
    }
    
    func requestFullSizePhoto(cropState: FMImageEditState, filterState: FMImageEditState, complete: @escaping (UIImage?) -> Void) {
        if let asset = asset {
            self.fullSizePhotoRequestId = Helper.getPhoto(by: asset, in: CGSize(width: 2000, height: 2000)){ image in
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
        
        requestThumb(refresh: true) { image in
            if let image = image {
                self.thumbChanged(image)
            }
        }
    }
    
    public func isEdited() -> Bool {
        return editor.isEdited()
    }
}
