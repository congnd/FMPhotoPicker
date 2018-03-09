//
//  FMCropName.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/09.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

struct FMCropRatio {
    let width: Int
    let height: Int
}

enum FMCropName: String {
    case ratio4x3 = "4:3"
    case ratio16x9 = "16:9"
    case ratioCustom = "カスタム"
    case ratioOrigin = "元の縦横比"
    case ratioSquare = "正方形"
    
    public func ratio() -> FMCropRatio? {
        switch self {
        case .ratio4x3:
            return FMCropRatio(width: 16, height: 9)
        case .ratio16x9:
            return FMCropRatio(width: 16, height: 9)
        case .ratioSquare:
            return FMCropRatio(width: 1, height: 1)
        default:
            return nil
        }
    }
        
    public func icon() -> UIImage? {
        switch self {
        case .ratio4x3:
            return UIImage(named: "icon_crop_4x3", in: Bundle(for: FMPhotoPickerViewController.self), compatibleWith: nil)
        case .ratio16x9:
            return UIImage(named: "icon_crop_16x9", in: Bundle(for: FMPhotoPickerViewController.self), compatibleWith: nil)
        case .ratioCustom:
            return UIImage(named: "icon_crop_custom", in: Bundle(for: FMPhotoPickerViewController.self), compatibleWith: nil)
        case .ratioOrigin:
            return UIImage(named: "icon_crop_origin_ratio", in: Bundle(for: FMPhotoPickerViewController.self), compatibleWith: nil)
        case .ratioSquare:
            return UIImage(named: "icon_crop_square", in: Bundle(for: FMPhotoPickerViewController.self), compatibleWith: nil)
        }
    }
}
