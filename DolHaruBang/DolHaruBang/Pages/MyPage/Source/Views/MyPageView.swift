//
//  MyPageView.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/31/24.
//

import SwiftUI
import ComposableArchitecture

struct MyPageView : View {
    @Bindable var store : StoreOf<MyPageFeature>
    
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
                        Text("마이페이지")
                            .font(Font.customFont(Font.h6))
                            .lineSpacing(41.60)
                            .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.97))
                            .padding(.bottom,15)
                        
                    }
                    .frame(height : geometry.size.height * 0.1)
                    .padding(.top , geometry.size.height * 0.07)
                    
                    VStack(alignment: .center){
                        
                        // 프로필 수정
                        HStack(spacing:0){
                            Spacer()
                            buttonView()
                        }
                        
                        if let userinfo = store.userInfo {
                            // 프로필 이미지
                            ZStack{
                                
                                if store.selectedImage != nil {
                                    // 선택된 이미지가 있을 때
                                    Image(uiImage: store.selectedImage!)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 108, height: 108)
                                        .clipShape(Circle()) // 이미지를 원형으로 클리핑
                                } else {
                                    // 선택된 이미지가 없을 때
                                    Image("normalprofile")
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 108, height: 108)
                                        .clipShape(Circle())
                                }

                                
                                // 오른쪽 위에 플러스 버튼 배치
                                
                                if store.selectedProfileEdit {
                                            plusButton()
                                                .offset(x: 40, y: -40)
                                        }
                            }
                            
                           
                            VStack(spacing : 12){
                                
                                if store.selectedProfileEdit {
                                    VStack {
                                       HStack(spacing : 6){
                                           Image("human")
                                               .resizable()
                                               .aspectRatio(contentMode: .fit)
                                               .frame(width: 16, height: 16)
                                           HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
                                               TextField("", text: $store.userName.sending(\.userNameChanged))
                                                   .font(.customFont(Font.button2))
                                                   .lineSpacing(28.80)
                                                   .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                                                   .multilineTextAlignment(.center) // 텍스트 중앙 정렬
                                                   .textFieldStyle(PlainTextFieldStyle()) // 텍스트 필드 스타일 설정 (필요에 따라 다른 스타일 적용 가능)
                                                  
                                       }
                                       .padding(EdgeInsets(top: 11, leading: 0, bottom: 11, trailing: 0))
                                       .frame(width: 184, height: 32)
                                       .background(Color(red: 0.95, green: 0.93, blue: 0.91))
                                       .cornerRadius(16)
                                       }
                                           
                                       HStack(spacing:6){
                                           Image("home")
                                               .resizable()
                                               .aspectRatio(contentMode: .fit)
                                               .frame(width: 16, height: 16)
                                           HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
                                               TextField("", text: $store.roomName.sending(\.roomNameChanged))
                                                   .font(.customFont(Font.button2))
                                                   .lineSpacing(28.80)
                                                   .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                                                   .multilineTextAlignment(.center) // 텍스트 중앙 정렬
                                                   .textFieldStyle(PlainTextFieldStyle())
                                                
                                           }
                                           .padding(EdgeInsets(top: 11, leading: 0, bottom: 11, trailing: 0))
                                           .frame(width: 184, height: 32)
                                           .background(Color(red: 0.95, green: 0.93, blue: 0.91))
                                           .cornerRadius(16)
                                       }
                                      
                                   }
                                        .frame(width: 210, height: 65)
                                            } else {
                                                falseContent(username: store.userName, roomname: store.roomName)
                                                    .frame(width: 210, height: 65)
                                            }
                                
                                // 탄생석, 사용자 생년월일
                                HStack(spacing: 8) {
                                    HStack(spacing: 10) {
                                        Text("\(userinfo.birthStone)")
                                            .font(Font.customFont(Font.body3Bold))
                                            .lineSpacing(21.60)
                                            .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.97))
                                    }
                                    .padding(6)
                                    .background(Color(red: 0.79, green: 0.32, blue: 0.17))
                                    .cornerRadius(20)
