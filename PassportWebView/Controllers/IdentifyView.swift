//
//  IdentifyView.swift
//  PassportWebView
//
//  Created by liran ben haim on 24/05/2023.
//

import SwiftUI
import CodeScanner

struct IdentifyView: View {
    
    typealias CloseAction = () -> Void
    var close: CloseAction?
    @State var isPresentingScanner : Bool = true
    @State var waitingForVerifi = false
    @State var successVerification  = false
    @State var failedVerification = false
    @State var timeIsUp = false
    
    
    var apiForVerification = "https://idndemo.herokuapp.com/checkcode"
    var apiForLiveFrification = "https://idndemo.herokuapp.com/checkid"
    var apiforverificationstatus = "https://idndemo.herokuapp.com/checkres"
    
    
    @State var idNmber : String = ""
    @State var pNumber : String = ""
    @State var personName: String = ""
    
    static var runCount = 0
    
    static var QRScanedCode = ""
    static var AnswerReturnFromApi = ""
    
    
    @State var timer: Timer?
    
    
   
    
    
    
    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack {
                    ZStack(alignment: .leading) {
                        
                        Button(action: {
                            close?()
                        }) {
                            if  let backImage = UIImage(named: "Arrow-Left") {
                                Image(uiImage: backImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                
                            }
                        }.frame(width: 40, height: 40, alignment: .center)
                        VStack {
                            Text("Age and id")
                                .font(.system(size: 24).bold())
                                .foregroundColor(Color.black)
                                .frame(maxWidth: .infinity, alignment: .center)
                        }.frame(maxWidth: .infinity)
                        
                    }.frame(maxWidth: .infinity)
                    
                    lineView(key: "מספר טלפון", value:pNumber)
                    lineView(key: "ת.ז ", value: idNmber)
                    lineView(key: "שם", value:personName)
                    
                    Spacer()
                }.padding(.leading, 20)
                    .padding(.trailing, 20)
                    .padding(.top, 60)
                
                Button(action:{
                    sendRequest(api: apiForLiveFrification,code:IdentifyView.QRScanedCode, keyName: "code"){ res in
                        IdentifyView.AnswerReturnFromApi = res
                    }
                    waitingForVerifi = true
                    startTimer()
                }){
                    
                    Text("אימות נוסף")
                        .font(.system(size: 25)).bold()
                        .foregroundColor(.black)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.HexToColor(hexString: "#F2F2F7"))
                }
            }
        }
        .sheet(isPresented: $isPresentingScanner) {
            CodeScannerView(codeTypes: [.qr],simulatedData:"" ,completion: handleScan)
                
        }
        .sheet(isPresented: $waitingForVerifi){
                ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(4)
                    .interactiveDismissDisabled()
        }
        .sheet(isPresented: $timeIsUp){
            if let backgroundImage = UIImage(named: "cycle") {
                Image(uiImage: backgroundImage)
            }
        }
        .sheet(isPresented: $successVerification){
            if let backgroundImage = UIImage(named: "thumbWithoutText") {
                Image(uiImage: backgroundImage)
            }
        }
        .sheet(isPresented: $failedVerification){
            if let backgroundImage = UIImage(named: "failedWithoutText") {
                Image(uiImage: backgroundImage)
            }
        }
    }
    
    func lineView(key:String,value:String)-> some View{
        return ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .shadow(color: .gray, radius: 8)
            HStack {
                Text(key)
                    .font(.system(size: 15).bold())
                    .foregroundColor(Color.black)
                    .padding(.leading, 30)
                Spacer()
                Text(value)
                    .padding(.trailing,20)
            }
        }.frame(maxWidth: .infinity, minHeight:60, maxHeight: 60)
            .padding(.top, 10)
            .padding(.leading, 8)
            .padding(.trailing, 8)
    }
    
    func withCloseAction(_ action: @escaping CloseAction)-> Self{
        var clone  = self
        clone.close = action
        return clone
    }
    
    func handleScan(result:Result<ScanResult,ScanError>){
        isPresentingScanner = false
        switch result {
        case .success(let result):
            print(result.string)
            sendRequest(api: apiForVerification, code: result.string,keyName:"code") { res in
                let temp = res.components(separatedBy:"_")
                idNmber = temp[0]
                pNumber = temp[1]
                personName = temp[2]
                IdentifyView.QRScanedCode = result.string
                
            }
            break
        case .failure(let err):
            print(err)
            break
        }
    }
    
    func sendReqWithJeson(api:String,code:String,keyName:String,compiltion:@escaping(Result<String,Error>) ->Void){
        let url = URL(string:api)
        guard let requestUrl = url else{
            fatalError()
        }
        
        let parameters = [
            "\(keyName)":"\(code)",
        ]
        
        guard let jsonData = try? JSONSerialization.data(withJSONObject: parameters) else {
                    return
                }

        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    compiltion(.failure(error!))
                    return
                }
            if let httpResponse = response as? HTTPURLResponse {
                           if httpResponse.statusCode == 200 {
                               if let responseString = String(data: data, encoding: .utf8) {
                                   compiltion(.success(responseString))
                                   if responseString == "1" || responseString == "2"{
                                       IdentifyView.AnswerReturnFromApi = responseString
                                       
                                   }
                                   
                               }
                           } else {
                               _ = "Request failed with status code: \(httpResponse.statusCode)"
                           }
                
                       }
                   }.resume()
        

    }
    
    func sendRequest(api:String,code:String,keyName:String,compiltion:@escaping(String) ->Void) {
        
        
        let url = URL(string:api)
        guard let requestUrl = url else{
            fatalError()
        }
        
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"


        let postString = "\(keyName)=\(code)"
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
    
     func startTimer(){
         print("------------------------ timer start -----------------------------")
       timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true){_ in
           IdentifyView.runCount += 1
           
           if  IdentifyView.runCount == 120{
               stopTimer(number: 0)
           }
           if IdentifyView.AnswerReturnFromApi == "1"{
               stopTimer(number: 1)
               
           }
           if IdentifyView.AnswerReturnFromApi == "2"{
               stopTimer(number: 2)
               
           }
           
           sendReqWithJeson(api: apiforverificationstatus, code: IdentifyView.AnswerReturnFromApi , keyName: "sessionId"){res in
               
           }
        }
    }
    
    
    func stopTimer(number:Int)->Void{
        
        print("------------------------ timer stop -----------------------------")
        timer?.invalidate()
        timer = nil
        waitingForVerifi = false
        IdentifyView.runCount = 0
        
        switch number {
        case 0:
            timeIsUp = false
            break
        case 1 :
            successVerification = true
            break
        case 2 :
            failedVerification = true
            break
        default:
            break
        }
        
        
      
        DispatchQueue.main.asyncAfter(deadline: .now()+5.0){
            successVerification = false
            failedVerification = false
            timeIsUp = false
        }
        
    }
    
    
  
    
}
struct IdentifyView_Previews: PreviewProvider {
    static var previews: some View {
        IdentifyView()
    }
}


