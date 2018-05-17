//
//  PhotoCell.swift
//  FullScreenImageViewController
//
//  Created by dewey on 2018. 3. 20..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import SDWebImage

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var thumbImageURL: URL?
    var originImageURL:URL?
    
    var data: [String:URL]? {
        didSet {
            if let data = data {
                self.thumbImageURL = data["thumb"]
                self.imageView.sd_setImage(with: self.thumbImageURL)
            }
        }
    }
    
    static func reuseIdentifier() -> String! {
        return "photoCell"
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}
