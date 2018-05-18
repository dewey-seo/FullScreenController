//
//  PhotoCell.swift
//  FullScreenImageViewController
//
//  Created by dewey on 2018. 3. 20..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import AlamofireImage

class PhotoCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var thumbImageURL: URL?
    var originImageURL:URL?
    
    var data: [String:URL]? {
        didSet {
            if let data = data {
                if let thumbImageURL = data["thumb"] {
                    self.thumbImageURL = thumbImageURL
                    self.imageView.sd_setImage(with: thumbImageURL, completed: nil)
                }
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
