//
//  FMPhotoPickerOptions.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/09.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import Foundation

public enum FMMediaType: Int {
    case image = 1
    case video = 2
}

public struct FMPhotoPickerConfig {
    var mediaTypes: [FMMediaType]
    var maxImageSelections: Int
    var maxVideoSelections: Int
    
    public init() {
        self.mediaTypes = [.image, .video]
        self.maxVideoSelections = 10
        self.maxImageSelections = 10
    }
    
    public init(mediaTypes: [FMMediaType], maxImageSelections: Int, maxVideoSelections: Int) {
        self.mediaTypes = mediaTypes
        self.maxImageSelections = maxImageSelections
        self.maxVideoSelections = maxVideoSelections
    }
}
