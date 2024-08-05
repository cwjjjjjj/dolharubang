//
//  HomeView.swift
//  DolHaruBang
//
//  Created by 양희태 on 7/31/24.
//

import SwiftUI
import ComposableArchitecture

struct HomeView : View {
    @State var store: StoreOf<HomeFeature>
    
    var body : some View {
            GeometryReader { geometry in
                ZStack {
                    Color.mainGreen
                        .edgesIgnoringSafeArea(.all)
                    VStack {
                        HStack{
                            Spacer()
                            Button("꾸미기"){
                                store.send(.clickDecoration)
                            }
                        }.padding([.top , .trailing], 40)
                        Spacer()
                        Button("돌이미지"){
                            store.send(.clickProfile)
                        }
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
                                    font: .customFont(Font.button1)
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
                        
                        
                        HStack{
                            BottomButtonView(imageName: "calendar", buttonText: "달력", destination: AnyView(LoginView()))
                            BottomButtonView(imageName: "bubble.right.fill", buttonText: "하루방", destination: AnyView(LoginView()))
                            BottomButtonView(imageName: "house.fill", buttonText: "홈", destination: AnyView(LoginView()))
                            BottomButtonView(imageName: "leaf.fill", buttonText: "공원", destination: AnyView(LoginView()))
                            BottomButtonView(imageName: "person.crop.circle", buttonText: "마이페이지", destination: AnyView(LoginView()))
                            
                        }
                    }
                    .ignoresSafeArea()
                    .frame(height: geometry.size.height)
                    .keyboardResponder(isKeyboardVisible: $store.isKeyboardVisible)
                    
                }
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

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeView(store: Store(initialState: HomeFeature.State()) {
            HomeFeature()
                ._printChanges()
          })
    }
}
