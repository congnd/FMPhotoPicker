//
//  UIImage+Extensions.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/13.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

extension UIImage {
    convenience init(view: UIView) {
        UIGraphicsBeginImageContext(view.frame.size)
        view.layer.render(in:UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        self.init(cgImage: image!.cgImage!)
    }
}
