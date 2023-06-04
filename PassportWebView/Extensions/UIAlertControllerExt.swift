//
//  UIAlertControllerExt.swift
//  PassportWebView
//
//  Created by Ameya on 2022/12/1.
//

import Foundation
import UIKit

extension UIAlertController {
    
    func addImage(image: UIImage) {
        
        let maxSize = CGSize(width: 245, height: 300)
        let imgsize = image.size
        
        var ratio: CGFloat!
        if imgsize.width > imgsize.height {
            ratio = maxSize.width / imgsize.width
        } else {
            ratio = maxSize.height / imgsize.height
        }
        
        let scaledSize = CGSize(width: imgsize.width * ratio, height: imgsize.height * ratio)
        
        var resizedImage = image.imageWithSize(scaledSize)
        
        if imgsize.height > imgsize.width {
            let left = (maxSize.width - resizedImage.size.width) / 2
            resizedImage = resizedImage.withAlignmentRectInsets(UIEdgeInsets(top: 0,left: -left,bottom: 0,right: 0))
        }
        
        
        let imgAction = UIAlertAction(title: "", style: .default, handler: nil)
        imgAction.isEnabled = false
        imgAction.setValue(resizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
        self.addAction(imgAction)
    }
}
