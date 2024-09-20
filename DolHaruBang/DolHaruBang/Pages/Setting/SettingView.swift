//
//  SettingView.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/21/24.
//

import SwiftUI
import ComposableArchitecture

struct SettingView : View {
    @State var store : StoreOf<SettingFeature>
    
    
    var body : some View {
        GeometryReader { geometry in
            ZStack {
                // 배경이미지 설정
                // 추후 통신을 통해 받아오면 됨
                
                // 배경 이미지
                Image(Background(rawValue: store.selectedBackground.rawValue)!.fileName)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing:0){
                    
                    HStack{
                        Text("설정")
                            .font(Font.custom("Cafe24 Ssurround", size: 26).weight(.bold))
                            .lineSpacing(41.60)
                            .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.97))
                            .padding(.bottom,15)
                        
                    }
                    .frame(height : geometry.size.height * 0.1)
                    .padding(.top , geometry.size.height * 0.07)
                    
                    VStack {
                      Text("설정해유")
                    }
                    .frame(width: geometry.size.width ,height : geometry.size.height * 0.78)
                    .background(Color(red: 0.98, green: 0.98, blue: 0.97))
                    .cornerRadius(15) // 뭉툭한 테두리
                    
                    Spacer()
                    
                }
                
            } // ZStack
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button(action: {
                            store.send(.goBack)
                        }) {
                            Image("BackIcon")
                                .resizable()
                                .frame(width: 38, height: 38)
                        }
                    }
                    .offset(x: 8, y: 8)
                }
            }

        }
    }
}

           
