//
//  SettingView.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/21/24.
//

import SwiftUI
import ComposableArchitecture
import HapticsManager

struct SettingView : View {
    @State var store : StoreOf<SettingFeature>
    
    @AppStorage(HapticUserDefaultsKey.hapticEffectsEnabled, store: .haptics)
    var isHapticsEnabled: Bool = false
    @State var flag = false
    
    var body : some View {
        GeometryReader { geometry in
            ZStack {
                
                // 배경 이미지
                Image(Background(rawValue: store.selectedBackground.rawValue)!.fileName)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing:0){
                    
                    HStack{
                        Text("설정")
                            .font(Font.customFont(Font.h6))
                            .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.97))
                            .padding(.bottom,15)
                        
                    }
                    .frame(height : geometry.size.height * 0.1)
                    .padding(.top , geometry.size.height * 0.07)
                    
                    VStack(alignment: .leading, spacing: 25) {
//                        HStack{
//                            
//                            Text("알림")
//                                .font(Font.customFont(Font.body1Regular))
//                                .lineSpacing(28.80)
//                                .foregroundColor(Color.decoSheetTextColor)
//                            Spacer()
//                            
//                            
//                            Toggle("", isOn: $flag)
//                                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "A5CD3B")))
//                        }
                        
                        HStack{
                            Text("햅틱 진동")
                                .font(Font.customFont(Font.body1Regular))
                                .foregroundColor(Color.decoSheetTextColor)
                            Spacer()
                            
                            Toggle("햅틱 진동", isOn: $isHapticsEnabled)
                                .onChange(of: isHapticsEnabled) {
                                        // 여기서만 진동 관련 처리
                                        UserDefaults.haptics.set(isHapticsEnabled, for: HapticUserDefaultsKey.hapticEffectsEnabled)
                                }
                                .toggleStyle(SwitchToggleStyle(tint: Color(hex: "A5CD3B")))
                        }
                        
                        HStack{
                            
                            Text("배경 음악")
                                .font(Font.customFont(Font.body1Regular))
                                .foregroundColor(Color.decoSheetTextColor)
                            Spacer()
                            
                            MusicToggleView()
                        }
                        
                        
                        Divider()
                        
                        Text("돌하루방 응원하기")
                            .font(Font.customFont(Font.body1Regular))
                            .foregroundColor(Color.decoSheetTextColor)
                        
                        InquiryView()
                        
                        Divider()
                        
                        Link("회원 탈퇴", destination: URL(string: "https://apps.kakao.com/disconnected/app/1113293?lang=ko")!)
                            .font(Font.customFont(Font.body1Regular))
                            .foregroundColor(Color.decoSheetTextColor)
                        
                        Spacer()
                        
                        Text("BGM 출처\nYOUTUBE [HYP - Spring Has Come]\nhttps://www.youtube.com/watch?v=fhSzUbsd5cY")
                            .font(Font.customFont(Font.body5Regular))
                            .foregroundColor(Color.decoSheetTabbar)
                        
                        
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


