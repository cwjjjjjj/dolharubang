//
//  MailView.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/25/24.
//

import ComposableArchitecture
import SwiftUI

struct MailView: View {
    @Binding var showPopup: Bool // 팝업 표시 여부

    var body: some View {
        VStack(alignment: .center) {
            Spacer().frame(height: 24)
            
            HStack(spacing: 6) {
                Text("우편함")
                    .font(Font.customFont(Font.subtitle3))
                    .foregroundColor(.decoSheetGreen)
                    .padding(.leading, 24)
                
                Text("최근 7일동안 받은 우편")
                    .font(Font.customFont(Font.body5Regular))
                    .lineSpacing(13)
                    .foregroundColor(Color(red: 0.65, green: 0.61, blue: 0.57));
               
                Spacer()
                
                Button(action: {
                    showPopup = false
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.placeHolder)
                }
                .padding(.trailing, 24)
            }
            
            Spacer().frame(height: 20)
            
            Divider()

            //
            
            Spacer()
        }
        .frame(width: 320, height: 400)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 10)
        
    }
}
