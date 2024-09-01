//
//  HomeView.swift
//  DolHaruBang
//
//  Created by 양희태 on 7/31/24.
//

import SwiftUI
import UIKit
import ComposableArchitecture


struct HomeView : View {
    @State var store: StoreOf<HomeFeature>
    
    var body : some View {
            GeometryReader { geometry in
                ZStack {
                    // 배경이미지 설정
                    // 추후 통신을 통해 받아오면 됨
                    
                    Image(Background(rawValue: store.selectedBackground.rawValue)!.fileName)
                        .resizable()
                        .scaledToFill()
                        .edgesIgnoringSafeArea(.all)
                    
                    // 메인 컴포넌트들
                    VStack {
                        // 상단 부분
                        HStack{
                            
                            HStack{
                                Button(action: {
                                    // 추후 추가
                                }) {
                                    HStack {
                                        Image("Sand")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 12, height: 12)
                                        Text("20")
                                            .font(Font.customFont(Font.caption1))
                                            .foregroundColor(.white)
                                    }
                                    .background(Color.clear)
                                    .frame(width: geometry.size.width * 0.15, height: 30)
                                    .cornerRadius(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.white, lineWidth: 1) // 테두리 색상과 두께 설정
                                    )
                                }
                                .padding(.bottom , 15)
                                Spacer()
                            }.frame(width: geometry.size.width * 0.25)
                            
                            
                            Text("돌돌이 방")
                                .padding(.bottom , 15)
                                .font(Font.customFont(Font.h6))
                                .shadow(radius: 4,x:0,y: 1)
                                .frame(width: geometry.size.width * 0.4, alignment: .center)
                            
                            // 공유, 꾸미기
                            HStack(spacing: 10){
                                Button(action: {
                                    store.send(.openDecoration)
                                }) {
                                    VStack {
                                        Image("Share")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24)
                                    }
                                    .padding(.bottom , 15)
                                    .background(Color.clear)
                                    
                                }
                                
                                Button(action: {
                                    store.send(.openDecoration)
                                }) {
                                    VStack {
                                        Image("Brush")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24) // 이미지 크기 조정
                                        Text("꾸미기")
                                            .font(Font.customFont(Font.caption1))
                                            .foregroundStyle(Color.white)
                                    }
                                    .padding(10)
                                    .background(Color.clear) // 배경색을 투명으로 설정
                                    .clipShape(Circle()) // 원형으로 자르기
                                    .overlay(
                                        Circle() // 원형 테두리
                                            .stroke(Color.white, lineWidth: 1) // 테두리 색상과 두께 설정
                                    )
                                    .shadow(color: .gray, radius: 1, x: 1, y: 1) // 그림자 추가
                                }
                                .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                            }
                            .frame(width: geometry.size.width * 0.25, height: geometry.size.width * 0.25)
                         
                            
                        
                        }
                        .frame(height : geometry.size.height * 0.1)
                        .padding(.top , geometry.size.height * 0.07)
                        
                        
                        Spacer().background(Color.red)
                        DolView(
                            selectedFace: $store.selectedFace,
                            selectedFaceShape: $store.selectedFaceShape,
                            selectedAccessory: $store.selectedAccessory
                        )
                        
                        Spacer().background(Color.red)
                        VStack{
                            
                            if store.ability{
                                HStack{
                                    Button(action: {
                                        
                                    }){
                                        VStack{
                                            Text("능력")
                                                .font(Font.customFont(Font.caption1))
                                                .foregroundColor(store.ability ? .black: .white)
                                                .padding()// Text
                                        }
                                        .frame(height: geometry.size.width * 0.1)
                                        .background(Color.ability1).cornerRadius(20)
                                    }
                                }
                                .frame(height: geometry.size.width * 0.15)
                                .transition(.opacity) // 애니메이션 전환 효과
                                .animation(.easeInOut, value: store.ability)
                            }else{
                                Spacer().frame(height: geometry.size.width * 0.15)
                            }
                            
                            
                            HStack(spacing : 5){
                                
                                Button(action: {
                                    store.send(.clickAbility)
                                }) {
                                    VStack(spacing : 0) {
                                        Image(store.ability ? "Star2" : "Star")
                                                    .resizable()
                                                    .scaledToFit()
                                        
                                        Text("능력")
                                            .font(Font.customFont(Font.caption1))
                                            .foregroundColor(store.ability ? Color.ability1: Color.ability2)
                                            .padding(.bottom,2)
                                    }
                                    .frame(width: geometry.size.width * 0.12, height: geometry.size.width * 0.12)
                                    .background(store.ability ? Color.ability2 : Color.ability1)
                                    .clipShape(Circle())
                                   
                                    
                                }
                                
                                CustomTextField(
                                    text: $store.message,
                                    placeholder: "돌에게 말을 걸어보세요",
                                    placeholderColor: UIColor(Color.placeHolder),
                                    maxLength: 40,
                                    useDidEndEditing: false,
                                    customFontStyle: Font.body3Bold,
                                    alignment: Align.leading,
                                    leftPadding : 5
                                )
                                .frame(width: geometry.size.width * 0.65, height: geometry.size.width * 0.1)
                                .cornerRadius(25)
                                
                                Button(action: {
                                    store.send(.clickMessage)
                                    hideKeyboard()
                                    
                                }){
                                    Image("Send")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1)
                                }
                                
                            }
                            .padding(.bottom , geometry.size.height * 0.02)
                        }
                        .offset(y: store.isKeyboardVisible ? -geometry.size.height * 0.15 : 0)
                        .animation(.easeInOut, value: store.isKeyboardVisible)
                        
                      
