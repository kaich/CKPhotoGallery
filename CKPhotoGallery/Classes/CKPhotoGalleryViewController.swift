//
//  CKPhotoGalleryViewController.swift
//  Pods
//
//  Created by mac on 16/10/17.
//
//

import UIKit

class CKPhotoGalleryViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIViewControllerTransitioningDelegate {
    var urls = [URL]()
    var referenceView :UIImageView?
    var dismissReferenceBlock :((Int) -> UIImageView?)?
    var duration :TimeInterval?
    var currentIndex :Int = 0 {
        didSet {
           pageControl.currentPage = currentIndex
        }
    }
    
    fileprivate var currentViewController :CKPhotoViewController {
        return self.pageViewController.viewControllers?.first as! CKPhotoViewController
    }
    fileprivate lazy var pageViewController :UIPageViewController = {
        let tmpPageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 16.0])
        tmpPageController.view.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.8)
        tmpPageController.delegate = self
        tmpPageController.dataSource = self
        tmpPageController.setViewControllers([self.createPhotoViewControllerForPhoto(self.urls[self.currentIndex])], direction: .forward, animated: true, completion: nil)
        return tmpPageController
    }()
    fileprivate lazy var pageControl :UIPageControl = UIPageControl(frame: CGRect(x: (UIScreen.main.bounds.width - 220)/2, y: UIScreen.main.bounds.height - 60, width: 220, height: 40))
    
    init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .custom
        transitioningDelegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        view.backgroundColor = UIColor.clear

        addChildViewController(pageViewController)
        view.addSubview(pageViewController.view)
        
        pageControl.numberOfPages = self.urls.count
        pageControl.currentPage = currentIndex
        pageControl.pageIndicatorTintColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.6)
        pageControl.isUserInteractionEnabled = false
        self.view.addSubview(pageControl)
        
        // Add tap gesutre to dimimss
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(tapView(gesture:)))
        view.addGestureRecognizer(tapGesture)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func createPhotoViewControllerForPhoto(_ url: URL) -> CKPhotoViewController {
        let photoViewController = CKPhotoViewController(url: url)

        return photoViewController
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        view.frame = UIScreen.main.bounds
        pageViewController.view.frame = view.frame
    }
    
    //MARK: - Gesture
    func tapView(gesture :UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - UIPageViewControllerDataSource  UIPageViewControllerDelegate
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? CKPhotoViewController {
            currentIndex = urls.index(of: viewController.url!)!
        }
        if currentIndex - 1 < 0 {
            return nil
        }
        return createPhotoViewControllerForPhoto(urls[currentIndex - 1])
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let viewController = viewController as? CKPhotoViewController {
            currentIndex = urls.index(of: viewController.url!)!
        }
        if currentIndex + 1 >= urls.count {
            return nil
        }
        return createPhotoViewControllerForPhoto(urls[currentIndex + 1])
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if let dismissReferenceBlock = dismissReferenceBlock {
            if let previousVC = previousViewControllers.first as? CKPhotoViewController {
                let previousIndex = urls.index(of: previousVC.url!)
                let previousView = dismissReferenceBlock(previousIndex!)
                previousView?.alpha = 1
            }
            //currentIndex property can't use in this function. UIPageViewController is a black box.
            let index = urls.index(of: currentViewController.url!)
            let dismissReferenceView = dismissReferenceBlock(index!)
            dismissReferenceView?.alpha = 0
        }
    }
    
    //MARK: - UIViewControllerTransitioningDelegate
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animatedTransition = CKPhotoGalleryZoomTransition()
        animatedTransition.beginingView = referenceView
        animatedTransition.endingView = currentViewController.scalingImageView.imageView
        animatedTransition.isDimissing = false
        if let duration = duration {
            animatedTransition.animateDuration = duration
        }
        
        if let beginingView = animatedTransition.beginingView as? UIImageView , let endingView = animatedTransition.endingView as? UIImageView {
            if let beginingImage = beginingView.image , let endingImage = endingView.image {
                if beginingImage.imageOrientation.rawValue != endingImage.imageOrientation.rawValue  {
                    animatedTransition.rotationRadians = CGFloat(Float.pi / 2 * 3)
                }
            }
        }
        return animatedTransition
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let animatedTransition = CKPhotoGalleryZoomTransition()
        if let dismissReferenceBlock = dismissReferenceBlock {
            //because currentIndex isn't very accurate
            if let index =  urls.index(of: currentViewController.url!) {
                animatedTransition.endingView = dismissReferenceBlock(index)
            }
        }
        animatedTransition.beginingView = currentViewController.scalingImageView.imageView
        animatedTransition.isDimissing = true
        if let duration = duration {
            animatedTransition.animateDuration = duration
        }
        
        if let beginingView = animatedTransition.beginingView as? UIImageView , let endingView = animatedTransition.endingView as? UIImageView {
            if let beginingImage = beginingView.image , let endingImage = endingView.image {
                if beginingImage.imageOrientation.rawValue != endingImage.imageOrientation.rawValue  {
                    animatedTransition.rotationRadians = CGFloat(Float.pi / 2)
                }
            }
        }
        return animatedTransition
    }
    
}
