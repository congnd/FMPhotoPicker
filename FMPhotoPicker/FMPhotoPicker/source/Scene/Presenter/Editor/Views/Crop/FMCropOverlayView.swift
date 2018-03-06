//
//  FMCropOverlayView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/05.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMCropOverlayView: UIView {
    
    override var frame: CGRect {
        didSet {
            
        }
    }

    init() {
        super.init(frame: .zero)
        
        isUserInteractionEnabled = false
        
        layer.borderWidth = 6
        layer.borderColor = UIColor.brown.cgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
