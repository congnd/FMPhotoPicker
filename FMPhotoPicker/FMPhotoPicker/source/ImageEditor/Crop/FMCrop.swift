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
    
    public init(width: CGFloat, height: CGFloat) {
        self.width = width
        self.height = height
    }
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
    
    public func name(strings: [String: String]) -> String? {
        switch self {
        case .ratio4x3: return strings["editor_crop_ratio4x3"]
        case .ratio16x9: return strings["editor_crop_ratio16x9"]
        case .ratioCustom: return strings["editor_crop_ratioCustom"]
        case .ratioOrigin: return strings["editor_crop_ratioOrigin"]
        case .ratioSquare: return strings["editor_crop_ratioSquare"]
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
    
    public func identifier() -> String {
        switch self {
        case .ratio4x3: return "ratio4x3"
        case .ratio16x9: return "ratio16x9"
        case .ratioCustom: return "ratioCustom"
        case .ratioOrigin: return "ratioOrigin"
        case .ratioSquare: return "ratioSquare"
        }
    }
}
