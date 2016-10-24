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
        photsController.imageUrls = ["http://d.image.i4.cn/image/screenshot/iphone/2016/10/20/11/461703208/z1476934081985_798684.jpeg","http://d.image.i4.cn/image/screenshot/iphone/2016/10/20/11/461703208/z1476934081985_798640.jpeg","http://d.image.i4.cn/image/screenshot/iphone/2016/10/20/11/461703208/z1476934081985_812640.jpeg","http://d.image.i4.cn/image/screenshot/iphone/2016/10/20/11/461703208/z1476934081985_024662.jpeg","http://d.image.i4.cn/image/screenshot/iphone/2016/10/20/11/461703208/z1476934081985_371781.jpeg"].map({ (urlStr) -> URL in
            return URL(string: urlStr)!
        })
        photsController.view.frame = CGRect(x: 0, y: 100, width: view.frame.width, height: 300)
        view.addSubview(photsController.view)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

