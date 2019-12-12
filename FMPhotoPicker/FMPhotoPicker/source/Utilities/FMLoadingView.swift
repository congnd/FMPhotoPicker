//
//  LoadingView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/12.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import Foundation
import UIKit

class FMLoadingView {
    private let transparentView: UIView
    private let indicator: UIActivityIndicatorView
    
    static let shared = FMLoadingView()
    
    private init() {
        self.transparentView = UIView()
        self.transparentView.backgroundColor = UIColor(white: 0, alpha: 0.4)
        
        self.indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        self.indicator.center = self.transparentView.center
        self.indicator.color = .white
        
        self.transparentView.addSubview(self.indicator)
    }
    
    func show() {
        guard let keyWindow = UIApplication.shared.keyWindow else { return }
        
        self.transparentView.frame = keyWindow.frame
        keyWindow.addSubview(self.transparentView)
        
        self.transparentView.alpha = 0
        self.indicator.startAnimating()
        UIView.animate(withDuration: kEnteringAnimationDuration, animations: {
            self.transparentView.alpha = 1
        })
    }
    
    func hide() {
        UIView.animate(withDuration: kLeavingAnimationDuration,
                       animations: {
                        self.transparentView.alpha = 0
        },
                       completion: { completed in
                        self.transparentView.removeFromSuperview()
                        self.indicator.stopAnimating()
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
