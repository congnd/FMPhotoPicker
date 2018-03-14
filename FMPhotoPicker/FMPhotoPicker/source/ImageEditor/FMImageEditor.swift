//
//  FMImageEditor.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/02.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

struct FMImageEditor {
    var filter: FMFilterable?
    var crop: FMCroppable?

    
    func reproduce(source image: UIImage) -> UIImage {
        var result = image
        if let filter = filter {
            result = filter.filter(image: image)
        }
        
        return result
    }
}