//                                    Text("\(userinfo.birthDay)")
//                                        .font(Font.customFont(Font.body3Bold))
//                                        .lineSpacing(25.20)
//                                        .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                                }
                                .frame(width: 152, height: 21)
                                
                                // 사용자 이메일 주소
                                Text("\(userinfo.emailAddress)")// 텍스트 선택 비활성화 (iOS 15 이상에서 가능)
                                    .font(Font.customFont(Font.body2Bold))
                                    .lineSpacing(21.60)
                                    .foregroundColor(Color(hex: "837C74"))
                                
                                
                            }.padding(.bottom,20).animation(.easeIn, value: store.selectedProfileEdit)
                            
                        }
                        
                        
                        Divider()
                            .frame(width: 353, height: 0.4) // 길이와 두께 설정
                            .background(Color(red: 0.90, green: 0.87, blue: 0.84).opacity(0.50)) // 색상과 투명도 설정
                        
                        Button(action: {
                            store.send(.trophyButtonTapped)
                        }) {
                            Image("trophy")
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 132, height: 132)
                                .padding(.top, 20)
                        }
                        
                        
                        HStack(spacing: 8){
                            Button(action: {
                                store.send(.settingButtonTapped)
                            }){
                                HStack{
                                    Text("설정")
                                        .font(Font.customFont(Font.body3Bold))
                                        .lineSpacing(19.20)
                                        .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                                }
                                .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
                                .background(.white)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .inset(by: 0.50)
                                        .stroke(Color(red: 0.51, green: 0.49, blue: 0.45), lineWidth: 0.50)
                                )
                            }.withHaptic()
                            
                            
                            Button(action: {
                                TokenManager.shared.clearTokens()
                                
                            }){
                                HStack{
                                    Text("로그아웃")
                                        .font(Font.customFont(Font.body3Bold))
                                        .lineSpacing(19.20)
                                        .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                                }
                                .padding(EdgeInsets(top: 10, leading: 12, bottom: 10, trailing: 12))
                                .background(.white)
                                .cornerRadius(14)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .inset(by: 0.50)
                                        .stroke(Color(red: 0.51, green: 0.49, blue: 0.45), lineWidth: 0.50)
                                )
                            }
                            
                        }.padding(.bottom , 24).padding(.top,25)
                        
                        
                    }// 하얀 배경 VStack
                    .frame(width: geometry.size.width ,height : geometry.size.height * 0.78)
                    .background(Color(red: 0.98, green: 0.98, blue: 0.97))
                    .cornerRadius(15) // 뭉툭한 테두리
                    
                    Spacer()
                }
                
                
                
                
                
            } // ZStack
            .onAppear {
                store.send(.fetchUserInfo)
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true) // 기본 뒤로가기 버튼 숨기
            .sheet(isPresented: $store.showImagePicker) {
                ImagePicker(sourceType: .photoLibrary) { image in
                    store.send(.selectImage(image))
                }
            }
        }
      
        
        
        // 프로필 버튼 수정
        
        
    }
    
    @ViewBuilder
    private func buttonView() -> some View {
        let buttonTitle = store.selectedProfileEdit ? "완료" : "프로필 수정"
        let buttonAction: () -> Void = store.selectedProfileEdit ? {
            store.send(.completeEditProfile)
        } : {
            store.send(.clickEditProfile)
        }
        
        Button(action: buttonAction) {
            HStack {
                Text(buttonTitle)
                    .font(Font.customFont(Font.body3Bold))
                    .lineSpacing(19.20)
                    .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.97))
            }
            .frame(width: 82, height: 29)
            .background(Color(red: 0.65, green: 0.80, blue: 0.23))
            .cornerRadius(14)
            .padding(15)
        }
    }
    
    
    @ViewBuilder
    // 사진 추가 버튼
    private func plusButton() -> some View {
            Button(action: {
                store.send(.clickPlusButton)
            }) {
                ZStack {
                    Circle()
                        .fill(Color(hex: "A5CD3B"))
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: 12, height: 12)
                        .foregroundColor(.white)
                }
            }
        }// 사진추가버튼
    
    
    // 프로필 수정 페이지
    @ViewBuilder
    private func trueContent() -> some View {
           VStack {
              HStack(spacing : 6){
                  Image("human")
                      .resizable()
                      .aspectRatio(contentMode: .fit)
                      .frame(width: 16, height: 16)
                  HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
                      TextField("방 이름을 입력하세요", text: $store.userName.sending(\.userNameChanged))
//                          .font(Font.custom("NanumSquareRound", size: 14).weight(.bold))
                          .lineSpacing(28.80)
                          .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                          .textFieldStyle(PlainTextFieldStyle()) // 텍스트 필드 스타일 설정 (필요에 따라 다른 스타일 적용 가능)
              }
              .padding(.vertical, 11)
              .frame(width: 184, height: 32)
              .background(Color(red: 0.95, green: 0.93, blue: 0.91))
              .cornerRadius(16)
              }
                  
              HStack(spacing:6){
                  Image("home")
                      .resizable()
                      .scaledToFit()
                      .frame(width: 8, height: 8)
                  HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
                      Text("돌돌이")
                          .font(Font.customFont(Font.body2Bold))
                          .lineSpacing(28.80)
                          .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                  }
                  .padding(.vertical, 11)
                  .frame(width: 184, height: 32)
                  .background(Color(red: 0.95, green: 0.93, blue: 0.91))
                  .cornerRadius(16)
              }
             
          }
      }

      @ViewBuilder
      private func falseContent(username : String, roomname : String) -> some View {
          VStack {
              // 사용자명
              Text(username)
                  .font(Font.customFont(Font.subtitle2))
                  .lineSpacing(35.20)
                  .foregroundColor(Color(red: 0.38, green: 0.52, blue: 0))

              // 돌 집 이름
              HStack(spacing: 8) {
                  Image("home")
                      .resizable()
                      .scaledToFit()
                      .frame(width: 16, height: 17)

                  Text(roomname)
                      .font(Font.customFont(Font.subtitle3))
                      .lineSpacing(28.80)
                      .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
              }
          }
      }
}
