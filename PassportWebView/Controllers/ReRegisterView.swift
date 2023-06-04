//
//  ReRegisterView.swift
//  PassportWebView
//
//  Created by Ameya on 2022/12/2.
//

import SwiftUI
import PhotosUI
import CodeScanner

class CameraManager : ObservableObject {
    @Published var permissionGranted = false
    
    func requestPermission() {
        AVCaptureDevice.requestAccess(for: .video, completionHandler: {accessGranted in
            DispatchQueue.main.async {
                self.permissionGranted = accessGranted
            }
        })
    }
}
struct ReRegisterView: View {
    
    
    typealias RegisterAction = () -> Void
    var register: RegisterAction?
   
    typealias SelectAction = (Int) -> Void
        var select : SelectAction?
    @StateObject var cameraManager = CameraManager()
    typealias CheckIdAction = () -> Void
    var checkId: CheckIdAction?
    
    
    
    var viewId:some View{
        
        Button(action: {
            if SettingsStore().userInfo.name != "" {
                select?(1)
            }
            
        }) {
            
            Text("הצגת תיעוד")
                .font(.system(size: 25)).bold()
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.HexToColor(hexString: "#F2F2F7"))

        }
    }
    var verification:some View{
        
        Button(action: {
            select?(3)
        }) {
            
            Text("אימות")
                .font(.system(size: 25)).bold()
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.HexToColor(hexString: "#F2F2F7"))
            

        } 
    }
    var addCertificate:some View{
        
        Button(action: {
            
        }) {
            
            Text("הוספת תעודה")
                .font(.system(size: 25)).bold()
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.HexToColor(hexString: "#F2F2F7"))

        }
    }
    
    var settings:some View{
        
        Button(action: {
            
        }) {
            
            Text("הגדרות")
                .font(.system(size: 25)).bold()
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.HexToColor(hexString: "#F2F2F7"))

        }
    }

    
    
    
    
    
    var registerButtonView: some View {
        Button(action: {
            select?(2)
//            register?()
        }) {
            
            Text("רישום לשירות")
                .font(.system(size: 25)).bold()
                .foregroundColor(.black)
                .padding()
                .frame(maxWidth: .infinity)
                .background(Color.HexToColor(hexString: "#F2F2F7"))
//            if let registerNameImage = UIImage(named: "re-registerName") {
//                Image(uiImage: registerNameImage)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: .infinity, maxHeight: 20)
//
                    
            }
        }
//        .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
//        .background(Color.HexToColor(hexString: "#49CF6F"))
//        .padding(.top, 24)
//        .cornerRadius(10)
//    }
    
//    var checkIdButtonView: some View {
//        Button(action: {
//            checkId?()
//        }) {
//            if let registerNameImage = UIImage(named: "checkIdName") {
//                Image(uiImage: registerNameImage)
//                    .resizable()
//                    .aspectRatio(contentMode: .fit)
//                    .frame(maxWidth: .infinity, maxHeight: 20)
//
//
//            }
//        }
//        .frame(maxWidth: .infinity, minHeight: 60, maxHeight: 60)
//        .background(Color.HexToColor(hexString: "#F2F2F7"))
//        .padding(.top, 12)
//        .cornerRadius(10)
//    }
    
    var logoView: some View {
        ZStack {
            
            
            if let logoImage = UIImage(named: "binaeLogo") {
                Image(uiImage: logoImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, minHeight: 120)
                    
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    var mobileView: some View {
        ZStack {
            
            
            if let logoImage = UIImage(named: "mobile1") {
                Image(uiImage: logoImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200)
                    
            }
        }
        .padding(.top, 40)
        .frame(maxWidth: .infinity)
    }
    
    var body: some View {
        ZStack {
            
            VStack {
                
                registerButtonView
                viewId
                verification
                addCertificate
                settings
                
                Spacer()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(35)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onReceive(cameraManager.$permissionGranted, perform: { (granted) in
            if granted {
                //show image picker controller
            }
        })
        .onAppear {
            cameraManager.requestPermission()
            
        }
    }
    
    func withRegisterAction(_ action: @escaping RegisterAction) -> Self {
        var clone = self
        clone.register = action
        return clone
    }
    
    func widthCheckIdAction(_ action: @escaping CheckIdAction) -> Self {
        var clone = self
        clone.checkId = action
        return clone
    }
    
    func withSelectAction(_ action: @escaping SelectAction) -> Self
     {
         var clone = self
         clone.select = action
         return clone
     }
    
   
}

struct ReRegisterView_Previews: PreviewProvider {
    static var previews: some View {
        ReRegisterView()
    }
}
