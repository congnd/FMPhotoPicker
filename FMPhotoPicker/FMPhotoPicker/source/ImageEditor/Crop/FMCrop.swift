//
//  FMCrop.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/09.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

public struct FMCropRatio {
    let width: CGFloat
    let height: CGFloat
}

public enum FMCrop: FMCroppable {
    case ratio4x3
    case ratio16x9
    case ratioCustom
    case ratioOrigin
    case ratioSquare
    
    public func ratio() -> FMCropRatio? {
        switch self {
        case .ratio4x3:
            return FMCropRatio(width: 4, height: 3)
        case .ratio16x9:
            return FMCropRatio(width: 16, height: 9)
        case .ratioSquare:
            return FMCropRatio(width: 1, height: 1)
        default:
            return nil
        }
    }
    
    public func crop(image: UIImage, toRect rect: CGRect) -> UIImage {
        let orientation = image.imageOrientation
        let scale = image.scale
        var targetRect = CGRect()
        
        switch orientation {
        case .down:
            targetRect.origin.x = (image.size.width - rect.maxX) * scale
            targetRect.origin.y = (image.size.height - rect.maxY) * scale
            targetRect.size.width = rect.width * scale
            targetRect.size.height = rect.height * scale
        case .right:
            targetRect.origin.x = rect.minY * scale
            targetRect.origin.y = (image.size.width - rect.maxX) * scale
            targetRect.size.width = rect.height * scale
            targetRect.size.height = rect.width * scale
        case .left:
            targetRect.origin.x = image.size.height - rect.maxY * scale
            targetRect.origin.y = rect.minX * scale
            targetRect.size.width = rect.height * scale
            targetRect.size.height = rect.width * scale
        default:
            targetRect = CGRect(x: rect.origin.x * scale,
                                y: rect.origin.y * scale,
                                width: rect.width * scale,
                                height: rect.height * scale)
        }
        
        if let croppedCGImage = image.cgImage?.cropping(to: targetRect) {
            return UIImage(cgImage: croppedCGImage, scale: scale, orientation: orientation)
        }
        
        return image
    }
    
    public func name() -> String {
        switch self {
        case .ratio4x3: return "4:3"
        case .ratio16x9: return "16:9"
        case .ratioCustom: return "カスタム"
        case .ratioOrigin: return "元の比率"
        case .ratioSquare: return "正方形"
        }
    }
    
    public func icon() -> UIImage {
        var icon: UIImage?
        switch self {
        case .ratio4x3:
            icon = UIImage(named: "icon_crop_4x3", in: Bundle(for: FMPhotoPickerViewController.self), compatibleWith: nil)
        case .ratio16x9:
            icon = UIImage(named: "icon_crop_16x9", in: Bundle(for: FMPhotoPickerViewController.self), compatibleWith: nil)
        case .ratioCustom:
            icon = UIImage(named: "icon_crop_custom", in: Bundle(for: FMPhotoPickerViewController.self), compatibleWith: nil)
        case .ratioOrigin:
            icon = UIImage(named: "icon_crop_origin_ratio", in: Bundle(for: FMPhotoPickerViewController.self), compatibleWith: nil)
        case .ratioSquare:
            icon = UIImage(named: "icon_crop_square", in: Bundle(for: FMPhotoPickerViewController.self), compatibleWith: nil)
        }
        if icon != nil {
            return icon!
        }
        return UIImage()
    }
}
