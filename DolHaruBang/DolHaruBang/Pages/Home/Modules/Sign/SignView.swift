//
//  SignView.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/23/24.
//

import ComposableArchitecture
import SwiftUI

struct SignView: View {
    @Binding var showPopup: Bool // 팝업 표시 여부
    @Binding var message : String

    var body: some View {
        VStack(alignment: .center) {
            Spacer().frame(height: 24)
            
            HStack {
                Text("펫말")
                    .font(Font.customFont(Font.subtitle3))
                    .foregroundColor(.decoSheetGreen)
                    .padding(.leading, 24)
                
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

            
            TextField("", text: $message)
                .foregroundColor(.black) // 입력된 텍스트 색상
            
            Spacer()
        }
        .frame(width: 320, height: 200)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 10)
        
    }
}
