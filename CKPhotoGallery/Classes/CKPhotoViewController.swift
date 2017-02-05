//
//  CKPhotoViewController.swift
//  Pods
//
//  Created by mac on 16/10/17.
//
//

import UIKit
import Kingfisher

class CKPhotoViewController: UIViewController, UIScrollViewDelegate {
    var url :URL?

    lazy var scalingImageView :CKScalingImageView = {
        let imageView = CKScalingImageView(frame: self.view.bounds)
        imageView.delegate = self
        self.view.addSubview(imageView)
        return imageView
    }()
    
    init(url :URL) {
        self.url = url
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear
        scalingImageView.backgroundColor = UIColor.clear
        scalingImageView.translatesAutoresizingMaskIntoConstraints = false
        let resource = ImageResource(downloadURL: url!)
        scalingImageView.imageView.kf.setImage(with: resource, placeholder: UIImage.make(name:"nullData_icon_Img_40x40"), options: nil, progressBlock: nil, completionHandler: nil);
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scalingImageView.frame = view.bounds
    }
    
    // MARK:- UIScrollViewDelegate
    
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return scalingImageView.imageView
    }
    
    open func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        scrollView.panGestureRecognizer.isEnabled = true
    }
    
    open func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        // There is a bug, especially prevalent on iPhone 6 Plus, that causes zooming to render all other gesture recognizers ineffective.
        // This bug is fixed by disabling the pan gesture recognizer of the scroll view when it is not needed.
        if (scrollView.zoomScale == scrollView.minimumZoomScale) {
            scrollView.panGestureRecognizer.isEnabled = false;
        }
    }

}
