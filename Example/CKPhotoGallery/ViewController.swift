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

        let photsController = CKPhotosController.createPhotosController()
//        "http://d.image.i4.cn/image/screenshot/iphone/2016/10/14/16/1141118819/z1476432841275_523205.jpeg",
        photsController.imageUrls = ["http://d.image.i4.cn/image/screenshot/iphone/2016/10/10/17/417200582/z1476090601337_426931.jpeg","http://d.image.i4.cn/image/screenshot/iphone/2016/10/10/17/417200582/z1476090601337_159721.jpeg","http://d.image.i4.cn/image/screenshot/iphone/2016/10/10/17/417200582/z1476090601337_379763.jpeg","http://d.image.i4.cn/image/screenshot/iphone/2016/10/10/17/417200582/z1476090601337_153900.jpeg","http://d.image.i4.cn/image/screenshot/iphone/2016/10/10/17/417200582/z1476090601337_909646.jpeg"].map({ (urlStr) -> URL in
            return URL(string: urlStr)!
        })
        photsController.view.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: 300)
        view.addSubview(photsController.view)
        self.addChildViewController(photsController)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

