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
    case CIColorMonochrome = "CIColorMonochrome"
    case CIColorPosterize = "CIColorPosterize"
    case CIFalseColor = "CIFalseColor"
    case CIMinimumComponent = "CIMinimumComponent"
    
    case CISepiaTone = "CISepiaTone"
    case CIVignette = "CIVignette"
    
    func displayName() -> String {
        switch self {
        case .CIPhotoEffectChrome: return "Chrome"
        case .CIPhotoEffectFade: return "Fade"
        case .CIPhotoEffectInstant: return "Instant"
        case .CIPhotoEffectMono: return "Mono"
        case .CIPhotoEffectNoir: return "Noir"
        case .CIPhotoEffectProcess: return "Process"
        case .CIPhotoEffectTonal: return "Tonal"
        case .CIPhotoEffectTransfer: return "Transfer"
            
        case .CIColorCrossPolynomial:return "Polynomial"
        case .CIColorCube: return "Color Cube"
        case .CIColorCubeWithColorSpace: return "Color Space"
        case .CIColorInvert: return "Invert"
            
        case .CIColorMonochrome: return "Monochrome"
        case .CIColorPosterize: return "Posterize"
        case .CIFalseColor: return "Color"
        case .CIMinimumComponent: return "Component"
            
        case .CISepiaTone: return "Sepia"
        case .CIVignette: return "Vignette"
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
