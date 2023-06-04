//
//  Router.swift
//  PassportWebView
//
//  Created by Ameya on 2022/12/2.
//

import Foundation
import Alamofire
import SwiftUI
class Router {
    
    
    init() {
        
    }
    lazy var mainView : RoutingView = {
        let isStart = UserDefaults.standard.bool(forKey: "Begin")
        if(isStart) {
            return RoutingView(rootView: reRegisterView)
        }
        UserDefaults.standard.synchronize()
        return RoutingView(rootView: reRegisterView)
    } ()
    
  
    
    
    lazy var phoneNumber : EnterPhoneNumberView = {
        [unowned self] in
        var view = EnterPhoneNumberView().withCloseAction {
            self.mainView.popView(animated: true)
        }
        return view
    }()
    
    lazy var documentation : viewDocumentation = {
        [unowned self] in
        var view = viewDocumentation().withCloseAction{
            self.mainView.popView(animated: true)
        }
        return view
    }()
    
    lazy var identifyView : IdentifyView = {
        [unowned self] in
        var view = IdentifyView().withCloseAction{
            mainView.popView(animated: true)
        }
        return view
    }()
    
    lazy var failedView: FailedView = {
        [unowned self] in
        var view = FailedView().withCloseAction {
//            moveRegister()
            mainView.push(reRegisterView, animated: true)
        }
        
        
        return view
    } ()
    
    lazy var successView: SuccessView = {
        [unowned self] in
        var view = SuccessView().withCloseAction {
            moveRegister()
        }
        
        
        return view
    } ()
    
    lazy var thumbView: ThumbView = {
        [unowned self] in
        var view = ThumbView().withCloseAction {
            moveRegister()
        }
        
        
        return view
    } ()
    
    lazy var cycleView: CycleView = {
        [unowned self] in
        var view = CycleView().withCloseAction {
            moveRegister()
        }
        
        
        return view
    } ()
    
    lazy var mainContentView: MainView = {
        [unowned self] in
        var view = MainView().withStatusHandler { status in
            switch(status) {
            case 0:
                mainView.push(successView, animated: true)
                break
            case 1:
                mainView.push(thumbView, animated: true)
                break
            case 2:
                mainView.push(failedView, animated: true)
                break
            case 3:
                mainView.push(cycleView, animated: true)
                break
            default:
                print(status)
                break
            }
        }
        
        
        return view
    } ()
    
    lazy var reRegisterView: ReRegisterView = {
        [unowned self] in
        
        var view = ReRegisterView()
            .withRegisterAction {
                RegisterService.hitRegistrationApi { result, status in
                    mainContentView.withUrlString(result as? String ?? "")
                    let listVC = UIHostingController(rootView: mainContentView)
                    mainView.navigator.setViewControllers([listVC], animated: true)
                } failureResult: { error in
                    
                }

            }
            .widthCheckIdAction {
                RegisterService.hitReRegistrationApi { result, status in
                    mainContentView.withUrlString(result as? String ?? "")
                    let listVC = UIHostingController(rootView: mainContentView)
                    mainView.navigator.setViewControllers([listVC], animated: true)
                    
                } failureResult: { error in
                    
                }

            }.withSelectAction{ type in
                switch(type){
                case 1:
                    self.mainView.push(self.documentation ,animated: true)
                    break
                case 2 :
                    self.mainView.push(self.phoneNumber, animated: true)
                case 3 :
                    self.mainView.push(self.identifyView,animated: true)
                default:
                    break
                }
            }
        
        
        return view
    } ()
    func registerFromUrl (url :String){
        self.mainContentView.withUrlString(url)
        let listVC = UIHostingController(rootView: self.mainContentView)
        self.mainView.navigator.pushViewController(listVC, animated: true)
    }
    
    func moveRegister() {
        let listVC = UIHostingController(rootView: reRegisterView)
        mainView.navigator.setViewControllers([listVC], animated: true)
    }
    
}
