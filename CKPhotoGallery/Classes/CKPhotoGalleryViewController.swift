//
//  CKPhotoGalleryViewController.swift
//  Pods
//
//  Created by mac on 16/10/17.
//
//

import UIKit

enum CKPhotoGalleryTransitionStyle {
    case fade, scale
}

class CKPhotoGalleryViewController: UIViewController, UIPageViewControllerDelegate, UIPageViewControllerDataSource, UIViewControllerTransitioningDelegate {
    var urls = [URL]()
    var referenceView :UIView?
    var currentIndex :Int = 0 {
        didSet {
           pageControl.currentPage = currentIndex
        }
    }
    
    fileprivate lazy var beginViewController :CKPhotoViewController = {
        return self.createPhotoViewControllerForPhoto(self.urls[self.currentIndex])
    }()
    fileprivate lazy var pageController :UIPageViewController = {
        let tmpPageController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: [UIPageViewControllerOptionInterPageSpacingKey: 16.0])
        tmpPageController.view.backgroundColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.8)
        tmpPageController.delegate = self
        tmpPageController.dataSource = self
        tmpPageController.setViewControllers([self.beginViewController], direction: .forward, animated: true, completion: nil)
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

        view.addSubview(pageController.view)
        addChildViewController(pageController)
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = self.urls.count
        pageControl.pageIndicatorTintColor = UIColor(colorLiteralRed: 0, green: 0, blue: 0, alpha: 0.6)
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
    
    //MARK: - Gesture
    func tapView(gesture :UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - UIPageViewControllerDelegate  UIPageViewControllerDelegate
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
    
    //MARK: - UIViewControllerTransitioningDelegate
    open func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
   
        let transition = CKPhotoGalleryFadeTransition()
        transition.isDimissing = false
        return transition
    }
    
    open func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        let transition = CKPhotoGalleryFadeTransition()
        transition.isDimissing = true
        return transition
    }
    
}
