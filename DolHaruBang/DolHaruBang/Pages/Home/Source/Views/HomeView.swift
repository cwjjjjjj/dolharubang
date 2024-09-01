//
//  HomeView.swift
//  DolHaruBang
//
//  Created by 양희태 on 7/31/24.
//

import SwiftUI
import UIKit
import ComposableArchitecture

struct HomeView: View {
    @State var store: StoreOf<HomeFeature>
    @State private var activeView: AnyView? = nil // 하단 버튼에 따라 보여지는 뷰
    @State private var titleText: String = "돌돌이 방" // 상단 텍스트
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // 배경이미지 설정
                Image(Background(rawValue: store.selectedBackground.rawValue)!.fileName)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack {
                    // 상단 부분 (titleText는 항상 표시, 나머지는 activeView가 없을 때만 표시)
                    HStack {
                        if activeView == nil {
                            // activeView가 없을 때만 보여지는 요소들
                            HStack {
                                Button(action: {
                                    // 추가 작업
                                }) {
                                    HStack {
                                        Image("Sand")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 12, height: 12)
                                            .background(
                                                ShadowView(
                                                    color: UIColor(Color(hex: "837C74")),
                                                    alpha: 1.0,
                                                    x: -1,
                                                    y: -1,
                                                    blur: 3,
                                                    spread: 0,
                                                    isInnerShadow: true
                                                )
                                            )
                                            .background(
                                                ShadowView(
                                                    color: UIColor(Color(hex: "FBFAF7")),
                                                    alpha: 1.0,
                                                    x: 1,
                                                    y: 1,
                                                    blur: 4,
                                                    spread: 0,
                                                    isInnerShadow: true
                                                )
                                            )
                                        Text("20")
                                            .font(Font.customFont(Font.caption1))
                                            .foregroundColor(.white)

                                    }
                                    .background(Color.clear)
                                    .frame(width: geometry.size.width * 0.15, height: 30)
                                    .cornerRadius(30)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 30)
                                            .stroke(Color.white, lineWidth: 1)
                                    )
                                }
                                .padding(.bottom, 15)
                                Spacer()
                            }
                            .frame(width: geometry.size.width * 0.25)

                            Text(titleText) // 상단 타이틀
                                .padding(.bottom, 15)
                                .font(Font.customFont(Font.h6))
                                .shadow(radius: 4, x: 0, y: 1)
                                .frame(width: geometry.size.width * 0.4, alignment: .center)

                            // 공유, 꾸미기 버튼들
                            HStack(spacing: 10) {
                                Button(action: {
                                    store.send(.openDecoration)
                                }) {
                                    VStack {
                                        Image("Share")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24)
                                    }
                                    .padding(.bottom, 15)
                                    .background(Color.clear)
                                }

