//
//  UIImageExt.swift
//  PassportWebView
//
//  Created by Ameya on 2022/12/1.
//

import Foundation
import UIKit
import SwiftUI

extension UIImage {
    func imageWithSize(_ size:CGSize) -> UIImage {
        var scaledImageRect = CGRect.zero
        
        let aspectWidth:CGFloat = size.width / self.size.width
        let aspectHeight:CGFloat = size.height / self.size.height
        let aspectRatio:CGFloat = min(aspectWidth, aspectHeight)
        
        scaledImageRect.size.width = self.size.width * aspectRatio
        scaledImageRect.size.height = self.size.height * aspectRatio
        scaledImageRect.origin.x = (size.width - scaledImageRect.size.width) / 2.0
        scaledImageRect.origin.y = (size.height - scaledImageRect.size.height) / 2.0
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0)
        
        self.draw(in: scaledImageRect)
        
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return scaledImage!
    }
    
    func toBase64String() -> String {
        
        guard let imageData = self.jpegData(compressionQuality: 1)
        else {
            return ""
        }
        
        let str64 = imageData.base64EncodedString()
        
        return str64
        //        return "data:image/jpg;base64,\(str64)"
    }
}

extension Color{
    static func HexToColor(hexString: String) -> Color {
        // Convert hex string to an integer
        var hexInt: UInt64 = 0
        let scanner: Scanner = Scanner(string: hexString)
        scanner.charactersToBeSkipped = CharacterSet(charactersIn: "#")
        scanner.scanHexInt64(&hexInt)
        
        let red = CGFloat((hexInt & 0xff0000) >> 16) / 255.0
        let green = CGFloat((hexInt & 0xff00) >> 8) / 255.0
        let blue = CGFloat((hexInt & 0xff) >> 0) / 255.0
        
        // Create color object, specifying alpha as well
        let color = Color(UIColor(red: red, green: green, blue: blue, alpha: 1.0))
        return color
    }

}
