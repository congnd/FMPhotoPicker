//
//  InsertableUIView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/06.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

protocol InsertableUIView {
    func insert(toView parentView: UIView)
}

extension InsertableUIView where Self: UIView {
    internal func insert(toView parentView: UIView) {
        parentView.addSubview(self)
        
        translatesAutoresizingMaskIntoConstraints = false
        topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        leftAnchor.constraint(equalTo: parentView.leftAnchor).isActive = true
        bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        rightAnchor.constraint(equalTo: parentView.rightAnchor).isActive = true
    }
}

extension UIView: InsertableUIView {}
