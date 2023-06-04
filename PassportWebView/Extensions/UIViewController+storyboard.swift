//
//  UIViewController+storyboard.swift
//  WebviewCommunication
//
//  Created by Freelance on 8/3/22.
//

import Foundation
import UIKit
import SwiftUI

extension UIViewController {
    static func storyboardInstance() -> Self {
        let classStr = String(describing: self)
        let abbreviation = String(classStr.prefix(classStr.count - "ViewController".count))
        return UIStoryboard(name: abbreviation, bundle: Bundle.main).instantiateInitialViewController() as! Self
    }
}

extension View {
    @ViewBuilder func hidden(_ shouldHide: Bool) -> some View {
        switch shouldHide {
        case true: self.hidden()
        case false: self
        }
    }
}
