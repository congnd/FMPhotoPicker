//
//  FMZoomInAnimationController.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/01/26.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMZoomInAnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    var getOriginFrame: (() -> CGRect)!
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toVC = transitionContext.viewController(forKey: .to) as? FMPhotoPresenterViewController,
            let photoVC = toVC.pageViewController.viewControllers?.first as? FMPhotoViewController
            else { return }
        
        let containerView = transitionContext.containerView
        
        let snapshot = photoVC.scalingImageView.imageView.ins_snapshotView()
        
        let bgView = UIView(frame: containerView.frame)
        containerView.addSubview(bgView)
        containerView.addSubview(snapshot)
        snapshot.frame = self.realDestinationFrame(scaledFrame: self.getOriginFrame(), realSize: snapshot.frame.size)
        
        containerView.addSubview(toVC.view)
        containerView.addSubview(snapshot)
        
        toVC.view.isHidden = true
        
        snapshot.alpha = 0
        bgView.backgroundColor = .white
        bgView.alpha = 0
        
        let duration = transitionDuration(using: transitionContext)
        
        UIView.animateKeyframes(withDuration: duration,
                                delay: 0,
                                options: .calculationModeCubic,
                                animations: {
                                    UIView.addKeyframe(withRelativeStartTime: 0.0, relativeDuration: 0.1) {
                                        snapshot.alpha = 1
                                    }
                                    
                                    UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.9) {
                                        snapshot.frame = CGRect(x: 0, y: 0, width: photoVC.scalingImageView.imageView.frame.width, height: photoVC.scalingImageView.imageView.frame.height)
                                        snapshot.center =  containerView.center
                                    }
                                    
                                    UIView.addKeyframe(withRelativeStartTime: 0.5, relativeDuration: 0.5) {
                                        bgView.alpha = 1
                                    }
        },
                                completion: { _ in
                                    toVC.view.isHidden = false
                                    snapshot.removeFromSuperview()
                                    bgView.removeFromSuperview()
                                    transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    private func realDestinationFrame(scaledFrame: CGRect, realSize: CGSize) -> CGRect {
        let scaledSize = scaledFrame.size
        let ratio = realSize.width / realSize.height
        var x: CGFloat = 0.0
        var y: CGFloat = 0.0
        var width: CGFloat = scaledSize.width
        var height: CGFloat = scaledSize.height
        
        if ratio >= 1 {
            let scaleRatio = scaledSize.height / realSize.height
            width = realSize.width * scaleRatio
            x = -(width - scaledSize.width) / 2
        } else {
            let scaleRatio = scaledSize.width / realSize.width
            height = realSize.height * scaleRatio
            y = -(height - scaledSize.height) / 2
        }
        
        let frame = CGRect(x: scaledFrame.origin.x + x,
                           y: scaledFrame.origin.y + y,
                           width: width,
                           height: height)
        return frame
    }
}
