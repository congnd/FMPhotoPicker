//
//  FMImageEditor.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/02.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

enum FMImageEditState {
    case original
    case edited
}

public struct FMCropArea {
    var scaleX: CGFloat = 0.0
    var scaleY: CGFloat = 0.0
    var scaleW: CGFloat = 1.0
    var scaleH: CGFloat = 1.0
    
    func area(forSize size: CGSize) -> CGRect {
        return CGRect(x: ceil(size.width * scaleX),
                      y: ceil(size.height * scaleY),
                      width: ceil(size.width * scaleW),
                      height: ceil(size.height * scaleH))
    }
    
    func isApproximatelyEqualToOriginal() -> Bool {
        if scaleX > kEpsilon { return false }
        if scaleY > kEpsilon { return false }
        if 1.0 - scaleW > kEpsilon { return false }
        if 1.0 - scaleH > kEpsilon { return false }
        return true
    }
    
    func isApproximatelyEqual(to cropArea: FMCropArea) -> Bool {
        if abs(cropArea.scaleX - scaleX) > kEpsilon { return false }
        if abs(cropArea.scaleY - scaleY) > kEpsilon { return false }
        if abs(cropArea.scaleW - scaleW) > kEpsilon { return false }
        if abs(cropArea.scaleH - scaleH) > kEpsilon { return false }
        return true
    }
}

struct FMImageEditor {
    var filter: FMFilterable
    var crop: FMCroppable
    var cropArea: FMCropArea
    
    let initFilter: FMFilterable
    let initCrop: FMCroppable
    let initCropArea: FMCropArea
    
    init(filter: FMFilterable=kDefaultFilter, crop: FMCroppable=kDefaultCrop, cropArea: FMCropArea=FMCropArea()) {
        initFilter      = filter
        self.filter     = filter
        
        initCrop        = crop
        self.crop       = crop
        
        initCropArea    = cropArea
        self.cropArea   = cropArea
    }
    
    func reproduce(source image: UIImage, cropState: FMImageEditState, filterState: FMImageEditState) -> UIImage {
        var result = image
        
        if cropState == .edited {
            result = performCrop(source: result)
        }
        
        if filterState == .edited {
            result = performFilter(source: result)
        }
        
        return result
    }
    
    func performFilter(source image: UIImage) -> UIImage {
        return filter.filter(image: image)
    }
    
    func performCrop(source image: UIImage) -> UIImage {
        if cropArea.isApproximatelyEqualToOriginal() {
            return image
        }
        
        return crop.crop(image: image,
                         toRect: cropArea.area(forSize: image.size))
    }
    
    public func isEdited() -> Bool {
        return filter.filterName() != initFilter.filterName() || crop.identifier() != initCrop.identifier() || !cropArea.isApproximatelyEqual(to: initCropArea)
    }
}
