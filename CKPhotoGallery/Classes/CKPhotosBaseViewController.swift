//
//  CKPhotosBaseViewController.swift
//  Pods
//
//  Created by mac on 16/10/17.
//
//

import UIKit
import Kingfisher

let HexColor = {(hex :Int, alpha :CGFloat) in return UIColor(red: ((CGFloat)((hex & 0xFF0000) >> 16))/255.0, green: ((CGFloat)((hex & 0xFF00) >> 8))/255.0, blue: ((CGFloat)(hex & 0xFF))/255.0, alpha: alpha) }

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
    public var sizeByURLBlock :((URL) -> CGSize)? = { _ in return CGSize.zero }
    public var videoURLByURLBlock :((URL) -> URL?) = { _ in return nil }
    //图片加载完成(isVertical ，finalSize)
    public var imageLoadCompleteBlock :((Bool, CGSize) -> Void)?
    public var estimatedHeight :CGFloat = 0
    public var horhorizonalPadding :CGFloat = 0
    
    struct CKImageInformation {
        var url :URL?
        var size = CGSize(width: 0, height: 0)
        var orientation :UIImageOrientation
    }
    
    var imageInformationDic = [Int : CKImageInformation]()
    let CellIdentifier = "CKPhotoCollectionViewCell"
    
    var retryTimes = 0
    
    var isVertical = false
    var finalSize = CGSize.zero
    
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
    
    func calculateSize(imageInformDic :[Int : CKImageInformation]) {
        self.imageInformationDic = imageInformDic
        var sampleSize = CGSize.zero
        var sampleDic: [CGFloat : (Int, CGSize)] = [:]
        for  (_, inform) in self.imageInformationDic {
            if inform.size.height > inform.size.width {
                self.isVertical = true
            }
            sampleSize = inform.size
            let scale = sampleSize.width / sampleSize.height < 1 ? sampleSize.width / sampleSize.height : sampleSize.height / sampleSize.width
            if let (times, size) = sampleDic[scale] {
                sampleDic[scale] = (times + 1, size)
            }
            else {
                sampleDic[scale] = (1, inform.size)
            }
        }
        
        var maxValue: (Int, CGSize)? = nil
        for (_ , (times , size)) in sampleDic {
            if let (maxTimes , _) = maxValue {
                if times > maxTimes {
                    maxValue = (times,size)
                }
            }
            else {
                maxValue = (times, size)
            }
            
        }
        if let maxValue = maxValue {
            (_ ,sampleSize) = maxValue
        }
        
        if self.isVertical {
            let height = self.estimatedHeight - 16
            let scale = sampleSize.width / sampleSize.height < 1 ? sampleSize.width / sampleSize.height : sampleSize.height / sampleSize.width
            let width =  height * scale
            self.finalSize = CGSize(width: width, height: height)
        }
        else {
            let width = UIScreen.main.bounds.width - self.horhorizonalPadding * 2
            let scale = sampleSize.height / sampleSize.width
            let height = width * scale
            self.finalSize = CGSize(width: width, height: height)
        }
        
        if let imageLoadCompleteBlock = self.imageLoadCompleteBlock {
            imageLoadCompleteBlock(self.isVertical,self.finalSize)
        }
        self.collectionView?.reloadData()
    }
    
    func preloadImages(urls :[URL]) {
        
        let count = urls.count
        var loadedCount :Int = 0
        var tmpImageInformationDic = [Int : CKImageInformation]()
        for url in urls {
            let backendSize = self.sizeByURLBlock!(url)
            if  backendSize == CGSize.zero {
                let resource = ImageResource(downloadURL: url)
                KingfisherManager.shared.retrieveImage(with: resource, options: nil, progressBlock: nil, completionHandler: { (image, error, type, url) in
                    if let image = image, let url = url {
                        let imageInfo = CKImageInformation(url: url, size: image.size, orientation: image.imageOrientation)
                        let index = self.imageUrls.index(of: url)
                        tmpImageInformationDic[index!] = imageInfo
                        loadedCount += 1
                    }
                    
                    if loadedCount == count {
                        self.calculateSize(imageInformDic: tmpImageInformationDic)
                    }
                    else {
                        self.retryTimes += 1
                        if self.retryTimes <= 3 {
                            self.preloadImages(urls: urls)
                        }
                    }
                })
            }
            else {
                let imageInfo = CKImageInformation(url: url, size: backendSize, orientation: .up)
                let index = self.imageUrls.index(of: url)
                tmpImageInformationDic[index!] = imageInfo
                loadedCount += 1
                
                if loadedCount == count {
                    self.calculateSize(imageInformDic: tmpImageInformationDic)
                }
            }
        }
        
    }
    
    //MARK: - UICollectionViewController UICollectionViewDelegateFlowLayout Delegate Datasource
    
    override public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageInformationDic.count
    }
    
    
    override public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CellIdentifier, for: indexPath)
        if let cell = cell as? CKPhotoBaseCollectionViewCell {
            let url = imageUrls[indexPath.row]
            let resource = ImageResource(downloadURL: url)
            cell.ivImage.kf.setImage(with: resource, placeholder: nil, options: nil, progressBlock: nil, completionHandler: { (image, error, type, url) in
                if let image = image {
                    if self.isVertical {
                        if image.size.width > image.size.height {
                            let rotatedImage = UIImage(cgImage: image.cgImage!, scale: CGFloat(1.0), orientation: .right)
                            cell.ivImage.image = rotatedImage
                        }
                    }
                    cell.ivPlaceholder.isHidden = true
                }
                else {
                    cell.ivPlaceholder.isHidden = false
                }
            })
            
            if self.videoURLByURLBlock(url) != nil {
                cell.ivTypeImage.image = UIImage.make(name: "video")
                cell.ivPlaceholder.isHidden = true
            }
            else {
                cell.ivTypeImage.image = nil
                if cell.ivImage.image != nil {
                    cell.ivPlaceholder.isHidden = true
                }
                else {
                    cell.ivPlaceholder.isHidden = false
                }
            }
        }
        return cell
    }
    
    //MARK: -  UICollectionViewDelegateFlowLayout
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.finalSize
    }
    
    
}


