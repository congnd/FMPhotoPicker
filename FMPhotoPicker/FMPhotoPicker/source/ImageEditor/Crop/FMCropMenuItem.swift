//
//  FMCropMenuItem.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/09.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

enum FMCropMenuItem: String {
    case cropReset = "リセット"
    case cropRotation = "回転"
    
    public func icon() -> UIImage? {
        switch self {
        case .cropReset:
            return UIImage(named: "icon_crop_reset", in: Bundle(for: FMPhotoPickerViewController.self), compatibleWith: nil)
        case .cropRotation:
            return UIImage(named: "icon_crop_rotation", in: Bundle(for: FMPhotoPickerViewController.self), compatibleWith: nil)
        }
    }
}
