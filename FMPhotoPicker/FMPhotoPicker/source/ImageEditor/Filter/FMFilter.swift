//
//  FMFilter.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/01.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMFilter: FMFilterable {
    let name: FMFilterName
    
    init(name: FMFilterName) {
        self.name = name
    }
    
    func filter(image: UIImage) -> UIImage {
        let context = CIContext(options: nil)
        
        let currentFilter = CIFilter(name: self.name.rawValue)!
        let beginImage = CIImage(image: image)
        currentFilter.setValue(beginImage, forKey: kCIInputImageKey)
//        currentFilter.setValue(0.5, forKey: kCIInputIntensityKey)
        
        if let output = currentFilter.outputImage {
            if let cgimg = context.createCGImage(output, from: output.extent) {
                let originalOrientation = image.imageOrientation
                let originalScale = image.scale
                return UIImage(cgImage: cgimg, scale: originalScale, orientation: originalOrientation)
            }
        }
        return UIImage()
    }
    
    func filterName() -> String {
        return self.name.displayName()
    }
}
