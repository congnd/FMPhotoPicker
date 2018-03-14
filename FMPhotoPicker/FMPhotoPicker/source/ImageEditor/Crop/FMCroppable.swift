//
//  FMCroppable.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/14.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

public protocol FMCroppable {
    func crop(image: UIImage, toRect rect: CGRect) -> UIImage
    func name() -> String
    func icon() -> UIImage
    func ratio() -> FMCropRatio?
}
