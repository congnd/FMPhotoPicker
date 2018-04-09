//
//  FMWarningView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/13.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import Foundation
import UIKit

class FMWarningView {
    private let containerView: UIView
    private let contentView: UIView
    private let messageLabel: UILabel
    
    private var animating = false
    
    public var message: String = "" {
        didSet {
            self.messageLabel.text = self.message
        }
    }
    
    static let shared = FMWarningView()
    
    private init() {
        let rootVC = (UIApplication.shared.delegate?.window??.rootViewController)!
        
        self.containerView = UIView(frame: rootVC.view.frame)
        self.containerView.backgroundColor = .clear
        self.containerView.isHidden = true
        self.containerView.isUserInteractionEnabled = false
        
        self.contentView = UIView()
        self.contentView.backgroundColor = UIColor(white: 0, alpha: 0.9)
        self.contentView.layer.cornerRadius = 10
        
        self.containerView.addSubview(self.contentView)
        
        self.contentView.translatesAutoresizingMaskIntoConstraints = false
        self.contentView.centerXAnchor.constraint(equalTo: self.containerView.centerXAnchor, constant: 0).isActive = true
        self.contentView.centerYAnchor.constraint(equalTo: self.containerView.centerYAnchor, constant: 0).isActive = true
        self.contentView.trailingAnchor.constraint(equalTo: self.containerView.trailingAnchor, constant: -50).isActive = true
        self.contentView.leadingAnchor.constraint(equalTo: self.containerView.leadingAnchor, constant: 50).isActive = true
        self.contentView.heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        self.messageLabel = UILabel()
        self.messageLabel.translatesAutoresizingMaskIntoConstraints = false
        self.messageLabel.textColor = .white
        self.messageLabel.font = UIFont.systemFont(ofSize: 15)
        self.messageLabel.text = self.message
        self.messageLabel.numberOfLines = 2
        self.messageLabel.textAlignment = .center
        
        self.contentView.addSubview(self.messageLabel)
        self.messageLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 8) .isActive = true
        self.messageLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8).isActive = true
        self.messageLabel.leftAnchor.constraint(equalTo: self.contentView.leftAnchor, constant: 8).isActive = true
        self.messageLabel.rightAnchor.constraint(equalTo: self.contentView.rightAnchor, constant: -8).isActive = true
    }
    
    func showAndAutoHide() {
        if self.animating { return }
        
        self.animating = true
        
        UIApplication.shared.keyWindow?.addSubview(self.containerView)
        self.containerView.isHidden = false
        self.containerView.alpha = 0
        
        UIView.animateKeyframes(withDuration: kKeyframeAnimationDuration,
                                delay: 0,
                                options: .calculationModeCubic,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.05, animations: {
                                        self.containerView.alpha = 1
                                    })
                                    UIView.addKeyframe(withRelativeStartTime: 0.8, relativeDuration: 0.2, animations: {
                                        self.containerView.alpha = 0
                                    })
        },
                                completion: { completed in
                                    self.containerView.isHidden = true
                                    self.containerView.removeFromSuperview()
                                    self.animating = false
        })
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
