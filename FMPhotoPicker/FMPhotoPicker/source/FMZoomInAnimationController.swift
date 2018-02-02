//
//  FMZoomInAnimationController.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/26.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMZoomInAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    private let originFrame: CGRect
    
    init(originFrame: CGRect) {
        self.originFrame = originFrame
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        let containerView = transitionContext.containerView
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        containerView.addSubview(toVC.view)
        toVC.view.translatesAutoresizingMaskIntoConstraints = false
        toVC.view.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
        toVC.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor).isActive = true
        toVC.view.leftAnchor.constraint(equalTo:  containerView.leftAnchor).isActive = true
        toVC.view.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        toVC.view.layoutIfNeeded()
        
        guard let snapshot = toVC.view.snapshotView(afterScreenUpdates: true) else { return }
        
        snapshot.frame = originFrame
        snapshot.layer.masksToBounds = true
        
        containerView.addSubview(snapshot)
        toVC.view.isHidden = true
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0,
                                options: .calculationModeCubic,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1) {
                                        snapshot.frame = finalFrame
                                        snapshot.layer.cornerRadius = 0
                                    }
        },
                                completion: { _ in
                                    toVC.view.isHidden = false
                                    snapshot.removeFromSuperview()
                                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
}
