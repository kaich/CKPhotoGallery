//
//  CKScalingImageView.swift
//  Pods
//
//  Created by mac on 16/10/17.
//
//

import UIKit
private func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

class CKScalingImageView: UIScrollView {
    fileprivate let imageViewImageKeyPath = "imageView.image"
    
    lazy var imageView: UIImageView = {
        let imageView = UIImageView(frame: self.bounds)
        self.addSubview(imageView)
        return imageView
    }()
    
    var image: UIImage? {
        didSet {
            updateImage(image)
        }
    }
    
    override var frame: CGRect {
        didSet {
            updateZoomScale()
            centerScrollViewContents()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addObserver(self, forKeyPath: imageViewImageKeyPath, options: .new, context: nil)
        setupImageScrollView()
        updateZoomScale()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupImageScrollView()
        updateZoomScale()
    }
    
    deinit {
        removeObserver(self, forKeyPath: "imageView.image")
    }
    
    override func didAddSubview(_ subview: UIView) {
        super.didAddSubview(subview)
        centerScrollViewContents()
    }
    
    private func setupImageScrollView() {
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false;
        bouncesZoom = true;
        decelerationRate = UIScrollViewDecelerationRateFast;
    }
    
    func centerScrollViewContents() {
        var horizontalInset: CGFloat = 0;
        var verticalInset: CGFloat = 0;
        
        if (contentSize.width < bounds.width) {
            horizontalInset = (bounds.width - contentSize.width) * 0.5;
        }
        
        if (self.contentSize.height < bounds.height) {
            verticalInset = (bounds.height - contentSize.height) * 0.5;
        }
        
        if (window?.screen.scale < 2) {
            horizontalInset = floor(horizontalInset);
            verticalInset = floor(verticalInset);
        }
        
        // Use `contentInset` to center the contents in the scroll view. Reasoning explained here: http://petersteinberger.com/blog/2013/how-to-center-uiscrollview/
        self.contentInset = UIEdgeInsetsMake(verticalInset, horizontalInset, verticalInset, horizontalInset);
    }
    
    private func updateImage(_ image: UIImage?) {
        let size = image?.size ?? CGSize.zero
        
        imageView.transform = CGAffineTransform.identity
        imageView.frame = CGRect(origin: CGPoint.zero, size: size)
        self.contentSize = size
        
        updateZoomScale()
        centerScrollViewContents()
    }
    
    private func updateZoomScale() {
        if let image = imageView.image {
            let scrollViewFrame = self.bounds
            let scaleWidth = scrollViewFrame.size.width / image.size.width
            let scaleHeight = scrollViewFrame.size.height / image.size.height
            let minimumScale = min(scaleWidth, scaleHeight)
            
            self.minimumZoomScale = minimumScale
            self.maximumZoomScale = max(minimumScale, self.maximumZoomScale)
            
            self.zoomScale = minimumZoomScale
            
            // scrollView.panGestureRecognizer.enabled is on by default and enabled by
            // viewWillLayoutSubviews in the container controller so disable it here
            // to prevent an interference with the container controller's pan gesture.
            //
            // This is enabled in scrollViewWillBeginZooming so panning while zoomed-in
            // is unaffected.
            self.panGestureRecognizer.isEnabled = false
        }
    }
    
    //MARK: - Observer 
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == imageViewImageKeyPath {
           image = imageView.image
        }
    }
}
