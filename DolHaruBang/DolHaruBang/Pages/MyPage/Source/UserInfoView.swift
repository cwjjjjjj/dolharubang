////
////  UserInfoView.swift
////  DolHaruBang
////
////  Created by 양희태 on 9/24/24.
////
//
//import SwiftUI
//import ComposableArchitecture
//
//struct UserInfoView : View {
//    var body: some View{
//        
//        VStack(alignment: .center){
//            // 프로필 수정
//            HStack(spacing:0){
//                Spacer()
//                buttonView()
//            }
//            
//            // 프로필 이미지
//            ZStack{
//                
//                if store.selectedImage != nil {
//                    // 선택된 이미지가 있을 때
//                    Image(uiImage: store.selectedImage!)
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 108, height: 108)
//                        .clipShape(Circle()) // 이미지를 원형으로 클리핑
//                } else {
//                    // 선택된 이미지가 없을 때
//                    Image("normalprofile")
//                        .resizable()
//                        .aspectRatio(contentMode: .fill)
//                        .frame(width: 108, height: 108)
//                        .clipShape(Circle())
//                }
//
//                
//                // 오른쪽 위에 플러스 버튼 배치
//                
//                if store.selectedProfileEdit {
//                            plusButton()
//                                .offset(x: 40, y: -40)
//                        }
//            }
//            
//           
//            VStack(spacing : 12){
//                
//                if store.selectedProfileEdit {
//                                trueContent()
//                        .frame(width: 210, height: 65)
//                            } else {
//                                falseContent()
//                                    .frame(width: 210, height: 65)
//                            }
//                
//                // 탄생석, 사용자 생년월일
//                HStack(spacing: 8) {
//                    HStack(spacing: 10) {
//                        Text("가넷")
//                            .font(Font.custom("NanumSquareRound", size: 12).weight(.bold))
//                            .lineSpacing(21.60)
//                            .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.97))
//                    }
//                    .padding(6)
//                    .background(Color(red: 0.79, green: 0.32, blue: 0.17))
//                    .cornerRadius(20)
//                    Text("2000년 01월 13일")
//                        .font(Font.custom("NanumSquareRound", size: 14).weight(.bold))
//                        .lineSpacing(25.20)
//                        .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
//                }
//                .frame(width: 152, height: 21)
//                
//                // 사용자 이메일 주소
//                Text("bahaea@*****.com")// 텍스트 선택 비활성화 (iOS 15 이상에서 가능)
//                    .font(Font.custom("NanumSquareRound", size: 12))
//                    .lineSpacing(21.60)
//                    .foregroundColor(Color(hex: "837C74"))
//                
//                
//            }.padding(.bottom,20).animation(.easeIn, value: store.selectedProfileEdit)
//            
//         
//                
//            }.padding(.bottom , 24).padding(.top,25)
//            
//            
//        }// 하얀 배경 VStack
//        
//        
//    }
//    
//    
//    
//    
//    @ViewBuilder
//    private func buttonView() -> some View {
//        let buttonTitle = store.selectedProfileEdit ? "완료" : "프로필 수정"
//        let buttonAction: () -> Void = store.selectedProfileEdit ? {
//            store.send(.completeEditProfile)
//        } : {
//            store.send(.clickEditProfile)
//        }
//        
//        Button(action: buttonAction) {
//            HStack {
//                Text(buttonTitle)
//                    .font(Font.custom("NanumSquareRound", size: 12).weight(.heavy))
//                    .lineSpacing(19.20)
//                    .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.97))
//            }
//            .frame(width: 82, height: 29)
//            .background(Color(red: 0.65, green: 0.80, blue: 0.23))
//            .cornerRadius(14)
//            .padding(15)
//        }
//    }
//    
//    @ViewBuilder
//    // 사진 추가 버튼
//    private func plusButton() -> some View {
//            Button(action: {
//                store.send(.clickPlusButton)
//            }) {
//                ZStack {
//                    Circle()
//                        .fill(Color(hex: "A5CD3B"))
//                        .frame(width: 32, height: 32)
//                    
//                    Image(systemName: "plus")
//                        .resizable()
//                        .frame(width: 12, height: 12)
//                        .foregroundColor(.white)
//                }
//            }
//        }// 사진추가버튼
//    
//    
//    // 프로필 수정 페이지
//    @ViewBuilder
//      private func trueContent() -> some View {
//          VStack {
//              HStack(spacing : 6){
//                  Image("human")
//                      .resizable()
//                      .aspectRatio(contentMode: .fit)
//                      .frame(width: 16, height: 16)
//                  HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
//                  Text("해인")
//                      .font(Font.custom("NanumSquareRound", size: 14).weight(.bold))
//                      .lineSpacing(28.80)
//                      .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
//              }
//              .padding(EdgeInsets(top: 11, leading: 0, bottom: 11, trailing: 0))
//              .frame(width: 184, height: 32)
//              .background(Color(red: 0.95, green: 0.93, blue: 0.91))
//              .cornerRadius(16)
//              }
//                  
//              HStack(spacing:6){
//                  Image("home")
//                      .resizable()
//                      .aspectRatio(contentMode: .fit)
//                      .frame(width: 16, height: 16)
//                  HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
//                      Text("돌돌이의방")
//                          .font(Font.custom("NanumSquareRound", size: 14).weight(.bold))
//                          .lineSpacing(28.80)
//                          .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
//                  }
//                  .padding(EdgeInsets(top: 11, leading: 0, bottom: 11, trailing: 0))
//                  .frame(width: 184, height: 32)
//                  .background(Color(red: 0.95, green: 0.93, blue: 0.91))
//                  .cornerRadius(16)
//              }
//             
//          }
//      }
//
//      @ViewBuilder
//      private func falseContent() -> some View {
//          VStack {
//              // 사용자명
//              Text("해인")
//                  .font(Font.custom("NanumSquareRound", size: 22).weight(.bold))
//                  .lineSpacing(35.20)
//                  .foregroundColor(Color(red: 0.38, green: 0.52, blue: 0))
//
//              // 돌 집 이름
//              HStack(spacing: 8) {
//                  Image("home")
//                      .resizable()
//                      .aspectRatio(contentMode: .fit)
//
//                  Text("돌돌이방")
//                      .font(Font.custom("NanumSquareRound", size: 18).weight(.bold))
//                      .lineSpacing(28.80)
//                      .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
//              }
//              .frame(width: 89, height: 17)
//          }
//      }
//}
