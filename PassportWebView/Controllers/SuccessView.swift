//
//  SuccessView.swift
//  PassportWebView
//
//  Created by Ameya on 2022/12/2.
//

import SwiftUI

struct SuccessView: View {
    typealias CloseAction = () -> Void
    var close: CloseAction?
    var successView: some View {
        ZStack {
            
            
            if let logoImage = UIImage(named: "success") {
                Image(uiImage: logoImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    
            }
        }
        .frame(maxWidth: .infinity)
    }
    var body: some View {
        ZStack {
            
            VStack {
                Spacer()
                successView
                Spacer()
                
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(35)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .onAppear(perform: {
            Timer.scheduledTimer(withTimeInterval:5.0, repeats: false) {
                 time in
                close?()
            }
         })
    }
    
    func withCloseAction(_ action: @escaping CloseAction) -> Self {
        var clone = self
        clone.close = action
        return clone
    }
    
}

struct SuccessView_Previews: PreviewProvider {
    static var previews: some View {
        SuccessView()
    }
}
