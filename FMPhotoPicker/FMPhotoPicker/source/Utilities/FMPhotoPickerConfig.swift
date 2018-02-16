//
//  FMPhotoPickerOptions.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/09.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import Foundation
import Photos

public enum FMSelectMode {
    case multiple
    case single
}

public enum FMMediaType {
    case image
    case video
    case unsupported
    
    public func value() -> Int {
        switch self {
        case .image:
            return PHAssetMediaType.image.rawValue
        case .video:
            return PHAssetMediaType.video.rawValue
        case .unsupported:
            return PHAssetMediaType.unknown.rawValue
        }
    }
    
    init(withPHAssetMediaType type: PHAssetMediaType) {
        switch type {
        case .image:
            self = .image
        case .video:
            self = .video
        default:
            self = .unsupported
        }
    }
}

public struct FMPhotoPickerConfig {
    var mediaTypes: [FMMediaType]
    var selectMode: FMSelectMode
    var maxImage: Int
    var maxVideo: Int
    
    public init(selectMode: FMSelectMode = .multiple,
                mediaTypes: [FMMediaType] = [.image],
                maxImage: Int = 10,
                maxVideo: Int = 10) {
        self.mediaTypes = mediaTypes
        self.maxImage = maxImage
        self.maxVideo = maxVideo
        self.selectMode = selectMode
    }   
}
