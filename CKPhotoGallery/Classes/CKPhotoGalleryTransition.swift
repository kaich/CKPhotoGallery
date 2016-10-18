//
//  CKPhotoGalleryTransition.swift
//  Pods
//
//  Created by mac on 16/10/18.
//
//

import UIKit


class CKPhotoGalleryTransition: CKPhotoGalleryBaseTransition {
    var isDimissing :Bool = false
    var begingView :UIView?
    var endingView :UIView?

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
       zoomAnimate(uring: transitionContext)
    }


    func zoomAnimate(uring transitionContext: UIViewControllerContextTransitioning) {
        guard let begingView = begingView, let endingView = endingView else {
           return
        }
        
        let containerView = transitionContext.containerView
        
        guard let fromViewController = transitionContext.viewController(forKey: .from), let toViewController = transitionContext.viewController(forKey: .to) else {
            return 
        }
        
        containerView.backgroundColor = UIColor.clear
        
//        let scale = endingView.frame.width / begingView.frame.width

        if !isDimissing {
            
            containerView.addSubview(toViewController.view)
            
            UIView.animate(withDuration: 0.3, animations: {
                toViewController.view.alpha = 1
                }) { (isFinish) in
                    let wasCancelled = transitionContext.transitionWasCancelled
                    transitionContext.completeTransition(!wasCancelled)
            }
        }
        else {
            containerView.bringSubview(toFront: toViewController.view)
            
            UIView.animate(withDuration: 0.3, animations: {
                toViewController.view.alpha = 1
            }) { (isFinish) in
                let wasCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!wasCancelled)
            }
        }
        
    }
}


extension UIView {
    func ins_snapshotView() -> UIView {
        if let contents = layer.contents {
            var snapshotedView: UIView!
            
            if let view = self as? UIImageView {
                snapshotedView = type(of: view).init(image: view.image)
                snapshotedView.bounds = view.bounds
            } else {
                snapshotedView = UIView(frame: frame)
                snapshotedView.layer.contents = contents
                snapshotedView.layer.bounds = layer.bounds
            }
            snapshotedView.layer.cornerRadius = layer.cornerRadius
            snapshotedView.layer.masksToBounds = layer.masksToBounds
            snapshotedView.contentMode = contentMode
            snapshotedView.transform = transform
            
            return snapshotedView
        } else {
            return snapshotView(afterScreenUpdates: true)!
        }
    }
    
    func ins_translatedCenterPointToContainerView(_ containerView: UIView) -> CGPoint {
        var centerPoint = center
        
        // Special case for zoomed scroll views.
        if let scrollView = self.superview as? UIScrollView , scrollView.zoomScale != 1.0 {
            centerPoint.x += (scrollView.bounds.width - scrollView.contentSize.width) / 2.0 + scrollView.contentOffset.x
            centerPoint.y += (scrollView.bounds.height - scrollView.contentSize.height) / 2.0 + scrollView.contentOffset.y
        }
        return self.superview?.convert(centerPoint, to: containerView) ?? CGPoint.zero
    }
}