//                        // 하단 버튼들
//                        HStack{
//                            BottomButtonView(imageName: "Calander", buttonText: "달력", destination: AnyView(LoginView()))
//                            BottomButtonView(imageName: "Harubang", buttonText: "하루방", destination: AnyView(LoginView()))
//                            BottomButtonView(imageName: "Home", destination: AnyView(LoginView()))
//                            BottomButtonView(imageName: "Park", buttonText: "공원", destination: AnyView(LoginView()))
//                            BottomButtonView(imageName: "Mypage", buttonText: "마이페이지", destination: AnyView(LoginView()))
//                            
//                        }
//                        .padding(.bottom , geometry.size.height * 0.035)
                        
                    }
//                    .safeAreaInset(edge: .bottom) {
//                                FloatingMenuView(store: Store(initialState: FloatButtonFeature.State()){FloatButtonFeature()})
//                              }
                    
                } // ZStack
                
                .edgesIgnoringSafeArea(.all)
                .navigationBarBackButtonHidden(true) // 기본 뒤로가기 버튼 숨기기
                .frame(height: geometry.size.height)
                .keyboardResponder(isKeyboardVisible: $store.isKeyboardVisible)
                .onAppear (perform : UIApplication.shared.hideKeyboard)
                .sheet(isPresented: $store.decoration) {
                    // 이 뷰가 모달로 표시됩니다.
                    DecorationView(store: store)
                        .presentationDetents([.fraction(0.45)])
                        .presentationCompactAdaptation(.none)
                        .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                    }// sheet
            } // geometry
    } // some
    
    
} // View

struct FloatingMenuView : View {

    var store : StoreOf<FloatButtonFeature>
    var nav: StoreOf<NavigationFeature>
    
    struct ViewState: Equatable {
      struct Screen: Equatable, Identifiable {
        let id: StackElementID
        let name: String
      }

      var currentStack: [Screen]
      var total: Int
      init(state: NavigationFeature.State) {
        self.total = 0
        self.currentStack = []
        for (id, element) in zip(state.path.ids, state.path) {
          switch element {
          case let .harubang(HaruBangFeature):
              print("하루방")
              self.currentStack.insert(Screen(id: id, name: "Screen A"), at: 0)
          case let .park(ParkFeature):
              print("공원")
              self.currentStack.insert(Screen(id: id, name: "Screen B"), at: 0)
          case let .mypage(MyPageFeature):
              print("마이페이지")
              self.currentStack.insert(Screen(id: id, name: "Screen C"), at: 0)
          case let .home(HomeFeature):
              print("홈")
              self.currentStack.insert(Screen(id: id, name: "Screen D"), at: 0)
          case .DBTIQuestion1View:
              print("질문")
              self.currentStack.insert(Screen(id: id, name: "Screen E"), at: 0)
          case let .DBTIResultView(FloatButtonFeature):
              print("결과")
              self.currentStack.insert(Screen(id: id, name: "Screen F"), at: 0)
          }
        }
          self.total = self.currentStack.count
          print("total : ", total)
      }
    }

    var body : some View {
        let viewState = ViewState(state: nav.state)
        if viewState.currentStack.count > 0{
            HStack{
                BottomButtonView(imageName: "Calander", buttonText: "달력", destinationState: .harubang(HaruBangFeature.State()))
                BottomButtonView(imageName: "Harubang", buttonText: "하루방", destinationState: .harubang(HaruBangFeature.State()))
                BottomButtonView(imageName: "Home", destinationState: .home(HomeFeature.State()))
                BottomButtonView(imageName: "Park", buttonText: "공원", destinationState: .park(ParkFeature.State()))
                BottomButtonView(imageName: "Mypage", buttonText: "마이페이지", destinationState: .mypage(MyPageFeature.State()))
            }
        }
    }
}


struct BottomButtonView: View {
    var imageName: String
    var buttonText: String?
    var destinationState : NavigationFeature.Path.State
//    var nav : StoreOf<NavigationFeature>
    
    var body: some View {
        Button(action : {print("버튼")}) {
            ZStack {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Image(imageName)
                        Spacer()
                    }
                    if let buttonText = buttonText {
                        HStack(alignment: .center) {
                            Text(buttonText)
                                .font(Font.customFont(Font.caption1))
                                .foregroundColor(.white)
                                .padding(.bottom, 2)
                        }
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




struct CommonTextFieldStyle: TextFieldStyle {
    var placeholderColor: Color
    var textColor: Color
    var backgroundColor: Color
    var borderColor: Color
    var cornerRadius: CGFloat
    var shadowColor: Color
    var shadowRadius: CGFloat

    func _body(configuration: TextField<Self._Label>) -> some View {
        ZStack(alignment: .leading) {
            // Background Rectangle
            Rectangle()
                .foregroundColor(backgroundColor)
                .cornerRadius(cornerRadius)
                .frame(height: 46)
                .shadow(color: shadowColor.opacity(0.5), radius: shadowRadius, x: 0, y: 2)
                .overlay(
                    RoundedRectangle(cornerRadius: cornerRadius)
                        .stroke(borderColor, lineWidth: 1)
                )
            
          
            // TextField
            configuration
                .font(.body)
                .foregroundColor(textColor)
                .padding(.leading, 8) // Add padding to align text within the text field
        }
        .padding(.horizontal, 8) // Add horizontal padding for the whole ZStack
    }
}
