//
//  FMCropTranslucencyView.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/03/08.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

enum FMCropTranslucencyStatus {
    case show
    case hide
    case beingShow
    case beingHide
    case scheduledShow
}

class FMCropTranslucencyView: UIVisualEffectView {
    private let showAlpha: CGFloat = 1.0
    private let hideAlpha: CGFloat = 0.5
    
    public var status: FMCropTranslucencyStatus
    
    private var timer: Timer?

    override init(effect: UIVisualEffect?) {
        status = .show
        super.init(effect: effect)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    public func scheduleShowing() {
        if status == .show || status == .beingShow {
            return
        }
        
        if status == .scheduledShow {
            timer?.invalidate()
            timer = nil
        }
        
        layer.removeAllAnimations()
        status = .scheduledShow
        timer = Timer.scheduledTimer(timeInterval: 0.8,
                                     target: self,
                                     selector: #selector(show),
                                     userInfo: nil,
                                     repeats: false)
    }
    
    // MARK: - show/hide translucent view
    @objc private func show() {
        status = .beingShow
        UIView.animate(withDuration: kEnteringAnimationDuration,
                       animations: {
                        self.alpha = self.showAlpha
        },
                       completion: { _ in
                        self.status = .show
        })
    }
    
    private func hide() {
        status = .beingHide
        layer.removeAllAnimations()
        UIView.animate(withDuration: kLeavingAnimationDuration,
                       animations: {
                        self.alpha = self.hideAlpha
        },
                       completion: { _ in
                        self.status = .hide
        })
    }
    
    public func safetyHide() {
        if status != .beingHide && status != .hide {
            timer?.invalidate()
            hide()
        }
    }
    
    public func safetyShow() {
        if status == .scheduledShow {
            timer?.invalidate()
            timer = nil
        }
        if status != .show && status != .beingShow {
            show()
        }
    }
}