class CKPhotoBaseCollectionViewCell: UICollectionViewCell {
    var ivPlaceholder = UIImageView(image: UIImage.make(name: "nullData_icon_Img_40x40"))
    var ivImage = UIImageView()
    var ivTypeImage = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(ivImage)
        ivImage.translatesAutoresizingMaskIntoConstraints = false
        ivImage.layer.borderColor = HexColor(0xbbbbbb, 1).cgColor
        ivImage.layer.borderWidth = 1 / UIScreen.main.scale
        ivImage.layer.cornerRadius = 3
        ivImage.layer.masksToBounds = true
        let hConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(0)-[imageView]-(0)-|", options: .alignAllFirstBaseline, metrics: nil, views:["imageView" : ivImage] )
        let vConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|-(0)-[imageView]-(0)-|", options: .alignAllFirstBaseline, metrics: nil, views:["imageView" : ivImage] )
        let constraints = hConstraints + vConstraints
        contentView.addConstraints(constraints)
        
        ivTypeImage.backgroundColor = .clear
        ivTypeImage.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ivTypeImage)
        let widthConstraint = NSLayoutConstraint(item: ivTypeImage, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 48)
        let heightConstraint = NSLayoutConstraint(item: ivTypeImage, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 48)
        let centerXConstraint = NSLayoutConstraint(item: ivTypeImage, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)
        let centerYConstraint = NSLayoutConstraint(item: ivTypeImage, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
        ivTypeImage.addConstraints([widthConstraint,heightConstraint])
        contentView.addConstraints([centerXConstraint,centerYConstraint])
        
        
        ivPlaceholder.backgroundColor = .clear
        ivPlaceholder.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(ivPlaceholder)
        let phWidthConstraint = NSLayoutConstraint(item: ivPlaceholder, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .width, multiplier: 1, constant: 40)
        let phHeightConstraint = NSLayoutConstraint(item: ivPlaceholder, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .height, multiplier: 1, constant: 40)
        let phCenterXConstraint = NSLayoutConstraint(item: ivPlaceholder, attribute: .centerX, relatedBy: .equal, toItem: contentView, attribute: .centerX, multiplier: 1, constant: 0)
        let phCenterYConstraint = NSLayoutConstraint(item: ivPlaceholder, attribute: .centerY, relatedBy: .equal, toItem: contentView, attribute: .centerY, multiplier: 1, constant: 0)
        ivPlaceholder.addConstraints([phWidthConstraint,phHeightConstraint])
        contentView.addConstraints([phCenterXConstraint,phCenterYConstraint])
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //forces the system to do one layout pass
    var isHeightCalculated: Bool = false
}
