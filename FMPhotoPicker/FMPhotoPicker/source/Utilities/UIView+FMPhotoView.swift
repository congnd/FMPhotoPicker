//
//  UIView+FMPhotoView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/06.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

extension UIView {
    func snapshot() -> UIView {
        if layer.contents == nil {
            layer.setNeedsDisplay()
            layer.displayIfNeeded()
        }
        
        if let contents = layer.contents {
            var snapshotedView: UIView!
            
            if let view = self as? UIImageView {
                snapshotedView = type(of: view).init(image: view.image)
                snapshotedView.bounds = view.bounds
            } else {
                snapshotedView = UIView(frame: frame)
                snapshotedView.layer.contents = contents
                snapshotedView.layer.bounds = layer.bounds
            }
            snapshotedView.layer.cornerRadius = layer.cornerRadius
            snapshotedView.layer.masksToBounds = layer.masksToBounds
            snapshotedView.contentMode = contentMode
            snapshotedView.transform = transform
            
            return snapshotedView
        } else {
            return snapshotView(afterScreenUpdates: true)!
        }
    }
}