                                Button(action: {
                                    store.send(.openDecoration)
                                }) {
                                    VStack {
                                        Image("Brush")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 24, height: 24)
                                        Text("꾸미기")
                                            .font(Font.customFont(Font.caption1))
                                            .foregroundStyle(Color.white)
                                    }
                                    .padding(10)
                                    .background(Color.clear)
                                    .clipShape(Circle())
                                    .overlay(
                                        Circle()
                                            .stroke(Color.white, lineWidth: 1)
                                            .blendMode(.multiply)
                                    )
                                    .shadow(color: .gray, radius: 1, x: 1, y: 1)
                                }
                                .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                            }
                            .frame(width: geometry.size.width * 0.25, height: geometry.size.width * 0.25)

                        } else {
                            // activeView가 있을 때는 titleText만 표시
                            Spacer()
                            Text(titleText)
                                .font(Font.customFont(Font.h6))
                                .shadow(radius: 4, x: 0, y: 1)
                                .frame(width: geometry.size.width * 0.4, alignment: .center)
                            Spacer()
                        }
                    }
                    .frame(height: geometry.size.height * 0.1)
                    .padding(.top, geometry.size.height * 0.07)

                    // activeView가 있을 때는 activeView를 표시, 없을 때는 기본 홈 뷰를 표시
                    if let activeView = activeView {
                        activeView
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        // 기본 홈 뷰
                        VStack {
                            DolView(
                                selectedFace: $store.selectedFace,
                                selectedFaceShape: $store.selectedFaceShape,
                                selectedAccessory: $store.selectedAccessory
                            )

                            Spacer()

                            VStack {
                                if store.ability {
                                    HStack {
                                        Button(action: {}) {
                                            VStack {
                                                Text("능력")
                                                    .font(Font.customFont(Font.caption1))
                                                    .foregroundColor(store.ability ? .black : .white)
                                                    .padding()
                                            }
                                            .frame(height: geometry.size.width * 0.1)
                                            .background(Color.ability1)
                                            .cornerRadius(20)
                                        }
                                    }
                                    .frame(height: geometry.size.width * 0.15)
                                    .transition(.opacity)
                                    .animation(.easeInOut, value: store.ability)
                                } else {
                                    Spacer().frame(height: geometry.size.width * 0.15)
                                }

                                HStack(spacing: 5) {
                                    Button(action: {
                                        store.send(.clickAbility)
                                    }) {
                                        VStack(spacing: 0) {
                                            Image(store.ability ? "Star2" : "Star")
                                                .resizable()
                                                .scaledToFit()

                                            Text("능력")
                                                .font(Font.customFont(Font.caption1))
                                                .foregroundColor(store.ability ? Color.ability1 : Color.ability2)
                                                .padding(.bottom, 2)
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
                                        leftPadding: 5
                                    )
                                    .frame(width: geometry.size.width * 0.65, height: geometry.size.width * 0.1)
                                    .cornerRadius(25)

                                    Button(action: {
                                        store.send(.clickMessage)
                                        hideKeyboard()
                                    }) {
                                        Image("Send")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: geometry.size.width * 0.1, height: geometry.size.width * 0.1)
                                    }
                                }
                                .padding(.bottom, geometry.size.height * 0.02)
                            }
                            .offset(y: store.isKeyboardVisible ? -geometry.size.height * 0.15 : 0)
                            .animation(.easeInOut, value: store.isKeyboardVisible)
                        }
                    }

                    Spacer().frame(height: geometry.size.height * 0.035)

                    // 하단 버튼들 (항상 표시됨)
                    HStack {
                        BottomButtonView(imageName: "Calander", buttonText: "달력", action: {
                            titleText = "달력"
                            activeView = AnyView(CalendarView())
                        })

                        BottomButtonView(imageName: "Harubang", buttonText: "하루방", action: {
                            titleText = "하루방"
                            activeView = AnyView(LoginView())
                        })

                        BottomButtonView(imageName: "Home", action: {
                            titleText = "돌돌이 방"
                            activeView = nil // 홈 버튼을 눌렀을 때 기본 뷰로 복귀
                        })

                        BottomButtonView(imageName: "Park", buttonText: "공원", action: {
                            titleText = "공원"
                            activeView = AnyView(LoginView())
                        })

                        BottomButtonView(imageName: "Mypage", buttonText: "마이페이지", action: {
                            titleText = "마이페이지"
                            activeView = AnyView(LoginView())
                        })
                    }
                    .padding(.bottom, geometry.size.height * 0.035)
                }
            }
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
            .frame(height: geometry.size.height)
            .keyboardResponder(isKeyboardVisible: $store.isKeyboardVisible)
            .onAppear(perform: UIApplication.shared.hideKeyboard)
            .sheet(isPresented: $store.decoration) {
                // 이 뷰가 모달로 표시됩니다.
                DecorationView(store: store)
                    .presentationDetents([.fraction(0.45)])
                    .presentationCompactAdaptation(.none)
                    .edgesIgnoringSafeArea(.all)
            }
        }
    }
}



struct BottomButtonView: View {
    var imageName: String
    var buttonText: String?
    var action: () -> Void // 버튼이 눌렸을 때 수행할 동작을 클로저로 전달

    var body: some View {
        HStack {
            Button(action: action) {
                ZStack {
                    VStack(spacing: 0) {
                        HStack {
                            Spacer()
                            Image(imageName)
                                .resizable()
                                .frame(width: 48, height: 48)
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
