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
    private let indicatorContainter: UIView
    private let indicator: UIActivityIndicatorView
    
    static let shared = FMLoadingView()
    
    private init() {
        let rootVC = (UIApplication.shared.delegate?.window??.rootViewController)!
        
        self.transparentView = UIView(frame: rootVC.view.frame)
        self.transparentView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)
        
        self.indicatorContainter = UIView(frame: CGRect(x: 0, y: 0, width: 80, height: 80))
        self.indicatorContainter.backgroundColor = .white
        self.indicatorContainter.layer.cornerRadius = 10
        
        self.indicator = UIActivityIndicatorView(frame: CGRect(x: 0, y: 0, width: 35, height: 35))
        self.indicatorContainter.addSubview(self.indicator)
        self.indicator.center = self.indicatorContainter.center
        self.indicator.color = .black
        self.indicator.startAnimating()
        
        self.transparentView.addSubview(self.indicatorContainter)
        
        self.indicatorContainter.center = self.transparentView.center
        
        self.transparentView.isHidden = true
        
        UIApplication.shared.keyWindow?.addSubview(self.transparentView)
    }
    
    func show() {
        self.transparentView.isHidden = false
        self.transparentView.alpha = 0
        UIView.animate(withDuration: 0.2, animations: {
            self.transparentView.alpha = 1
        })
    }
    
    func hide() {
        UIView.animate(withDuration: 0.2,
                       animations: {
                        self.transparentView.alpha = 0
        },
                       completion: { completed in
                        self.transparentView.isHidden = true
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
