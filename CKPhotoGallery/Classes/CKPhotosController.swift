//
//  CKPhotosController.swift
//  Pods
//
//  Created by mac on 16/10/17.
//
//

import UIKit
import DZNEmptyDataSet

public class CKPhotosController: CKPhotosBaseViewController, DZNEmptyDataSetDelegate, DZNEmptyDataSetSource {
    
    public var isZoomTranstion = true
    
    /// 创建CKPhotosController实例
    ///
    /// - returns: 创建的实例
    public class func createPhotosController(target :UIViewController) -> CKPhotosController {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        flowLayout.minimumInteritemSpacing = 0;
        flowLayout.minimumLineSpacing = 0;
        let vc = CKPhotosController(collectionViewLayout: flowLayout)
        target.addChildViewController(vc)
        return vc
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView?.emptyDataSetDelegate = self
        collectionView?.emptyDataSetSource = self
  
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //MARK: - UICollectionViewController UICollectionViewDelegateFlowLayout Delegate Datasource
    
    public override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? CKPhotoBaseCollectionViewCell {
            let vc = CKPhotoGalleryViewController()
            vc.urls =  imageUrls
            vc.currentIndex =  indexPath.row
            if isZoomTranstion {
                vc.referenceView = cell.ivImage
                vc.dismissReferenceBlock = { (index) in
                    let finalIndexPath = IndexPath(row: index, section: 0)
                    let finalCell = collectionView.cellForItem(at: finalIndexPath) as? CKPhotoBaseCollectionViewCell
                    return finalCell?.ivImage
                }
            }
            present(vc, animated: true, completion: nil)
        }
    }
    
    //MARK: -  DZNEmptyDataSetDelegate , DZNEmptyDataSetSource
    public func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        let image = UIImage.make(name: "nullData_icon_Img_80x80")
        return image
    }
    
    public func emptyDataSetShouldAllowTouch(_ scrollView: UIScrollView!) -> Bool {
        return true
    }
    
    public func emptyDataSet(_ scrollView: UIScrollView!, didTap view: UIView!) {
        preloadImages(urls: imageUrls)
    }
}
