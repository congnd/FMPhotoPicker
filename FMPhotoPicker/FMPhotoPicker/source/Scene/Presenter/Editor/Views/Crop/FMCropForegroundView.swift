//
//  FMCropForegroundView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/05.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMCropForegroundView: UIView {
    public let imageView: UIImageView
    
    override var frame: CGRect {
        didSet {
            self.imageView.frame = self.frame
        }
    }

    init(image: UIImage) {
        imageView = UIImageView(frame: .zero)
        
        super.init(frame: .zero)
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        isUserInteractionEnabled = false
        clipsToBounds = true
        
//        layer.borderWidth = 12
//        layer.borderColor = UIColor.red.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
