//
//  Const.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/04/05.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

internal let kComplexAnimationDuration: Double = 0.375
internal let kEnteringAnimationDuration: Double = 0.225
internal let kLeavingAnimationDuration: Double = 0.195
internal let kKeyframeAnimationDuration: Double = 2.0

internal let kRedColor = UIColor(red: 1, green: 81/255, blue: 81/255, alpha: 1)
internal let kGrayColor = UIColor(red: 114/255, green: 114/255, blue: 114/255, alpha: 1)
internal let kBlackColor = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
internal let kBackgroundColor = UIColor(red: 242/255, green: 242/255, blue: 242/255, alpha: 1)
internal let kTransparentBackgroundColor = UIColor(white: 1, alpha: 0.9)
internal let kBorderColor = UIColor(red: 221/255, green: 221/255, blue: 221/255, alpha: 1)

internal let kDefaultFilter = FMFilter.None
internal let kDefaultCrop = FMCrop.ratioCustom

internal let kEpsilon: CGFloat = 0.01

internal let kFilterPreviewImageSize = CGSize(width: 90, height: 90)

internal let kDefaultAvailableFilters = [
    FMFilter.None,
    FMFilter.CIPhotoEffectChrome,
    FMFilter.CIPhotoEffectInstant,
    FMFilter.CIPhotoEffectMono,
    FMFilter.CIPhotoEffectProcess,
    FMFilter.CIPhotoEffectTransfer,
    FMFilter.CISepiaTone,
    FMFilter.CIPhotoEffectNoir,
    FMFilter.CIMinimumComponent,
    FMFilter.CIColorPosterize,
    FMFilter.CIColorMonochrome,
    FMFilter.CIColorCrossPolynomial,
    FMFilter.CIColorCube,
    FMFilter.CIColorCubeWithColorSpace,
    FMFilter.CIColorInvert,
    FMFilter.CIFalseColor,
    FMFilter.CIPhotoEffectFade,
    FMFilter.CIPhotoEffectTonal,
    FMFilter.CIVignette
]

internal let kDefaultAvailableCrops = [
    FMCrop.ratioCustom,
    FMCrop.ratioOrigin,
    FMCrop.ratioSquare,
    FMCrop.ratio4x3,
    FMCrop.ratio16x9
]
