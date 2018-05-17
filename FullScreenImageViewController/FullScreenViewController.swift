//
//  FullScreenViewController.swift
//  FullScreenImageViewController
//
//  Created by dewey on 2018. 3. 21..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit

protocol FullScreenViewControllerProtocol: class {
    func closeButtonPressed()
}

class FullScreenViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var dataSouce: Array<[String: URL]>?
    var startIndex: Int?
    weak var delegate: FullScreenViewControllerProtocol?
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if self.dataSouce != nil, startIndex != nil {
            self.collectionView.scrollToItem(at: IndexPath(item: startIndex!, section: 0), at: .centeredHorizontally, animated: false)
            startIndex = nil
        }
    }
    
    public func getCurrentFullScreenCell() -> FullScreenCell? {
        let centerPoint = CGPoint(x: self.collectionView.center.x + self.collectionView.contentOffset.x, y: self.collectionView.center.y + self.collectionView.contentOffset.y)
        
        guard let centerIndexPath = self.collectionView.indexPathForItem(at: centerPoint)  else {
            return nil
        }
        
        if let currentCell = self.collectionView.cellForItem(at: centerIndexPath) as? FullScreenCell {
            return currentCell
        }
        
        return nil
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.isStatusBarHidden = true;
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isStatusBarHidden = false;
    }
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .black
        
        self.collectionView.register(UINib.init(nibName: "FullScreenCell", bundle: nil), forCellWithReuseIdentifier: FullScreenCell.reuseIdentifier())
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    @IBAction func closeButtonPressed(_ sender: Any) {
        if let delegate = self.delegate {
            delegate.closeButtonPressed()
        }
    }
}

//MARK: - UICollectionViewDelegate
extension FullScreenViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print("didSelect")
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
    }
}

//MARK: - UICollectionViewDelegateFlowLayout
extension FullScreenViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
}

//MARK: - UICollectionViewDataSource
extension FullScreenViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let datasource = self.dataSouce else {
            return 0;
        }
        return datasource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FullScreenCell.reuseIdentifier(), for: indexPath) as! FullScreenCell
        
        cell.data = self.dataSouce?[indexPath.row]
        
        return cell
    }
}
