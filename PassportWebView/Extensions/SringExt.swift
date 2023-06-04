//
//  SringExt.swift
//  PassportWebView
//
//  Created by liran ben haim on 23/05/2023.
//

import Foundation
import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins

extension String {

    var length: Int {
        return count
    }

    subscript (i: Int) -> String {
        return self[i ..< i + 1]
    }

    func substring(fromIndex: Int) -> String {
        return self[min(fromIndex, length) ..< length]
    }

    func substring(toIndex: Int) -> String {
        return self[0 ..< max(0, toIndex)]
    }

    subscript (r: Range<Int>) -> String {
        let range = Range(uncheckedBounds: (lower: max(0, min(length, r.lowerBound)),
                                            upper: min(length, max(0, r.upperBound))))
        let start = index(startIndex, offsetBy: range.lowerBound)
        let end = index(start, offsetBy: range.upperBound - range.lowerBound)
        return String(self[start ..< end])
    }
    func toUIImage () -> UIImage{
        let dataDecoded : Data = Data(base64Encoded: self, options: .ignoreUnknownCharacters)!
        let decodedimage = UIImage(data: dataDecoded)
        return decodedimage ?? UIImage()
    }
    func formateDate()->String{
        //let monthTab = ["Jan.","Feb.","Mar.","Apr.","May.","Jun.","Jul.","Aug.","Sep.","Oct.","Nov.","Dec."]
        let day = "\(self.substring(fromIndex: 4))"
        let month = self.substring(fromIndex: 2).substring(toIndex: 2)
        let year = self.prefix(2)
        return "\(day)/\(month)/\(year)"
    }
    func generateQRCode()->UIImage{
        let filter = CIFilter.qrCodeGenerator()
        let data = Data(self.utf8)
        filter.setValue(data, forKey: "inputMessage")
        if let qrCodeImage = filter.outputImage{
            if let qrCodeCGImage = CIContext().createCGImage(qrCodeImage, from: qrCodeImage.extent){
                return UIImage(cgImage: qrCodeCGImage)
            }
        }
        return UIImage(systemName: "xmark") ?? UIImage()
    }
}
