//
//  FullScreenCell.swift
//  FullScreenImageViewController
//
//  Created by dewey on 2018. 3. 22..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import SDWebImage

class FullScreenCell: UICollectionViewCell {
    
    @IBOutlet weak var scrollView: UIScrollView!
    private var _placeholderImage: UIImage = UIImage()
    private var _originalImage: UIImage = UIImage()
    
    var imageView: UIImageView?
    
    var needChangeImage: Bool = false
    var placeholderImage: UIImage! {
        get {
            return _placeholderImage
        }
        
        set {
            _placeholderImage = newValue
            self.applyZoomScale(_placeholderImage, isOriginImage: false)
        }
    }
    
    var originalImage: UIImage! {
        get {
            return _originalImage
        }
        
        set {
            _originalImage = newValue
            if self.scrollView.isZooming == true {
                needChangeImage = true;
            } else {
                self.applyZoomScale(_originalImage, isOriginImage: true)
            }
        }
    }
    
    
    var data: [String: URL]? {
        didSet{
            guard let data = self.data else {
                return;
            }
            
            let thumbnailURL = data["thumb"]
            let originURL = data["origin"]
            
            var placeholderImage: UIImage? = nil
            
            // check cache
            if let image = SDImageCache.shared().imageFromMemoryCache(forKey: thumbnailURL?.absoluteString) {
                placeholderImage = image
            } else if let image = SDImageCache.shared().imageFromDiskCache(forKey: thumbnailURL?.absoluteString) {
                placeholderImage = image
            }
            
            if let oldImageView = self.imageView {
                if oldImageView.superview != nil {
                    oldImageView.removeFromSuperview()
                }
            }
            
            self.imageView = UIImageView()
            
            if let newImageView = self.imageView {
                self.scrollView.addSubview(newImageView)
                self.scrollView.minimumZoomScale = 1
                self.scrollView.maximumZoomScale = 1
                
                if placeholderImage != nil {
                    self.placeholderImage = placeholderImage
                }
                
                guard let downloader = SDWebImageManager.shared().imageDownloader else {return}
                downloader.executionOrder = SDWebImageDownloaderExecutionOrder(rawValue: 1)! //(last-in-first-out)
                
                downloader.downloadImage(with: originURL, options: SDWebImageDownloaderOptions(rawValue: 0), progress: { (a, b, url) in
                    print("\(url?.absoluteString ?? "unkown") : \(a) / \(b)")
                }) { (image, data, error, result) in
                    if image != nil {
                        self.originalImage = image
                    }
                }
            }
        }
    }
    
    static func reuseIdentifier() -> String! {
        return NSStringFromClass(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = 1
        self.scrollView.alwaysBounceVertical = true
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.imageView?.image = nil
        self.imageView?.alpha = 1
        
        self.needChangeImage = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func applyZoomScale(_ image:UIImage, isOriginImage:Bool) {
        DispatchQueue.main.async {
            guard let imageView = self.imageView else {return}
            
            imageView.image = image
            imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            
            // min scale
            let minXScale = self.scrollView.frame.size.width / image.size.width
            let minYScale = self.scrollView.frame.size.height / image.size.height
            let minScale = min(minXScale, minYScale)
            
            // zoom scale
            var zoomScale: CGFloat = 1.0
            let xScale = self.scrollView.frame.size.width / image.size.width
            let yScale = self.scrollView.frame.size.height / image.size.height
            zoomScale = max(min(xScale, yScale), minScale)
            
            if isOriginImage == true {
                let imageViewRect = imageView.frame
                
                let xZoomScale = imageViewRect.size.width / image.size.width
                let yZoomScale = imageViewRect.size.height / image.size.height
                zoomScale = max(min(xZoomScale, yZoomScale), minScale)
            }
            
            self.scrollView.maximumZoomScale = max(1, minScale)
            self.scrollView.minimumZoomScale = minScale
            self.scrollView.zoomScale = zoomScale
            
            self.centerContent()
        }
    }
    
    private func centerContent() {
        var insets = UIEdgeInsetsMake(0, 0, 0, 0);
        
        if self.scrollView.contentSize.width < self.bounds.width {
            insets.left = (self.bounds.width - self.scrollView.contentSize.width) * 0.5
        }
        insets.right = insets.left
        
        if self.scrollView.contentSize.height < self.bounds.height {
            insets.top = (self.bounds.height - self.scrollView.contentSize.height) * 0.5
        }
        insets.bottom = insets.top
        
        self.scrollView.contentInset = insets
    }
}

extension FullScreenCell: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerContent()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.scrollViewZoomingEnd()
        if self.needChangeImage == true {
            self.applyZoomScale(self.originalImage, isOriginImage: true)
            self.needChangeImage = false
        }
        print(#function)
        print("zoomScale: \(scale)")
    }
    
    func scrollViewZoomingEnd() {
        self.centerContent()
    }
    
}
