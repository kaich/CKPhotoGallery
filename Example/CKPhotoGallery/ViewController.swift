//
//  ViewController.swift
//  CKPhotoGallery
//
//  Created by kaich on 10/17/2016.
//  Copyright (c) 2016 kaich. All rights reserved.
//

import UIKit
import CKPhotoGallery

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        let photsController = CKPhotosController.createPhotosController(target: self)
        photsController.imageUrls = ["http://a1.mzstatic.com/us/r30/Purple128/v4/6c/6a/09/6c6a09d8-f83b-49c9-74a4-e75fd599d2b1/screen696x696.jpeg","http://a3.mzstatic.com/us/r30/Purple128/v4/65/8f/88/658f88f9-5ee6-af82-7b1c-9b2775ac1707/screen696x696.jpeg","http://a1.mzstatic.com/us/r30/Purple118/v4/96/7c/3f/967c3f11-cd75-46b9-44b4-8403bf0322bc/screen696x696.jpeg","http://a1.mzstatic.com/us/r30/Purple128/v4/b5/1d/85/b51d85a6-a356-9d23-58bd-b62750b388ae/screen696x696.jpeg","http://a1.mzstatic.com/us/r30/Purple/v4/cc/8a/16/cc8a16db-3c31-8f23-a921-2672b34f9883/screen520x924.jpeg"].map({ (urlStr) -> URL in
            return URL(string: urlStr)!
        })
        photsController.view.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 300)
        photsController.estimatedHeight = 300
        photsController.isZoomTranstion = false
        view.addSubview(photsController.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

