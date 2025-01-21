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
   
    @StateObject private var settings = AppSettings.shared

    
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
                            .font(Font.customFont(Font.h6))
                            .lineSpacing(41.60)
                            .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.97))
                            .padding(.bottom,15)
                        
                    }
                    .frame(height : geometry.size.height * 0.1)
                    .padding(.top , geometry.size.height * 0.07)
                    
                    VStack(alignment: .leading, spacing: 25) {
                        HStack{
                            
                            Text("알림")
                                .font(Font.customFont(Font.bodyRegular))
                                .lineSpacing(28.80)
                                .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                            Spacer()
                            
                           
                            Toggle("", isOn: $settings.isHapticEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "A5CD3B")))
                        }
                        
                        HStack{
                            Text("햅틱 진동")
                                .font(Font.customFont(Font.bodyRegular))
                                .lineSpacing(28.80)
                                .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                            Spacer()
                            
                            Toggle("", isOn: $settings.isHapticEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "A5CD3B")))
                        }
                        
                        HStack{
                            
                            Text("배경 음악")
                                .font(Font.customFont(Font.bodyRegular))
                                .lineSpacing(28.80)
                                .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                            Spacer()
                            
                            Toggle("", isOn: $settings.isBGMEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "A5CD3B")))
                        }

                        
                        Divider()
                        
                        Text("돌하루방 응원하기")
                            .font(Font.customFont(Font.bodyRegular))
                            .lineSpacing(28.80)
                            .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                        
                        Text("문의하기")
                            .font(Font.customFont(Font.bodyRegular))
                            .lineSpacing(28.80)
                            .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                        
                        Divider()
                        
                        Text("회원 탈퇴")
                            .font(Font.customFont(Font.bodyRegular))
                            .lineSpacing(28.80)
                            .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                        
                        Spacer()
                        
                        Text("BGM 출처\nYOUTUBE [HYP - Spring Has Come]\nhttps://www.youtube.com/watch?v=fhSzUbsd5cY")
                            .font(Font.customFont(Font.body5Regular))
                            .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45));
                           
                            
                    }
                    .padding(30)
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

           
