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
    func name(strings: [String: String]) -> String?
    func icon() -> UIImage
    func ratio() -> FMCropRatio?
    func identifier() -> String
}

extension FMCroppable {
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
}
