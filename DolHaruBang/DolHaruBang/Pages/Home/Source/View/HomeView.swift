//
//  HomeView.swift
//  DolHaruBang
//
//  Created by 양희태 on 7/31/24.
//

import SwiftUI
import ComposableArchitecture
import RealityKit


struct HomeView : View {
    @State var store: StoreOf<HomeFeature>
    
    var body : some View {
            GeometryReader { geometry in
                ZStack {
                    // 배경이미지 설정
                    // 추후 통신을 통해 받아오면 됨
                    Image("background")
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                    
                    // 메인 컴포넌트들
                    VStack {
                        // 상단 부분
                        HStack{
                            // 재화갯수
                            Button(action: {
                                // 추후 추가
                            }) {
                                HStack {
                                    Image(systemName: "circle")
                                        .font(.system(size: 11))
                                        .foregroundColor(.brown)
                                    Text("20")
                                        .font(.system(size: 11))
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                }
                                .padding()
                                .background(Color.clear)
                            }
                            .clipShape(Circle()) // Makes the button circular
                            .frame(width: geometry.size.width * 0.3)
                            
                            Text("돌돌이 방")
                                .font(.title)
                                .frame(maxWidth: .infinity, alignment: .center)
                            
                            // 공유, 꾸미기
                            HStack(spacing: 0){
                                Button(action: {
                                    store.send(.clickDecoration)
                                }) {
                                    VStack {
                                        Image(systemName: "square.and.arrow.up")
                                            .font(.system(size: 22))
                                            .foregroundColor(.white)
                                    }
                                    .padding()
                                    .background(Color.clear)
                                    
                                }
                                
                                Button(action: {
                                    store.send(.clickDecoration)
                                }) {
                                    VStack {
                                        Image(systemName: "pencil")
                                            .font(.system(size: 16))
                                            .foregroundColor(.white)
                                        Text("꾸미기")
                                            .font(.system(size: 11))
                                            .fontWeight(.bold)
                                            .foregroundColor(.white)
                                            .lineLimit(1)
                                            .minimumScaleFactor(0.5)
                                    }
                                    .padding(10)
                                    .background(Color.clear)
                                    
                                }
                                .clipShape(Circle())
                                .overlay(
                                    Circle()
                                        .stroke(Color.gray, lineWidth: 1) // 테두리 추가
                                )
                                .shadow(radius: 10) // 그림자 추가
                            }
                            .frame(width: geometry.size.width * 0.3)
                         
                            
                        
                        }.frame(height : geometry.size.height * 0.1).padding(.top , 20)
                        
                        
                        Spacer()
                        
                            Image("cupid2")
                                .resizable()
                                .frame(width: 200,height: 200)
                        
                       
                        
                        Spacer()
                        VStack{
                            
                            if store.ability{
                                HStack{
                                    Button(action: {
                                        
                                    }){
                                        VStack{
                                            Text("능력")
                                                .font(.system(size: 11)) // Adjust text size as needed
                                                .fontWeight(.bold)
                                                .foregroundColor(store.ability ? .black: .white)
                                                .padding()// Text
                                        }
                                        .frame(height: geometry.size.width * 0.1)
                                        .background(.yellow).cornerRadius(20)
                                    }
                                }.transition(.opacity) // 애니메이션 전환 효과
                                .animation(.easeInOut, value: store.ability)
                            }
                            
                            
                            HStack{
                                Button(action: {
                                    store.send(.clickAbility)
                                }) {
                                    VStack {
                                        Image(systemName: "star") // Replace with your icon name
                                            .font(.system(size: 11)) // Adjust size as needed
                                            .foregroundColor(store.ability ? .yellow: .orange) // Icon color
                                        Text("능력")
                                            .font(.system(size: 11)) // Adjust text size as needed
                                            .fontWeight(.bold)
                                            .foregroundColor(store.ability ? .yellow: .orange) // Text color
                                    }
                                    .padding()
                                    .background(store.ability ? .orange : .yellow) // Button background color
                                    
                                }
                                .clipShape(Circle()) // Makes the button circular
                                .frame(width: geometry.size.width * 0.2, height: geometry.size.width * 0.2)
                                
                                
                                CustomTextField(
                                    text: $store.message,
                                    placeholder: "돌에게 말을 걸어보세요",
                                    font: .customFont(Font.button1), maxLength: 40
                                )
                                .frame(width: geometry.size.width * 0.6, height: geometry.size.width * 0.1)
                                .cornerRadius(25)
                                
                                Button(action: {store.send(.clickMessage)}){
                                    Image(systemName: "envelope.fill")
                                        .font(.system(size: 24))
                                        .foregroundColor(.white)
                                        .padding()
                                }
                                
                            }
                        }
                        .offset(y: store.isKeyboardVisible ? -geometry.size.height * 0.4 : 0)
                        .animation(.easeInOut, value: store.isKeyboardVisible)
                        
                      
                        // 하단 버튼들
                        HStack{
                            BottomButtonView(imageName: "calendar", buttonText: "달력", destination: AnyView(ContentVieww()))
                            BottomButtonView(imageName: "bubble.right.fill", buttonText: "하루방", destination: AnyView(LoginView()))
                            BottomButtonView(imageName: "house.fill", buttonText: "홈", destination: AnyView(LoginView()))
                            BottomButtonView(imageName: "leaf.fill", buttonText: "공원", destination: AnyView(LoginView()))
                            BottomButtonView(imageName: "person.crop.circle", buttonText: "마이페이지", destination: AnyView(LoginView()))
                            
                        }
                        .padding(.bottom , geometry.size.height * 0.035)
                        
                    }
                    
                }
//                .navigationBarHidden(true)
//                .ignoresSafeArea(.all)
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true) // 기본 뒤로가기 버튼 숨기기
                .frame(height: geometry.size.height)
                .keyboardResponder(isKeyboardVisible: $store.isKeyboardVisible)
                .onAppear (perform : UIApplication.shared.hideKeyboard)
            
            }
        
        
        
    }
}



struct BottomButtonView: View {
    var imageName: String
    var buttonText: String
    var destination: AnyView

    var body: some View {
            HStack {
                NavigationLink(destination: destination) {
                    ZStack {
                        VStack{
                            HStack {
                                Spacer().frame(width: 20)
                                Image(systemName: imageName)
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            HStack {
                                Spacer()
                                Text(buttonText)
                                    .font(.system(size: 10))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                Spacer()
                            }
                        }
                    }
                    .frame(width: 64, height: 64)
                    .background(Color.mainBrown)
                    .cornerRadius(15)
                    .padding(.bottom, 23)
                }
            }
        
    }
}

//struct HomeView_Previews: PreviewProvider {
//    static var previews: some View {
//        HomeView(store: Store(initialState: HomeFeature.State()) {
//            HomeFeature()
//                ._printChanges()
//          })
//    }
//}
