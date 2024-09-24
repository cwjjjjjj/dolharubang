//
//  ProfileView.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/25/24.
//


import ComposableArchitecture
import SwiftUI

struct ProfileView: View {
    @Binding var showPopup: Bool // 팝업 표시 여부
    @State var captureDol : UIImage

    @State var store: StoreOf<ProfileFeature> // Store로 상태 및 액션 전달
    
    var body: some View {
        VStack(alignment: .center) {
            Spacer().frame(height: 24)
            
            HStack {
                Text("돌 프로필")
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
            if let profile = store.profile {
                VStack{
                    // 상단 부분
                    HStack{
                        //이미지
                        Image(uiImage: captureDol)
                                     .resizable()
                                     .scaledToFit()
                                     .frame(width: 100, height: 100) // 원하는 크기로 조절
                                     .padding(24)
                        
                        VStack{
                            HStack(spacing:8){
                                Text("\(profile.dolName)")
                                      .font(Font.customFont(Font.subtitle3))
                                      .lineSpacing(28.80)
                                      .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                               
                            }
                            
                            VStack(alignment: .leading, spacing: 12) {
                                    HStack(spacing: 6) {
                                      Text("성격")
                                        .font(Font.custom("NanumSquareRound", size: 11))
                                        .lineSpacing(19.80)
                                        .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                                        Text("\(profile.personality)")
                                        .font(Font.custom("NanumSquareRound", size: 11))
                                        .lineSpacing(19.80)
                                        .foregroundColor(Color(red: 0.38, green: 0.52, blue: 0))
                                    }
                                    .frame(width: 156)
                                    HStack(spacing: 6) {
                                      Text("초기능력")
                                        .font(Font.custom("NanumSquareRound", size: 11))
                                        .lineSpacing(19.80)
                                        .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                                        Text("\(profile.baseAbility)")
                                        .font(Font.custom("NanumSquareRound", size: 11))
                                        .lineSpacing(19.80)
                                        .foregroundColor(Color(red: 0.38, green: 0.52, blue: 0))
                                    }
                                    .frame(width: 156)
                                    HStack(spacing: 6) {
                                      Text("주운 날")
                                        .font(Font.custom("NanumSquareRound", size: 11))
                                        .lineSpacing(19.80)
                                        .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                                      Text("2024년 7월 10일")
                                        .font(Font.custom("NanumSquareRound", size: 11))
                                        .lineSpacing(19.80)
                                        .foregroundColor(Color(red: 0.38, green: 0.52, blue: 0))
                                    }
                                    .frame(width: 156)
                                  }
                        }
                    }
                    
                    // 게이지
                    VStack{
                            HStack{
                                Text("친밀도")
                                       .font(Font.custom("NanumSquareRound", size: 12).weight(.bold))
                                       .lineSpacing(21.60)
                                       .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                                Text("3Lv")
                                       .font(Font.custom("NanumSquareRound", size: 12).weight(.bold))
                                       .lineSpacing(21.60)
                                       .foregroundColor(Color(red: 0.38, green: 0.52, blue: 0))
                                
                                Spacer()
                                Text("65%")
                                       .font(Font.custom("NanumSquareRound", size: 12).weight(.bold))
                                       .lineSpacing(21.60)
                                       .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                            }
                            
                            // 게이지바
                        ProgressView(value: Double(profile.friendShip), total: 100) // total 값을 원하는 최대치로 설정
                                                              .progressViewStyle(LinearProgressViewStyle())
                                                              .frame(width: 150) // 원하는 너비로 조정
                                                              .accentColor(Color.green) // 색상 변경 가능
                        }
                    
                    Divider()
                    
                    //활성능력탭
                    VStack{
                        Text("활성 능력")
                                .font(Font.custom("NanumSquareRound", size: 12).weight(.bold))
                                .lineSpacing(21.60)
                                .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                        HStack{
                            
                            // activeAbility 반복문
                            ForEach(profile.activeAbility, id: \.self) { ability in
                                HStack(spacing: 10) {
                                     Text("\(ability)")
                                       .font(Font.custom("NanumSquareRound", size: 10).weight(.bold))
                                       .lineSpacing(18)
                                       .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                                   }
                                   .padding(8)
                                   .frame(width: 62, height: 23)
                                   .background(.white)
                                   .cornerRadius(15)
                                   .overlay(
                                     RoundedRectangle(cornerRadius: 15)
                                       .inset(by: 0.25)
                                       .stroke(Color(red: 0.51, green: 0.49, blue: 0.45), lineWidth: 0.25)
                                   )
                            }
                            
                            
                           
                        }
                    }
                    
                    Divider()
                    
                    //잠재능력탭
                    VStack{
                        Text("잠재 능력")
                                .font(Font.custom("NanumSquareRound", size: 12).weight(.bold))
                                .lineSpacing(21.60)
                                .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                        HStack{
                            ForEach(profile.potential, id: \.self) { ability in
                                HStack(spacing: 10) {
                                     Text("🔒 \(ability)")
                                       .font(Font.custom("NanumSquareRound", size: 10).weight(.bold))
                                       .lineSpacing(18)
                                       .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                                   }
                                   .padding(8)
                                   .frame(width: 62, height: 23)
                                   .background(.white)
                                   .cornerRadius(15)
                                   .overlay(
                                     RoundedRectangle(cornerRadius: 15)
                                       .inset(by: 0.25)
                                       .stroke(Color(red: 0.51, green: 0.49, blue: 0.45), lineWidth: 0.25)
                                   )
                            }
                        }
                    }
                }
               
            }
            

            //
            
            Spacer()
        }
        .frame(width: 320, height: 417)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 10)
        .onAppear{
            store.send(.fetchProfile)
        }
        
    }
}
