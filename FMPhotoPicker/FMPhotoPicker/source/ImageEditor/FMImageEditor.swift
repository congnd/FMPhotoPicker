//
//  FMImageEditor.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/02.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

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
    var scale: CGFloat = 1

    
    func reproduce(source image: UIImage) -> UIImage {
        var result = image
        if let filter = filter {
            result = filter.filter(image: result)
        }
        
        if let crop = crop, let cropArea = cropArea {
            result = crop.crop(image: result,
                               toRect: cropArea.area(forSize: result.size))
        }
        
        return result
    }
}
