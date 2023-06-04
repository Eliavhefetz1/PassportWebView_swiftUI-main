//
//  MainView.swift
//  PassportWebView
//
//  Created by Ameya on 2022/12/2.
//

import SwiftUI
import WebKit
import SafariServices
import NFCPassportReader




typealias MessageHandler = (_ message:WKScriptMessage) -> Void
typealias StatusHandler = (_ stauts:Int) -> Void
struct MainView: View {
    var statusHandler: StatusHandler?
    @State private var viewModel: WebContentViewModel
    @State private var passportReader = PassportReader()
    @State private var isInProcess = false
    @State private var successFlag = true
    @State private var isSetUrl = false
    
    
     static var sodArray : [UInt8] = []
     static var imgArrayWithHeader:[UInt8] = []
     static var onlyImgArray:[UInt8] = []
   
    
    var api  = "https://idndemo.herokuapp.com/getcode"
    init() {
        viewModel = WebContentViewModel()
    }
    var body: some View {
        VStack(spacing: 0) {
            if let store = viewModel.webViewStore {
                WebView(webView: store.webView)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.red)
            }
            
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func withUrlString(_ urlString: String) {
        viewModel.setURl(urlString: urlString)
        viewModel.withMessageHandler { message in
            self.webViewMessage(message: message)
        }
    }
    
    func withStatusHandler(_ action: @escaping StatusHandler) -> Self {
        var clone = self
        clone.statusHandler = action
        return clone
    }
    
    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
    
    func convertToBase64String(_ inputString: String) -> String? {
        guard let inputData = inputString.data(using: .utf8) else {
            return nil
        }
        
        let base64String = inputData.base64EncodedString()
        return base64String
    }
    
    func sendRequest(api:String,pNumber:String,custid:String, compiltion:@escaping(String) ->Void) {
        
        
        let url = URL(string:api)
        guard let requestUrl = url else{
            fatalError()
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"


        let postString = "custphone=\(pNumber)&custid=\(custid)&custname=\(SettingsStore().userInfo.name)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        
    
        let task = URLSession.shared.dataTask(with: request){(data,response,error) in
            if let error = error{
                print(error)
                return
            }
            if let data = data,let dataString = String (data: data, encoding: .utf8){
                print("Response data string:\n \(dataString)")
                compiltion(dataString)
            }
        }
        task.resume()
       
    }
    
    func byteArryToBase64(array:[UInt8])->String{
        
        let data = NSData(bytes: array, length: array.count)
        
        let base64Data = data.base64EncodedData(options: NSData.Base64EncodingOptions.endLineWithLineFeed)
        
        let newData = NSData(base64Encoded: base64Data,options: NSData.Base64DecodingOptions.ignoreUnknownCharacters)
        
        let newNSString = newData!.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        
        return newNSString
    }

    
    
    
    func readPassportNFC(_ passportNumber: String, _ dateOfBirth: String, _ dateOfExpiry: String) {
        let passportUtils = PassportUtils()
        let mrzKey = passportUtils.getMRZKey( passportNumber: passportNumber, dateOfBirth: dateOfBirth, dateOfExpiry: dateOfExpiry)
        
        // Set the masterListURL on the Passport Reader to allow auto passport verification
        let masterListURL = Bundle.main.url(forResource: "masterList", withExtension: ".pem")!
        passportReader.setMasterListURL( masterListURL )
        
        passportReader.passiveAuthenticationUsesOpenSSL = true;
        
        // If we want to read only specific data groups we can using:
        let dataGroups : [DataGroupId] =  [.COM, .SOD, .DG1 , .DG2]
        
        Task {
            let customMessageHandler : (NFCViewDisplayMessage)->String? = { (displayMessage) in
                print("displayMessage: ֿ\(displayMessage)");
                switch displayMessage {
                case .requestPresentPassport:
                    return "הצמידו את הכרטיס לגב הטלפון"
                case .authenticatingWithPassport(_):
                    DispatchQueue.main.async {
                        self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleNFCEvent('CHIP_DETECTED')");
                    }
                    return "הצ'יפ נמצא, נא לא לזוז"
                case .error(let tagError): // TODO:: with Adi
                    print("tagError: ", tagError);
                    print("errorDescription: \(String(describing: tagError.errorDescription))");
                    isInProcess = false
                    switch tagError {
                    case NFCPassportReaderError.NFCNotSupported, NFCPassportReaderError.NotYetSupported:
                        DispatchQueue.main.async {
                            self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleNFCEvent('THERE_IS_NO_NFC_IN_DEVICE')");
                        }
                        return ""
                        
                    case NFCPassportReaderError.ConnectionError:
                        DispatchQueue.main.async {
                            self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleNFCEvent('CONNECTION_LOST')");
                        }
                        return "היה קצר בתקשורת, נסו שוב"

                    case NFCPassportReaderError.InvalidMRZKey:
                        DispatchQueue.main.async {
                            self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleNFCEvent('INVALID_MRZ_KEY')");
                        }
                        return "מפתח MRZ לא חוקי"
                        
                    default:
                        self.isInProcess = false
                        DispatchQueue.main.async {
                            self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleNFCEvent('NATIVE_EXCEPTION')");
                        }
                        return ""
                    }
                    
                    
                case .successfulRead:
                    self.isInProcess = false
                    return "הסריקה הסתיימה בהצלחה"
                default:
                    
                    return "הצ'יפ נמצא, נא לא לזוז"
                }
            }
            
            do {
                
                let passport = try await passportReader.readPassport( mrzKey: mrzKey,tags: dataGroups, customDisplayMessage:customMessageHandler)
                
                MainView.sodArray = SOD.alldata
                
                MainView.imgArrayWithHeader = DataGroup2.imageBytes
                
                let sodString = byteArryToBase64(array:MainView.sodArray)
                
                let fullimgStirng = byteArryToBase64(array: MainView.imgArrayWithHeader)
                
                
           
                
              
                
                
                
              

                
                
                
                guard let faceImage = passport.passportImage else {
                    DispatchQueue.main.async {
                        self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleNFCEvent('CONNECTION_LOST')");
                    }
                    return;
                }
                
                let base64 = faceImage.toBase64String();
                
                //                print("face image?: ")
                //                print(base64);
                
                
                
                // need to change it
                // remove base64
                // and add two values
                // 1 MainView.sodArray
                // 2 MainView.imgArrayWithHeader
                // and than send it to the server
                let images = NSMutableDictionary();
                images.setValue(base64, forKey: "face_image");
                
                
                
                
                
                
                
                
                
                let auth = NSMutableDictionary();
                let chipAuthSucceeded = passport.chipAuthenticationStatus == PassportAuthenticationStatus.success;
                let passiveAuthSuccess = passport.passportCorrectlySigned;
                auth.setValue(chipAuthSucceeded, forKey: "chip");
                auth.setValue(passiveAuthSuccess, forKey: "passive");
                
                
                let fields = NSMutableDictionary();
                
                let passportMRZ = passport.passportMRZ;
                
                print("passportMRZ.count: \(passportMRZ.count)");
                
                if (passportMRZ.count == 88) {
                    print("as Android: ")
                    print("\(passportMRZ.prefix(44))\n\(passportMRZ.suffix(44))\n");
                }
                SettingsStore().imgBase64 = base64
                                SettingsStore().userInfo = UserInfo(name: "\(passport.firstName) \(passport.lastName)", clientId: "1", image: base64, idNum:  passport.personalNumber ?? "", expireDate: passport.documentExpiryDate, birthDate:  passport.dateOfBirth, registrationDate: Date().formatted(.dateTime.month().year().day()),registrationHour: Date().formatted(.dateTime.hour().minute()),QRCode: "",phoneNumber:"")
                fields.setValue(passport.passportMRZ, forKey: ("mrz_lines"));
                //                fields.setValue(passport.documentSubType, forKey: "mrz_type"); // documentSubType?
                //                fields.setValue(passport.documentType, forKey: "document_type");
                fields.setValue(passport.issuingAuthority, forKey: "issuing_country_code"); // issuingAuthority?
                fields.setValue(passport.lastName, forKey: "last_name");
                fields.setValue(passport.firstName, forKey: "first_name");
                fields.setValue(passport.documentNumber, forKey: "passport_number");
                fields.setValue(passport.nationality, forKey: "nationality_code");
                fields.setValue(passport.dateOfBirth, forKey: "date_of_birth");
                fields.setValue(passport.gender, forKey: "gender");
                fields.setValue(passport.documentExpiryDate, forKey: "date_of_expiry");
                fields.setValue(passport.personalNumber, forKey: "personal_number");
                
                let defaults = UserDefaults.standard;
                defaults.set(passport.personalNumber, forKey: "personalNumber");
//                defaults.set(base64, forKey: "faceimage");
//
                
                let payload = NSMutableDictionary();
                payload.setValue(images, forKey: "images");
                payload.setValue(auth, forKey: "auth");
                payload.setValue(fields, forKey: "fields");
                
                let payloadJSON = try JSONSerialization.data(withJSONObject: payload, options: JSONSerialization.WritingOptions(rawValue: 0))
                
                let allInfoJSONString = NSString(data: payloadJSON, encoding: String.Encoding.utf8.rawValue)!
                
                DispatchQueue.main.async {
                    self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleNFCSuccess(JSON.parse('\(allInfoJSONString)'))");
                }
            } catch let e {
                print("catch e: ֿ\(e.localizedDescription)");
                
                if (e.localizedDescription == "UserCanceled" && isInProcess) {
                    DispatchQueue.main.async {
                        self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleNFCEvent('USER_CANCELED')");
                    }
                }
                else if (e.localizedDescription == "UnexpectedError" && isInProcess) { // we get here after 1 min (timeout)
                    // we should not get here couse we have a 30 sec timeout from webview that call stopProcess
                    DispatchQueue.main.async {
                        self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleNFCEvent('CHIP_NOT_DETECTED')");
                    }
                }
                else if (e.localizedDescription == "Tag connection lost") {
                    //TODO:: Do nothing because we handle it in messages supply
                }
                else {
                    //TODO:: check if we need other senerios
                }
            }
        }
    }
    
    func stopReadPassportNFC() {
        print("stopReadPassportNFC");
//         self.passportReader.readerSession?.invalidate()
    }
    
    func webViewMessage(message: WKScriptMessage) {
        switch message.name {
        case "startNFCProcess":
            //registrationProcess = true
            guard let data = message.body as? NSDictionary else {
                return
            }
            
            guard let passportNumber = data["passportNumber"] as? String else {
                return
            }
            
            guard let dateOfBirth = data["dateOfBirth"] as? String else {
                return
            }
            
            guard let dateOfExpiry = data["dateOfExpiry"] as? String else {
                return
            }
            
            isInProcess = true;
            readPassportNFC(passportNumber, dateOfBirth, dateOfExpiry);
            break;
            
        case "stopNFCProcess":
            stopReadPassportNFC();
            isInProcess = false;
            break;
            
        case "storeFace":
            print("storeFace");
                
            guard let data = message.body as? NSDictionary else {
                DispatchQueue.main.async {
                    self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleFaceStore('false')");
                }
                return
            }
            
            guard let imgPart2 = data["img_part2"] as? String else {
                DispatchQueue.main.async {
                    self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleFaceStore('false')");
                }
                return
            }
            
            guard let kcv = data["kcv"] as? String else {
                DispatchQueue.main.async {
                    self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleFaceStore('false')");
                }
                return
            }
            
            guard let uuid = data["uuid"] as? String else {
                DispatchQueue.main.async {
                    self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleFaceStore('false')");
                }
                return
            }
            
            let defaults = UserDefaults.standard;
            defaults.set(imgPart2, forKey: "IMG_PART2");
            defaults.set(kcv, forKey: "KCV");
            defaults.set(uuid, forKey: "UUID");
            
            DispatchQueue.main.async {
                self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleFaceStore('true')");
            }
            
            break;
          
        case "faceRetrieve":
            print("faceRetrieve");
            let defaults = UserDefaults.standard;
            
            let payload = NSMutableDictionary();
            
            payload.setValue(defaults.string(forKey:"IMG_PART2"), forKey: "img_part2");
            payload.setValue(defaults.string(forKey:"KCV"), forKey: "kcv");
            payload.setValue(defaults.string(forKey:"UUID"), forKey: "uuid");
            
            do {
                let payloadJSON = try JSONSerialization.data(withJSONObject: payload, options: JSONSerialization.WritingOptions(rawValue: 0))
                
                let allInfoJSONString = NSString(data: payloadJSON, encoding: String.Encoding.utf8.rawValue)!
                
                DispatchQueue.main.async {
                    self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleFaceRetrieve(JSON.parse('\(allInfoJSONString)'))");
                }
            } catch {
                DispatchQueue.main.async {
                    self.viewModel.webViewStore?.webView.evaluateJavaScript("window.handleFaceRetrieve(JSON.parse('{}'))"); // can we check it?
                }
            }

            
        case "processEnded":
            print("finished")
            
            guard let data = message.body as? NSDictionary else {
                print("processEnded sucess: false")
                
                return
            }
            
            guard let success = data["success"] as? Bool else {
                print("processEnded sucess: false")
                
                return
            }
            let registrationProcess = UserDefaults.standard.bool(forKey: "Begin")
            if (success) {
                print("processEnded sucess: true")
                if(registrationProcess){
                    statusHandler?(0)
                    sendRequest(api: api, pNumber: EnterPhoneNumberView.finalPNumber, custid: SettingsStore().userInfo.idNum) { res in
                        SettingsStore().userInfo.QRCode = res
                    }
                }
                else
                {
                    SettingsStore().userInfo.registrationDate = Date().formatted(.dateTime.month().year().day())
                    SettingsStore().userInfo.registrationHour = Date().formatted(.dateTime.hour().minute())
                    UserDefaults.standard.synchronize()
                    statusHandler?(1)
                    
                }
            }
            else {
                print("processEnded sucess: false")
                if(registrationProcess){
                    statusHandler?(3)
                        SettingsStore().userInfo = UserInfo(name: "", clientId: "", image: "", idNum: "", expireDate: "", birthDate: "", registrationDate: "",registrationHour: "",QRCode: "",phoneNumber: "")
                }
                else
                {
                    statusHandler?(2)
                }
            }
            
            
//            self.webView?.removeFromSuperview();
//            self.webView = nil;
//            let vc = SuccessViewController();
            
            
            
            break;
        default:
            print("userContentController message: \(message.name)");
            return
        }
    }
  
}

class WebContentViewModel: NSObject, WKScriptMessageHandler, WKNavigationDelegate, ObservableObject {
    @Published var webViewStore: WebViewStore?
    var messageHandler: MessageHandler?
    var webConfiguration: WKWebViewConfiguration?
    override init() {
        
        
        
        
    }
    
    func setURl(urlString: String) {
        if(urlString != "") {
            if let url = URL(string: urlString) {
                let userContentController = WKUserContentController()
                let configuration = WKWebViewConfiguration()
                webConfiguration = configuration
                webConfiguration?.allowsInlineMediaPlayback = true
                webConfiguration?.userContentController.add(self, name: "startNFCProcess");
                webConfiguration?.userContentController.add(self, name: "stopNFCProcess");
                webConfiguration?.userContentController.add(self, name: "storeFace");
                webConfiguration?.userContentController.add(self, name: "faceRetrieve");
                webConfiguration?.userContentController.add(self, name: "processEnded");
                
                let webView = WKWebView(frame: .zero, configuration: configuration)
                let myRequest = URLRequest(url: url)
                webView.load(myRequest)
                webView.navigationDelegate = self
                webViewStore = WebViewStore(webView: webView)

            
            }
        }
    }
    
  
    
    func withMessageHandler(_ action: @escaping MessageHandler){
        self.messageHandler = action
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        messageHandler?(message)
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        print("webView didReceiveServerRedirectForProvisionalNavigation");
        print("webView: \(webView)");
        print("navigation: \(navigation.description)");
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("webView decidePolicyFor");
        print("webView: \(webView)");
        print("webView url: \(String(describing: webView.url))");
        print("webView pathComponents: \(String(describing: webView.url?.pathComponents))");
        print("navigationAction: \(navigationAction)");
        print("navigationAction pathComponents: \(String(describing: navigationAction.request.url?.pathComponents))");
        
        
        if let pathComponentsCount = navigationAction.request.url?.pathComponents.count {
            
            if (pathComponentsCount > 1 && navigationAction.request.url?.pathComponents[1] == "completed") {
                OperationQueue.main.addOperation {
                    print(navigationAction.request.url?.absoluteString ?? "")
                    
                    decisionHandler(.cancel)
                    
                }
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        guard let serverTrust = challenge.protectionSpace.serverTrust else {
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }
        let exceptions = SecTrustCopyExceptions(serverTrust)
        SecTrustSetExceptions(serverTrust, exceptions)
        completionHandler(.useCredential, URLCredential(trust: serverTrust));
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
