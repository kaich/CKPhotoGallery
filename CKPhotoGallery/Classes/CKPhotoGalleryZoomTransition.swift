//
//  CKPhotoGalleryTransition.swift
//  Pods
//
//  Created by mac on 16/10/18.
//
//

import UIKit


class CKPhotoGalleryZoomTransition: CKPhotoGalleryBaseTransition {
    var isDimissing :Bool = false
    var beginingView :UIView?
    var endingView :UIView?
    var beginingAnimateView :UIView?
    var endingAnimateView :UIView?
    
    var shouldPerformZoomingAnimation: Bool {
        get {
            return self.beginingView != nil && self.endingView != nil
        }
    }

    override func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        setupCommon(using: transitionContext)
        if shouldPerformZoomingAnimation {
            zoomAnimate(uring: transitionContext)
        }
        fadeAnimate(transitionContext)
    }
    
    
    func setupCommon(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromViewController = transitionContext.viewController(forKey: .from), let toViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        
        let containerView = transitionContext.containerView
        
        if !isDimissing {
            containerView.addSubview(toViewController.view)
        }
        else {
            containerView.bringSubview(toFront: toViewController.view)
        }
    }
    
    
    func fadeAnimate(_ transitionContext: UIViewControllerContextTransitioning) {
        let fadeView = isDimissing ? transitionContext.view(forKey: UITransitionContextViewKey.from) : transitionContext.view(forKey: UITransitionContextViewKey.to)
        let beginningAlpha: CGFloat = isDimissing ? 1.0 : 0.0
        let endingAlpha: CGFloat = isDimissing ? 0.0 : 1.0
        
        fadeView?.alpha = beginningAlpha
        
        UIView.animate(withDuration: 0.3, animations: { () -> Void in
            fadeView?.alpha = endingAlpha
        }) { finished in
            if !self.shouldPerformZoomingAnimation {
                let wasCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!wasCancelled)
            }
        }
    }

    func zoomAnimate(uring transitionContext: UIViewControllerContextTransitioning) {
        guard let beginingView = beginingView, let endingView = endingView else {
           return
        }
        
        let containerView = transitionContext.containerView
        
        guard let fromViewController = transitionContext.viewController(forKey: .from), let toViewController = transitionContext.viewController(forKey: .to) else {
            return 
        }
        
        containerView.backgroundColor = UIColor.clear
        
        beginingAnimateView = beginingView.ck_snapshotView()
        guard  let beginingAnimateView = beginingAnimateView else {
            return
        }
        
        let beginCenter = beginingView.ck_translatedCenterPointToContainerView(containerView)
        let endCenter = endingView.ck_translatedCenterPointToContainerView(containerView)
        let scale = endingView.frame.width / beginingView.frame.width
        let finalTransform = beginingView.transform.scaledBy(x: scale, y: scale)
        
        beginingAnimateView.center = beginCenter
        containerView.addSubview(beginingAnimateView)
        beginingView.alpha = 0
        
        UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 1, options: [.allowAnimatedContent,.beginFromCurrentState], animations: {
            self.beginingAnimateView?.transform = finalTransform
            self.beginingAnimateView?.center = endCenter
            }, completion: { (isFinish) in
                if self.isDimissing {
                    endingView.alpha = 1
                }
                self.beginingAnimateView?.removeFromSuperview()
                let wasCancelled = transitionContext.transitionWasCancelled
                transitionContext.completeTransition(!wasCancelled)
        })
    
        
    }
}


extension UIView {
    func ck_snapshotView() -> UIView {
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
            return snapshotView(afterScreenUpdates: false)!
        }
    }
    
    func ck_translatedCenterPointToContainerView(_ containerView: UIView) -> CGPoint {
        var centerPoint = center
        
        // Special case for zoomed scroll views.
        if let scrollView = self.superview as? UIScrollView , scrollView.zoomScale != 1.0 {
            centerPoint.x += (scrollView.bounds.width - scrollView.contentSize.width) / 2.0 + scrollView.contentOffset.x
            centerPoint.y += (scrollView.bounds.height - scrollView.contentSize.height) / 2.0 + scrollView.contentOffset.y
        }
        return self.superview?.convert(centerPoint, to: containerView) ?? CGPoint.zero
    }
}
