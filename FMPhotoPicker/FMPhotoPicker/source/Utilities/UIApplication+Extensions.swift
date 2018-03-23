//
//  UIApplication+Extensions.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/23.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

extension UIApplication {
    var statusBarView: UIView? {
        return value(forKey: "statusBar") as? UIView
    }
}
