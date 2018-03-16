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
    var scaleX: CGFloat
    var scaleY: CGFloat
    var scaleW: CGFloat
    var scaleH: CGFloat
    
    func area(forSize size: CGSize) -> CGRect {
        return CGRect(x: ceil(size.width * scaleX),
                      y: ceil(size.height * scaleY),
                      width: ceil(size.width * scaleW),
                      height: ceil(size.height * scaleH))
    }
}

struct FMImageEditor {
    var filter: FMFilterable?
    var crop: FMCroppable?
    var cropArea: FMCropArea?
    var zoomScale: CGFloat?

    
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
        if let filter = filter {
            return filter.filter(image: image)
        }
        return image
    }
    
    func performCrop(source image: UIImage) -> UIImage {
        if let crop = crop, let cropArea = cropArea {
            return crop.crop(image: image,
                             toRect: cropArea.area(forSize: image.size))
        }
        return image
    }
}
