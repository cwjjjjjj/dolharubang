//
//  ShareView.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/23/24.
//
import ComposableArchitecture
import SwiftUI

struct ShareView: View {
    @Binding var showPopup: Bool // 팝업 표시 여부
    @Binding var DolImage: UIImage

    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 24)
            
            HStack {
                Text("돌 공유하기")
                    .font(Font.customFont(Font.subtitle3))
                    .foregroundColor(.decoSheetGreen)
                    .padding(.leading, 24)
                
                Spacer()
                
                Button(action: {
                    showPopup = false
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.placeHolder)
                }
                .padding(.trailing, 24)
            }
            
            Spacer().frame(height: 20)
            
            Divider()
            
            Image(uiImage: DolImage)
                         .resizable()
                         .scaledToFit()
                         .frame(width: 200, height: 200) // 원하는 크기로 조절

            
            Spacer()
        }
        .frame(width: 320, height: 320)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 10)
        
    }
}
