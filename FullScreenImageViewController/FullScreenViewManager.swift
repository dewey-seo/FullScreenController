//
//  FullScreenViewManager.swift
//  FullScreenImageViewController
//
//  Created by dewey on 2018. 3. 21..
//  Copyright © 2018년 path. All rights reserved.
//

import UIKit
import Neon
import SDWebImage

protocol FullScreenViewManagerProtocol {
}

class FullScreenViewManager: NSObject {
    static let sharedInstance = FullScreenViewManager()
    
    var delegate: FullScreenViewManagerProtocol?
    
    var contentView = UIView()
    let baseWindow: UIWindow = UIWindow()
    
    var baseVC: FullScreenViewController?
    
    weak var targetView: UIView?
    var fakeView: UIImageView?
    
    var targetImage: UIImage?
    var dataSouce: Array<[String: URL]>?
    var startIndex: Int?
    
    override init() {
        self.baseWindow.backgroundColor = .clear
        self.baseWindow.bounds = UIScreen.main.bounds
        self.baseWindow.windowLevel = 1
        
        self.contentView = UIView()
        self.contentView.backgroundColor = .clear
        
        self.baseWindow.addSubview(self.contentView)
        self.contentView.fillSuperview()
        
        self.baseVC = FullScreenViewController(nibName: "FullScreenViewController", bundle: nil)
    }
    
    public func showFullScreen(_ targetView: UIView, targetImage: UIImage, dataSource: Array<[String: URL]>, currentIndex: Int) {
        // set
        self.targetView = targetView
        self.targetImage = targetImage
        self.dataSouce = dataSource
        self.startIndex = currentIndex
        
        if self.fakeView?.superview != nil{
            self.fakeView?.removeFromSuperview();
        }
        
        // 1>
        self.hideBaseViewController()

        // 3>
        self.showWindow()
        
        // 4>
        self.showFakeViewForStart()
        
        // 5>
        self.fakeViewMoveToCenter { (done) in
            self.showBaseViewControlelr()
            
            self.baseVC?.dataSouce = self.dataSouce
            self.baseVC?.delegate = self
            self.baseVC?.collectionView.reloadData()
            
            if self.startIndex != nil {
                self.baseVC?.startIndex = self.startIndex
            }
        }
    }
    
    public func closeFullScreen() {
        // 1>
        self.showFakeViewForEnd()
    }
    
    private func showWindow() {
        self.baseWindow.makeKeyAndVisible()
    }
    
    private func hideWindow() {
        self.showOriginalView(show: true)
        self.baseWindow.isHidden = true
    }
    
    private func showFakeViewForStart() {
        guard let targetView = self.targetView else {
            return
        }

        self.showOriginalView(show: false)

        self.fakeView = UIImageView()
        guard let fakeView = self.fakeView else { return}

        fakeView.contentMode = targetView.contentMode
        fakeView.image = self.targetImage

        let rectFromWindow = targetView.convert(targetView.bounds, to: nil)

        self.contentView.addSubview(fakeView)
        fakeView.anchorInCorner(.topLeft, xPad: rectFromWindow.origin.x, yPad: rectFromWindow.origin.y, width: rectFromWindow.size.width, height: rectFromWindow.size.height)
    }
    
    private func fakeViewMoveToCenter (completion:@escaping ((Bool) -> ())){
        guard let targetImage = self.targetImage else { return}
        
        let afterSize = self.getAspectFillSizeToFullScreen(image: targetImage, targetViewSize: self.baseWindow.bounds.size)
        
        UIView.animate(withDuration: 0.3, animations: { 
            guard let fakeView = self.fakeView else { return}
            fakeView.anchorInCenter(width: afterSize.width, height: afterSize.height)
            
            self.contentView.backgroundColor = .black
        }) { (complete) in
                completion(complete)
        }
    }
    
    private func showFakeViewForEnd() {
        if self.fakeView?.superview != nil{
            self.fakeView?.removeFromSuperview();
        }
        
        self.fakeView = UIImageView()
        
        if let currentCell = self.baseVC?.getCurrentFullScreenCell(), self.targetView != nil {
            if let currentImageView = currentCell.imageView {
                let fromRect = currentImageView.convert(currentImageView.bounds, to: nil)
                let toRect = self.targetView?.convert((self.targetView?.bounds)!, to: nil) // check
                
                currentImageView.alpha = 0
                self.baseWindow.addSubview(self.fakeView!)
                self.fakeView?.image = currentImageView.image
                self.fakeView?.frame = fromRect
                
                UIView.animate(withDuration: 0.3, animations: {
                    self.fakeView?.frame = toRect!
                }) { (complete) in
                    self.hideWindow()
                }
            } else {
                self.hideWindow()
            }
        } else {
            self.hideWindow()
        }
    }
}

extension FullScreenViewManager {
    private func showOriginalView (show: Bool) {
        if show {
            self.targetView?.alpha = 1;
        } else {
            self.targetView?.alpha = 0;
        }
    }
    
    private func isShownBaseViewController() -> Bool {
        var isShown = false
        
        if self.baseWindow.rootViewController != nil { isShown = true }
        
        return isShown
    }
    
    private func hideBaseViewController() {
        self.baseWindow.rootViewController = nil
    }
    
    private func showBaseViewControlelr() {
        self.baseWindow.rootViewController = self.baseVC
    }
    
    private func getAspectFillSizeToFullScreen(image: UIImage, targetViewSize: CGSize) -> CGSize {
        let imageSize = image.size
        var resultSize = CGSize(width: 0, height: 0)
        if imageSize.width > imageSize.height {
            let rWidth = targetViewSize.width
            let rHeight = rWidth * imageSize.height / imageSize.width
            resultSize = CGSize(width: rWidth, height: rHeight)
        } else {
            let rHeight = targetViewSize.height
            let rWidth = rHeight * imageSize.width / imageSize.height
            resultSize = CGSize(width: rWidth, height: rHeight)
        }
        
        return resultSize
    }
}

extension FullScreenViewManager: FullScreenViewControllerProtocol {
    func closeButtonPressed() {
        self .closeFullScreen()
    }
}
