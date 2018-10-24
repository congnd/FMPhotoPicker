//
//  FMPhotoInteractionAnimator.swift
//  FMPhotoPicker
//
//  Created by c-nguyen on 2018/02/06.
//  Copyright © 2018 Tribal Media House. All rights reserved.
//

import UIKit

class FMPhotoInteractionAnimator: NSObject, UIViewControllerInteractiveTransitioning {
    var interactionInProgress = false
    
    private var shouldCompleteTransition = false
    private weak var viewController: FMPhotoPresenterViewController!
    lazy private var panGestureRecognizer: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handleGesture(_:)))
        
        // So important to prevent unexpected behavior when mixing GestrureRecognizer and touchesBegan
        // especially when a touch event occur near edge of the screen where the system menu recognizer is also handing.
        pan.cancelsTouchesInView = false
        return pan
    }()
    
    private var transitionContext: UIViewControllerContextTransitioning?
    var animator: UIViewControllerAnimatedTransitioning?
    
    init(viewController: FMPhotoPresenterViewController) {
        super.init()
        self.viewController = viewController
        self.viewController.view.addGestureRecognizer(self.panGestureRecognizer)
    }
    
    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        self.transitionContext = transitionContext
    }
    
    public func enable() {
        self.panGestureRecognizer.isEnabled = true
    }
    
    public func disable() {
        self.panGestureRecognizer.isEnabled = false
    }
    
    @objc func handleGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        let translation = gestureRecognizer.translation(in: gestureRecognizer.view!.superview!)
        var progress = (translation.x / 200)
        progress = CGFloat(fminf(fmaxf(Float(progress), 0.0), 1.0))
        
        if gestureRecognizer.state == .began {
            interactionInProgress = true
            viewController.dismiss(animated: true, completion: nil)
        } else {
            self.handlePanWithPanGestureRecognizer(gestureRecognizer,
                                                   viewToPan: self.viewController.pageViewController.view,
                                                   anchorPoint:  CGPoint(x: self.viewController.view.bounds.midX,
                                                                         y: self.viewController.view.bounds.midY))
        }
    }
    
    func handlePanWithPanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer, viewToPan: UIView, anchorPoint: CGPoint) {
        guard let fromView = transitionContext?.view(forKey: UITransitionContextViewKey.from) else {
            return
        }
        let translatedPanGesturePoint = gestureRecognizer.translation(in: fromView)
        let newCenterPoint = CGPoint(x: anchorPoint.x + translatedPanGesturePoint.x, y: anchorPoint.y + translatedPanGesturePoint.y)
        
        viewToPan.center = newCenterPoint
        
        let verticalDelta = newCenterPoint.y - anchorPoint.y
        let backgroundAlpha = backgroundAlphaForPanningWithVerticalDelta(verticalDelta)
        fromView.backgroundColor = fromView.backgroundColor?.withAlphaComponent(backgroundAlpha)
//        self.viewController.view.alpha = CGFloat(backgroundAlpha)
        
        if gestureRecognizer.state == .ended {
            interactionInProgress = false
            finishPanWithPanGestureRecognizer(gestureRecognizer, verticalDelta: verticalDelta,viewToPan: viewToPan, anchorPoint: anchorPoint)
        }
    }
    
    func finishPanWithPanGestureRecognizer(_ gestureRecognizer: UIPanGestureRecognizer, verticalDelta: CGFloat, viewToPan: UIView, anchorPoint: CGPoint) {
        guard let fromView = transitionContext?.view(forKey: UITransitionContextViewKey.from) else {
            return
        }
        let returnToCenterVelocityAnimationRatio = 0.00007
        let panDismissDistanceRatio = 50.0 / 667.0 // distance over iPhone 6 height
        let panDismissMaximumDuration = 0.45
        
        let velocityY = gestureRecognizer.velocity(in: gestureRecognizer.view).y
        
        var animationDuration = (Double(abs(velocityY)) * returnToCenterVelocityAnimationRatio) + 0.2
        var animationCurve: UIView.AnimationOptions = .curveEaseOut
        var finalPageViewCenterPoint = anchorPoint
        var finalBackgroundAlpha = 1.0
        
        let dismissDistance = panDismissDistanceRatio * Double(fromView.bounds.height)
        let isDismissing = Double(abs(verticalDelta)) > dismissDistance
        
        var didAnimateUsingAnimator = false
        
        if isDismissing {
            if let animator = self.animator, let transitionContext = transitionContext {
                animator.animateTransition(using: transitionContext)
                didAnimateUsingAnimator = true
            } else {
                let isPositiveDelta = verticalDelta >= 0
                let modifier: CGFloat = isPositiveDelta ? 1 : -1
                let finalCenterY = fromView.bounds.midY + modifier * fromView.bounds.height
                finalPageViewCenterPoint = CGPoint(x: fromView.center.x, y: finalCenterY)
                
                animationDuration = Double(abs(finalPageViewCenterPoint.y - viewToPan.center.y) / abs(velocityY))
                animationDuration = min(animationDuration, panDismissMaximumDuration)
                animationCurve = .curveEaseOut
                finalBackgroundAlpha = 0.0
            }
        }
        
        if didAnimateUsingAnimator {
            self.transitionContext = nil
        } else {
            UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurve, animations: { () -> Void in
                viewToPan.center = finalPageViewCenterPoint
                fromView.backgroundColor = fromView.backgroundColor?.withAlphaComponent(CGFloat(finalBackgroundAlpha))
            }, completion: { finished in
                if isDismissing {
                    self.transitionContext?.finishInteractiveTransition()
                } else {
                    self.transitionContext?.cancelInteractiveTransition()
                }
                
                self.transitionContext?.completeTransition(isDismissing && !(self.transitionContext?.transitionWasCancelled ?? false))
                self.transitionContext = nil
            })
        }
    }
    
    private func backgroundAlphaForPanningWithVerticalDelta(_ delta: CGFloat) -> CGFloat {
        return 1 - min(abs(delta) / 400, 1.0)
    }
}

