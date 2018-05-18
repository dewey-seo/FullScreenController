//
//  FullScreenCell.swift
//  FullScreenImageViewController
//
//  Created by dewey on 2018. 3. 22..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import SDWebImage
import Alamofire

class FullScreenCell: UICollectionViewCell {
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    var imageView: UIImageView = UIImageView()
    var needChangeImage: Bool = false
    
    var _placeholderImageImage: UIImage? = nil
    var placeholderImageIdentifier: String = ""
    var placeholderImage: UIImage? {
        get {
            return _placeholderImageImage
        }
        set {
            if let placeholderImage = newValue {
                self.applyZoomScale(placeholderImage, isOriginImage: false)
            }
            _placeholderImageImage = newValue
        }
    }
    
    var _originalImage: UIImage? = nil
    var origianlImagerIdentifier: String = ""
    var originalImage: UIImage? {
        get {
            return _originalImage
        }
        set {
            if let originalImage = newValue {
                if self.scrollView.isZooming == true {
                    needChangeImage = true;
                } else {
                    self.applyZoomScale(originalImage, isOriginImage: true)
                }
            }
            _originalImage = newValue
        }
    }
    
    var phImageDownloadToken: SDWebImageDownloadToken?
    var oriImageDownloadToken: SDWebImageDownloadToken?
    
    var data: [String: URL]? {
        didSet{
            guard let data = self.data else {return}
            guard let imageDownloader = SDWebImageManager.shared().imageDownloader else {return}
            
            if let phImageDownloadToken = self.phImageDownloadToken {
                imageDownloader.cancel(phImageDownloadToken)
            }
            
            if let thumbnailURL = data["thumb"] {
                SDWebImageManager.shared().cachedImageExists(for: thumbnailURL) { [weak self] exist in
                    if exist == true {
                        let key = SDWebImageManager.shared().cacheKey(for: thumbnailURL)
                        if let image = SDWebImageManager.shared().imageCache?.imageFromCache(forKey: key) {
                            self?.placeholderImage = image
                        }
                    } else {
                        self?.phImageDownloadToken = imageDownloader.downloadImage(with: thumbnailURL, options: SDWebImageDownloaderOptions(rawValue: 0), progress: { (rcv, size, url) in
                        }, completed: { [weak self] (image, rawData, error, finished) in
                            if let downloadedImage = image {
                                self?.placeholderImage = downloadedImage
                            }
                        })
                    }
                }
            }
            
            guard let originURL = data["origin"] else {return}
            
            self.scrollView.minimumZoomScale = 1
            self.scrollView.maximumZoomScale = 1
            
            SDWebImageManager.shared().cachedImageExists(for: originURL) { [weak self] exist in
                if exist == true {
                    let key = SDWebImageManager.shared().cacheKey(for: originURL)
                    if let image = SDWebImageManager.shared().imageCache?.imageFromCache(forKey: key) {
                        self?.originalImage = image
                    }
                } else {
                    if let oriImageDownloadToken = self?.oriImageDownloadToken {
                        imageDownloader.cancel(oriImageDownloadToken)
                    }
                    
                    self?.oriImageDownloadToken = imageDownloader.downloadImage(with: originURL, options: SDWebImageDownloaderOptions(rawValue: 0), progress: { (rcv, size, url) in
                        
                    }, completed: { [weak self] (image, rawData, error, finished) in
                        if let downloadedImage = image {
                            self?.originalImage = downloadedImage
                        }
                    })
                }
            }
        }
    }
    
    
    static func reuseIdentifier() -> String! {
        return NSStringFromClass(self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        self.scrollView.addSubview(self.imageView)
        
        self.scrollView.delegate = self
        self.scrollView.maximumZoomScale = 1
        self.scrollView.alwaysBounceVertical = true
        
        if #available(iOS 11.0, *) {
            self.scrollView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.placeholderImage = nil
        self.originalImage = nil
        
        self.imageView.image = nil
        self.imageView.alpha = 1
        
        self.needChangeImage = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    private func applyZoomScale(_ image:UIImage, isOriginImage:Bool) {
        DispatchQueue.main.async {
            self.scrollView.zoomScale = 1.0
            
            self.imageView.image = image

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
                let imageViewRect = self.imageView.frame

                let xZoomScale = imageViewRect.size.width / image.size.width
                let yZoomScale = imageViewRect.size.height / image.size.height
                zoomScale = max(min(xZoomScale, yZoomScale), minScale)
            }
            
            // init
            self.scrollView.minimumZoomScale = 1
            self.scrollView.maximumZoomScale = 1
            self.scrollView.zoomScale = 1
            self.scrollView.contentSize = image.size
            
            // set
            self.imageView.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
            self.scrollView.maximumZoomScale = max(1, minScale)
            self.scrollView.minimumZoomScale = minScale
            self.scrollView.zoomScale = zoomScale
            
            self.centerContent()
        }
    }
    
    private func centerContent() {
        var insets = UIEdgeInsetsMake(0, 0, 0, 0);

        if self.scrollView.contentSize.width < self.scrollView.frame.width {
            insets.left = (self.scrollView.bounds.width - self.scrollView.contentSize.width) * 0.5
        }
        insets.right = insets.left

        if self.scrollView.contentSize.height < self.scrollView.frame.height {
            insets.top = (self.scrollView.bounds.height - self.scrollView.contentSize.height) * 0.5
        }
        insets.bottom = insets.top

        self.scrollView.contentInset = insets
    }
}

extension FullScreenCell: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       print("\(scrollView.contentOffset.y)")
    }
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.imageView
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        self.centerContent()
    }
    
    func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        self.scrollViewZoomingEnd()
        if self.needChangeImage == true, let orinalImage = self.originalImage {
            self.applyZoomScale(orinalImage, isOriginImage: true)
            self.needChangeImage = false
        }
    }
    
    func scrollViewZoomingEnd() {
        self.centerContent()
    }
}

