//
//  CKPhotoGalleryFadeTransition.swift
//  Pods
//
//  Created by mac on 16/10/18.
//
//

import UIKit

class CKPhotoGalleryFadeTransition: CKPhotoGalleryBaseTransition {
    var isDimissing :Bool = false
    
    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        fadeAnimate(uring: transitionContext)
    }
    
    func fadeAnimate(uring transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        
        guard let fromViewController = transitionContext.viewController(forKey: .from), let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        containerView.backgroundColor = UIColor.clear
        
        if !isDimissing {
            
            containerView.addSubview(toViewController.view)
            
            toViewController.view.alpha = 0
            UIView.animate(withDuration: 0.3, animations: {
                toViewController.view.alpha = 1
            }) { (isFinish) in
                let wasCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!wasCancelled)
            }
        }
        else {
            containerView.bringSubview(toFront: toViewController.view)
            
            fromViewController.view.alpha = 1
            UIView.animate(withDuration: 0.3, animations: {
                fromViewController.view.alpha = 0
            }) { (isFinish) in
                let wasCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!wasCancelled)
            }
        }
    }
    
}
