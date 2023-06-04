//
//  PassportWebViewApp.swift
//  PassportWebView
//
//  Created by Ameya on 2022/12/1.
//

import SwiftUI

@main
struct PassportWebViewApp: App {
    
    
    init() {
        //VMCameraView.shared.mirrored = true
    }
    
//    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var router: Router = {
        
        
        
        return Router()
    } ()
    
    
    var body: some Scene {
        WindowGroup {
            router.mainView
                .onOpenURL { url in
                    DispatchQueue.global().sync {
                        var param = url.description.replacingOccurrences(of: "https://idndemo.herokuapp.com/links?", with: "")
                        router.registerFromUrl(url:"https://uat-pia-client.scanovate.com/?\(param)" )
                        if let components = URLComponents(url:url,resolvingAgainstBaseURL: false),
                           let parameter = components.queryItems?.first(where: {$0.name == "type"})?.value{
                            UserDefaults.standard.set(true, forKey: "Begin")
                        }
                        else{
                            UserDefaults.standard.set(false, forKey: "Begin")
                        }
                    }
                    
                }
        }
    }
}
