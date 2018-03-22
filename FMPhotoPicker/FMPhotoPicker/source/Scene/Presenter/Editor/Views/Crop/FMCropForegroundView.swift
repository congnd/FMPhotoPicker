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
    private var compareView: UIImageView
    public var isEnabledTouches = true {
        didSet {
            isUserInteractionEnabled = isEnabledTouches
        }
    }

    override var frame: CGRect {
        didSet {
//            self.imageView.frame = self.frame
        }
    }

    init(image: UIImage, originalImage: UIImage) {
        imageView = UIImageView(frame: .zero)
        compareView = UIImageView(frame: .zero)
        
        super.init(frame: .zero)
        
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        addSubview(imageView)
        
        compareView.image = originalImage
        compareView.contentMode = .scaleAspectFit
        addSubview(compareView)
        
        clipsToBounds = true
    }
    
    private func showCompareView() {
        compareView.frame = imageView.frame
        compareView.isHidden = false
    }
    
    private func hideCompareView() {
        compareView.isHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        showCompareView()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        hideCompareView()
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        hideCompareView()
    }
}
