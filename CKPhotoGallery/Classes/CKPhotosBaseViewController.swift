//
//  CKPhotosBaseViewController.swift
//  Pods
//
//  Created by mac on 16/10/17.
//
//

import UIKit
import Kingfisher

let HexColor = {(hex :Int, alpha :Float) in return UIColor.init(colorLiteralRed: ((Float)((hex & 0xFF0000) >> 16))/255.0, green: ((Float)((hex & 0xFF00) >> 8))/255.0, blue: ((Float)(hex & 0xFF))/255.0, alpha: alpha) }

public extension UIImage {
    static func make(name: String) -> UIImage? {
        let bundle = Bundle(for: CKPhotosBaseViewController.self)
        let imageName = "CKPhotoGallery.bundle/\(name)"
        return UIImage(named: imageName , in: bundle, compatibleWith: nil)
    }
}


public class CKPhotosBaseViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    var duration :TimeInterval = 0.5
    public var imageUrls = [URL]()
    
    struct CKImageInformation {
        var url :URL?
        var size = CGSize(width: 0, height: 0)
        var orientation :UIImageOrientation
    }
    
    var imageInformationDic = [Int : CKImageInformation]()
    let CellIdentifier = "CKPhotoCollectionViewCell"
    
    
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        collectionView?.backgroundColor = UIColor.clear
        collectionView?.showsHorizontalScrollIndicator = false
        collectionView?.register(CKPhotoBaseCollectionViewCell.self, forCellWithReuseIdentifier: CellIdentifier)
        
        preloadImages(urls: imageUrls)
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func preloadImages(urls :[URL]) {
        
        let count = urls.count
        var loadedCount :Int = 0
        for url in urls {
            let resource = ImageResource(downloadURL: url)
            KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil, completionHandler: { (image, error, type, url) in
                if let image = image, let url = url {
                    let imageInfo = CKImageInformation(url: url, size: image.size, orientation: image.imageOrientation)
                    let index = self.imageUrls.index(of: url)
                    self.imageInformationDic[index!] = imageInfo
                    loadedCount += 1
                }
                
                if loadedCount == count {
                    self.collectionView?.reloadData()
                }
            })
        }
        
    }
    
    //MARK: - UICollectionViewController UICollectionViewDelegateFlowLayout Delegate Datasource
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageInformationDic.count
    }
    
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath)
        if let cell = cell as? CKPhotoBaseCollectionViewCell {
            let resource = ImageResource(downloadURL: imageUrls[indexPath.row])
            cell.ivImage.kf.setImage(with: resource, placeholder: nil, options: nil, progressBlock: nil, completionHandler: nil)
        }
        return cell
    }
    
    //MARK: -  UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.contentSize.height
        let tmpImageinfo = imageInformationDic[indexPath.row]
        
        guard let imageinfo = tmpImageinfo else {
            return CGSize(width: 0, height: 0)
        }
        
        let imageSize = imageinfo.size
        let imageWidth = imageSize.width / imageSize.height * (height - 16)
        let width = imageWidth + 16
        
        return CGSize(width: width , height: height)
    }
    
    
}


class CKPhotoBaseCollectionViewCell: UICollectionViewCell {
    var ivImage = UIImageView(image: UIImage.make(name: "nullData_icon_Img_80x80"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(ivImage)
        ivImage.translatesAutoresizingMaskIntoConstraints = false
        ivImage.layer.borderColor = HexColor(0xbbbbbb, 1).cgColor
        ivImage.layer.borderWidth = 1 / UIScreen.main.scale
        ivImage.layer.cornerRadius = 3
        ivImage.layer.masksToBounds = true
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-[imageView]-|", options: .alignAllFirstBaseline, metrics: nil, views:["imageView" : ivImage] )
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-[imageView]-|", options: .alignAllFirstBaseline, metrics: nil, views:["imageView" : ivImage] )
        let constraints = hConstraints + vConstraints
        contentView.addConstraints(constraints)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //forces the system to do one layout pass
    var isHeightCalculated: Bool = false
}
