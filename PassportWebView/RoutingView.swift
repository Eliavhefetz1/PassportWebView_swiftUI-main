//
//  RoutingView.swift
//  PassportWebView
//
//  Created by Ameya on 2022/12/2.
//

import Foundation
import UIKit
import SwiftUI

struct RoutingView: UIViewControllerRepresentable {
    typealias UIViewControllerType = UINavigationController
    
    var navigator = UINavigationController()

    func makeUIViewController(context: Context) -> UINavigationController {
        return navigator
    }
    
    func updateUIViewController(_ uiViewController: UINavigationController, context: Context) {
    }
    
    func push<Content: View>(_ content: Content, animated: Bool) {
        let wrapper = UIHostingController(rootView: content)
        navigator.pushViewController(wrapper, animated: true)
    }

    func popView(animated: Bool) {
        navigator.popViewController(animated: animated)
    }
    
    func popAllView(animated: Bool) {
        var controllers = navigator.viewControllers
        let rootController = controllers.first
        controllers.removeAll()
        controllers.append(rootController!)
        navigator.viewControllers = controllers
        
        //navigator.popViewController(animated: animated)
    }

    
    init<RootView: View>(rootView: RootView) {
        let wrapper = UIHostingController(rootView: rootView)
        navigator.navigationBar.isHidden = true
        
        navigator.viewControllers = [wrapper]
    }
}
