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
        VStack(alignment: .center,spacing: 12) {
            
            HStack {
                Text("돌 공유하기")
                    .font(Font.customFont(Font.subtitle3))
                    .foregroundColor(.decoSheetGreen)
                    .padding(.leading, 118)
                
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
            }.padding(.top, 20)
            
            VStack{
                Image(uiImage: DolImage)
                    .resizable()
                    .scaledToFit()// 원하는 크기로 조절
            }
            .background(Color.semigray)
            .frame(width: 272, height: 272)
            .cornerRadius(15)
            .padding(10)
            
            
            HStack(spacing:8){
                Spacer()
                Button(action: {
                }) {
                    Image("kakao")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                
                Button(action: {
                }) {
                    Image("instagram")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                
                Button(action: {
                }) {
                    Image("image_download")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 40, height: 40)
                }
                Spacer()
            }
            Spacer()
        }
        .frame(width: 320, height: 400)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 10)
        
    }
}
