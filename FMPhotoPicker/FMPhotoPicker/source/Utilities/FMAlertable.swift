//
//  FMAlertable.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/20.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

public protocol FMAlertable {
    func show(in viewController: UIViewController, ok: @escaping () -> Void, cancel: @escaping () -> Void)
}

struct FMAlert: FMAlertable {
    func show(in viewController: UIViewController, ok: @escaping () -> Void, cancel: @escaping () -> Void) {
        let alert = UIAlertController(title: "Are you sure you want to cancel?", message: nil, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Yes", style: .cancel, handler: { _ in ok() }))
        alert.addAction(UIAlertAction(title: "No", style: .default, handler: { _ in cancel() }))
        
        viewController.present(alert, animated: true, completion: nil)
    }
}
