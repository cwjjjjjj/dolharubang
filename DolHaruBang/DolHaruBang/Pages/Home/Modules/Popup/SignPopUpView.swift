//
//  SignPopUpView.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/3/24.
//
import SwiftUI

struct MyTextFieldAlert: View {
    
    @Binding var isShown: Bool
    @Binding var text : String
    let screenSize = UIScreen.main.bounds
    let title = "타이틀"
    
    var body: some View {
        
        VStack {
            Text(title)
            TextField("텍스트 필드", text: $text)
            HStack {
                Button("추가") {
                    isShown.toggle()
                }
                Button("취소") {
                    isShown.toggle()
                }
            }
        }.padding()
            .frame(width: screenSize.width * 0.7, height: screenSize.height * 0.3)
            .background(.gray)
            .clipShape(RoundedRectangle(cornerRadius: 20.0, style: .continuous))
            .offset(y: isShown ? 0 : screenSize.height)
    }
}
