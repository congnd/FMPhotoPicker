//
//  FMCropBackgroundView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/05.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMCropBackgroundView: UIView {
    private let imageView: UIImageView
    
    init(image: UIImage) {
        imageView = UIImageView(frame: .zero)
        
        super.init(frame: .zero)
        
        imageView.insert(toView: self)
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
