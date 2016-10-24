//
//  CKPhotoGalleryTransitioning.swift
//  Pods
//
//  Created by mac on 16/10/18.
//
//

import UIKit

class CKPhotoGalleryBaseTransition: NSObject, UIViewControllerAnimatedTransitioning {
    var animateDuration :TimeInterval = 0.5
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
    }
    
    
    func animationEnded(_ transitionCompleted: Bool) {
        
    }
    
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    

}
