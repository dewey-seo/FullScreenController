//
//  ViewController.swift
//  FullScreenImageViewController
//
//  Created by dewey on 2018. 3. 20..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSource: Array<[String:URL]> {
        if let filePath = Bundle.main.path(forResource: "imageSource", ofType: "plist") {
            if let result = NSArray(contentsOfFile: filePath) as? Array<[String:String]> {
                var dataSource: Array<[String:URL]> = Array()
                
                for dict in result {
                    guard let thumbURLStr = dict["thumb"] else {break}
                    guard let originURLStr = dict["origin"] else {break}
                    
                    guard let thumbURL = URL(string: thumbURLStr) else {break}
                    guard let originURL = URL(string: originURLStr) else {break}
                    
                    dataSource.append(["thumb":thumbURL, "origin":originURL])
                }
                
                if dataSource.count != 0 {
                    return dataSource
                }
            }
        }
        return Array()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // set collection view
        self.collectionView.register(UINib.init(nibName: "PhotoCell", bundle: nil), forCellWithReuseIdentifier: PhotoCell.reuseIdentifier())
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
}

extension ViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let targetCell = collectionView.cellForItem(at: indexPath) as? PhotoCell else {
            return;
        }

        if let currentImage = targetCell.imageView.image {
            FullScreenViewManager.sharedInstance.showFullScreen(targetCell.contentView, targetImage: currentImage, dataSource: self.dataSource, currentIndex: indexPath.row)
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 150, height: 100)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(30, 30, 30, 30)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 30
    }
}
extension ViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.dataSource.count;
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PhotoCell.reuseIdentifier(), for: indexPath) as! PhotoCell
        let data = self.dataSource[indexPath.row]

        cell.data = data

        return cell
    }
}
