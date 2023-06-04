//
//  viewDocumentation.swift
//  PassportWebView
//
//  Created by liran ben haim on 23/05/2023.
//

import SwiftUI

struct viewDocumentation: View {
    
    typealias CloseAction = () -> Void
    var close: CloseAction?
   
    @State  var userInfo : UserInfo?
    
    
  
    
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
    
    var topView: some View {
        VStack {
            if let logoImage = UIImage(named: "top_background") {
                Image(uiImage: logoImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
    
    var userImage : some View {
        Image(uiImage: userInfo?.image.toUIImage() ?? "".toUIImage())
            .resizable()
            .aspectRatio(contentMode: .fit)
            .cornerRadius(15)
            .frame(width: 200, height: 200, alignment: .leading)
    }
    
    var personDataHeadline:some View{
        Text("נתוני אימות")
            .font(.system(size: 24).bold())
            .foregroundColor(Color.black)
            .frame(maxWidth: .infinity, alignment: .center)
    }
    
    var userInformation :some View {
        Text("עודכן\n\(userInfo?.registrationDate ?? "")\n\(userInfo?.registrationHour ?? "")")
            .font(.system(size: 15).bold())
            .foregroundColor(Color.black)
            .frame(alignment: .trailing)
    }
    
 

    
    var userName:some View {
        Text(userInfo?.name ?? "")
            .font(.system(size: 18).bold())
            .foregroundColor(Color.black)
    }
    
    var body: some View {
       
        ZStack{
            AnimatedBackground().edgesIgnoringSafeArea(.all)
            VStack{
                ZStack(alignment: .leading){
                    returnButton
                    VStack{
                        personDataHeadline
                    }.frame(maxWidth: .infinity)
                }.frame(maxWidth: .infinity)
                ZStack{
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .shadow(color: .gray, radius: 8)
                    VStack{
                        HStack (alignment: .top){
                            VStack{
                                userImage
                            }
                            VStack{
                                userInformation
                                
                                if let logoImage = UIImage(named: "isrf") {
                                    Image(uiImage: logoImage)
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 36, height: 36, alignment: .center)
                                }
                                Spacer()
                            }
                        }.padding(.top, 20)
                            .padding(.leading, 20)
                            userName
                            Text("אזרח")
                                .font(.system(size: 14).bold())
                                .foregroundColor(.green)

                            Rectangle().fill(.gray)
                                .frame(maxWidth: .infinity, minHeight: 0.5, maxHeight: 0.5)
                                .padding(.leading, 4)
                                .padding(.trailing, 4)
                                .padding(.top, 20)

                        ZStack{
                            if let backgroundImage = UIImage(named: "background_logo") {
                                Image(uiImage: backgroundImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(maxWidth: .infinity)
                                    
                            }
                            HStack{
                                VStack(spacing: 20) {
                                    VStack(alignment: .leading) {
                                        Text("מספר ת.ז")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.black)
                                        Text(userInfo?.idNum ?? "")
                                            .font(.system(size: 18).bold())
                                            .foregroundColor(Color.black)
                                        //.padding(.top, 2)
                                    }
                                    VStack(alignment: .leading) {
                                        Text("תוקף עד")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.black)
                                        Text(userInfo?.expireDate.formateDate() ?? "" )
                                            .font(.system(size: 18).bold())
                                            .foregroundColor(Color.black)
                                    }
                                    VStack(alignment: .leading) {
                                        Text("תאריך לידה")
                                            .font(.system(size: 14))
                                            .foregroundColor(Color.black)
                                        Text(userInfo?.birthDate.formateDate() ?? "" )
                                            .font(.system(size: 18).bold())
                                            .foregroundColor(Color.black)
                                    }
                                }
                                Spacer()
                                Image(uiImage:SettingsStore().userInfo.QRCode.generateQRCode())
                                    .interpolation(.none)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 130, height: 130, alignment: .center)
                                
                            }
                        }
                        .padding(.top, 20)
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .padding(.bottom, 40)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 40)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                Spacer().frame(maxWidth: .infinity, maxHeight: .infinity)
                
            }.frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(.leading, 20)
                .padding(.trailing, 20)
                .padding(.top, 60)

        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear{
                userInfo = SettingsStore().userInfo
            }
              
    }
    
    
    
    
    func withCloseAction(_ action: @escaping CloseAction)-> Self{
        var clone  = self
        clone.close = action
        return clone
    }
    
}


struct AnimatedBackground: View{
    @State var start = UnitPoint(x:0,y: -2)
    @State var end = UnitPoint(x: 4, y:0)
    
    let timer = Timer.publish(every: 1, on: .main, in: .default).autoconnect()
    let colors = [Color.blue,Color.gray,Color.white]
    
    
    var body: some View{
        LinearGradient(gradient: Gradient(colors: colors), startPoint: start, endPoint: end)
            .animation(Animation.easeInOut(duration: 3).repeatForever())
            .onReceive(timer, perform: { _ in
                self.start = UnitPoint(x:4,y:0)
                self.end = UnitPoint(x:-2,y:2)
                self.start = UnitPoint(x:-4,y:20)
                self.start = UnitPoint(x:4,y:0)
            })
    }
}




struct viewDocumentation_Previews: PreviewProvider {
    static var previews: some View {
        viewDocumentation()
    }
}
