//
//  FMFilterName.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/01.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import Foundation

enum FMFilterName: String {
    // CIPhotoEffect
    case CIPhotoEffectChrome = "CIPhotoEffectChrome"
    case CIPhotoEffectFade = "CIPhotoEffectFade"
    case CIPhotoEffectInstant = "CIPhotoEffectInstant"
    case CIPhotoEffectMono = "CIPhotoEffectMono"
    case CIPhotoEffectNoir = "CIPhotoEffectNoir"
    case CIPhotoEffectProcess = "CIPhotoEffectProcess"
    case CIPhotoEffectTonal = "CIPhotoEffectTonal"
    case CIPhotoEffectTransfer = "CIPhotoEffectTransfer"
    
    case CIColorCrossPolynomial = "CIColorCrossPolynomial"
    case CIColorCube = "CIColorCube"
    case CIColorCubeWithColorSpace = "CIColorCubeWithColorSpace"
    case CIColorInvert = "CIColorInvert"
//    case CIColorMap = "CIColorMap"
    case CIColorMonochrome = "CIColorMonochrome"
    case CIColorPosterize = "CIColorPosterize"
    case CIFalseColor = "CIFalseColor"
//    case CIMaskToAlpha = "CIMaskToAlpha"
//    case CIMaximumComponent = "CIMaximumComponent"
    case CIMinimumComponent = "CIMinimumComponent"
    
    case CISepiaTone = "CISepiaTone"
    case CIVignette = "CIVignette"
//    case CIVignetteEffect = "CIVignetteEffect"
    
    func displayName() -> String {
        switch self {
        default:
            return self.rawValue.replacingOccurrences(of: "CIPhotoEffect", with: "").replacingOccurrences(of: "CIColor", with: "").replacingOccurrences(of: "CI", with: "")
        }
    }
    
    public static func cases() -> AnySequence<FMFilterName> {
        return AnySequence { () -> AnyIterator<FMFilterName> in
            var raw = 0
            return AnyIterator {
                let current: FMFilterName = withUnsafePointer(to: &raw) { $0.withMemoryRebound(to: self, capacity: 1) { $0.pointee } }
                guard current.hashValue == raw else {
                    return nil
                }
                raw += 1
                return current
            }
        }
    }
    
    public static var allValues: [FMFilterName] {
        return Array(self.cases())
    }
}
