//
//  EnterPhoneNumberView.swift
//  PassportWebView
//
//  Created by liran ben haim on 23/05/2023.
//

import SwiftUI





struct EnterPhoneNumberView: View {
    
    typealias CloseAction = () -> Void
    var close: CloseAction?
    
    @State var phoneNumber = "05"
    @FocusState var pNumberIsFocused : Bool
    @State var showAlert : Bool = false
    @State var buttondisabled : Bool =  true
    var MsgApi = "https://idndemo.herokuapp.com/makereg"
    
   static var finalPNumber : String = ""
    
    
    var headLine :some View {
        Text("יש להכניס מספר טלפון לרישום")
            .font(.title)
            
    }
    
    var enterNumber :some View {
        TextField("Phone Number",text: $phoneNumber)
            .keyboardType(.phonePad)
            .textContentType(.telephoneNumber)
            .padding()
            .border(Color.gray)
            .frame(maxWidth: .infinity,alignment: .trailing)
            .focused($pNumberIsFocused)
            .onChange(of: phoneNumber){ newvalue in
                if phoneNumber.count == 10 && phoneNumber.hasPrefix("05"){
                    buttondisabled = false
                }
            }
        .toolbar{
                ToolbarItem(placement: .keyboard){
                    Button("Done"){
                        pNumberIsFocused = false
                    }
                }
            }
    }
    
    
    
    
    var submitButton : some View {
        Button(action:{
            EnterPhoneNumberView.finalPNumber = phoneNumber
            SettingsStore().userInfo.phoneNumber = phoneNumber
            sendRequest(api: MsgApi,pNumber: phoneNumber)
            buttondisabled = true
            
        })
        {
            Text("אישור")
            .font(.system(size: 25)).bold()
            .foregroundColor(.black)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.HexToColor(hexString: "#F2F2F7"))
        }  .disabled(buttondisabled)
        
    }
    
    var body: some View {
        VStack(alignment: .leading){
            HStack(){
                returnButton
            }
            VStack{
                headLine
                enterNumber
                Spacer()
                submitButton
            }
        }.padding()
            .alert(isPresented: $showAlert, content: msgSentAlert)
    }
    
    
     func msgSentAlert()->Alert{
        return Alert(title:Text("לרישום יש ללחוץ על הלינק שנשלח בהודעה"),dismissButton: .default(Text("אישור")))
             
    }
    
    
    
    
    func sendRequest(api:String,pNumber:String){
        
        // set the url and cheking if the url is ok
        let url = URL(string:api)
        guard let requestUrl = url else{
            fatalError()
        }
        
        // set the method of the req
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"

        // the params we sending to the url
        let postString = "custphone=\(pNumber)"
        request.httpBody = postString.data(using: String.Encoding.utf8)
        

        
        // sending the req and wating for the server to response
        let task = URLSession.shared.dataTask(with: request){(data,response,error) in
            if let error = error{
                print(error)
                return
            }
            if let data = data,let dataString = String (data: data, encoding: .utf8){
                print("Response data string:\n \(dataString)")
                // showing alert to the user by changig the boolean to true
                showAlert.toggle()

                
            }
        }
        task.resume()
    }
    
    var returnButton :some View{
        Button(action: {
            close?()
        }) {
            if  let backImage = UIImage(named: "Arrow-Left") {
                Image(uiImage: backImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: .infinity, height: .infinity, alignment: .center)
                    
            }
        }.frame(width: 40, height: 40, alignment: .center)
    }
    

    
    func withCloseAction(_ action: @escaping CloseAction)-> Self{
        var clone  = self
        clone.close = action
        return clone
    }
}

struct EnterPhoneNumberView_Previews: PreviewProvider {
    static var previews: some View {
        EnterPhoneNumberView()
    }
}
