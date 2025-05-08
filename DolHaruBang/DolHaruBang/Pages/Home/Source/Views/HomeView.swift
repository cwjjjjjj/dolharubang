
//
//  HomeView.swift
//  DolHaruBang
//
//  Created by 양희태 on 7/31/24.
//

import SwiftUI
import UIKit
import ComposableArchitecture
import HapticsManager


struct HomeView : View {
    @State var store: StoreOf<HomeFeature>
    
    var body : some View {
        GeometryReader { geometry in
            ZStack {
                Image(Background(rawValue: store.decoStore.selectedBackground.rawValue)!.fileName)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                // 메인 컴포넌트들
                VStack {
                    // MARK: 홈 상단
                    HomeHeader(store: store, geometry: geometry)
                    // MARK: 3D 돌 뷰
                    let dolView = DolView(
                        selectedFace: $store.decoStore.selectedFace,
                        selectedFaceShape: $store.decoStore.selectedFaceShape,
                        selectedAccessory: $store.decoStore.selectedAccessory,
                        selectedSign: $store.decoStore.selectedSign,
                        selectedMail: $store.decoStore.selectedMail,
                        selectedNest: $store.decoStore.selectedNest,
                        signText: $store.signStore.signInfo,
                        sign: $store.sign,
                        profile: $store.profile,
                        mail: $store.mail,
                        enable: $store.enable,
                        onImagePicked: { image in
                            store.send(.captureDol(image))
                        }
                    )
                    
                    // MARK: 중단부분
                    ZStack{
                        dolView
                        DolContentView(store: store,geometry: geometry)
                    }
                    
                    
                    // MARK: 하단 컴포넌트
                    HomeBottom(store: store, geometry: geometry, rollDol:  { dolView.rollDol() }, frontRollDol: { dolView.frontRollDol() })
                    
                    Spacer().frame(height: geometry.size.height * 0.033)
                    
                }
                
                // MARK: 모래알 튜토리얼
                SandView(store: store)
                    .frame(width: 200, height: 199)
                    .background(Color(red: 0.98, green: 0.98, blue: 0.97))
                    .cornerRadius(20)
                    .shadow(
                        color: Color(red: 0.71, green: 0.72, blue: 0.75, opacity: 1), radius: 5, y: 1
                    )
                    .position(x: 110, y: 210)
                    .opacity(store.sandButton ? 1 : 0)
                
                // MARK: 공유버튼
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            store.send(.closeShare)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(1)
                    ShareView(
                        showPopup: $store.shareButton, DolImage: $store.captureDol
                    )
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(radius: 10)
                    .zIndex(2)
                }.opacity(store.shareButton ? 1 : 0)
                
                // MARK: 펫말
                ZStack {
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            store.send(.closeSign)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(1)
                    SignView(
                        showPopup: $store.sign,
                        initMessage: $store.signStore.signInfo, store: store.scope(
                            state: \.signStore,
                            action: HomeFeature.Action.signStore
                        )
                    )
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(radius: 10)
                    .zIndex(2)
                }.opacity(store.sign ? 1 : 0)
                
                // MARK: 프로필
                ZStack{
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            store.send(.closeProfile)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(1)
                    ProfileView(
                        showPopup: $store.profile, store: store.scope(
                            state: \.profileStore,
                            action: HomeFeature.Action.profileStore
                        )
                    )
                    .frame(width: geometry.size.width * 0.8142, height : geometry.size.height * 0.55)
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(radius: 10)
                    .zIndex(2)
                }.opacity(store.profile ? 1 : 0)
                
                // MARK: 우체통
                ZStack{
                    Color.black.opacity(0.2)
                        .ignoresSafeArea()
                        .onTapGesture {
                            store.send(.closeMail)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(1)
                    MailView(
                        showPopup: $store.mail, geometry : geometry, store : store.scope(
                            state: \.mailStore,
                            action: HomeFeature.Action.mailStore
                        )
                    )
                    .frame(width: geometry.size.width * 0.8142, height : geometry.size.height * 0.55)
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(radius: 10)
                    .zIndex(2)
                }.opacity(store.mail ? 1 : 0)
            } // ZStack
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true) // 기본 뒤로가기 버튼 숨기기
            .frame(height: geometry.size.height)
            .keyboardResponder(isKeyboardVisible: $store.isKeyboardVisible)
            .onAppear (
                perform : UIApplication.shared.hideKeyboard
            )
            .onAppear{
                store.send(.fetchDeco)
                store.send(.fetchSand)
            }
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
            .sheet(isPresented: $store.decoration) {
                // 이 뷰가 모달로 표시됩니다.
                DecorationView(store : store.scope(
                    state: \.decoStore,
                    action: HomeFeature.Action.decoStore
                ))
                .presentationDetents([.fraction(0.45)])
                .presentationCompactAdaptation(.none)
                .edgesIgnoringSafeArea(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
            }// sheet
        } // geometry
    } // some
    
    
} // View

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
            
            
            // TextField.
            configuration
                .font(.body)
                .foregroundColor(textColor)
                .padding(.leading, 8) // Add padding to align text within the text field
        }
        .padding(.horizontal, 8) // Add horizontal padding for the whole ZStack
    }
}

struct HomeHeader : View {
    let store : StoreOf<HomeFeature>
    let geometry : GeometryProxy
    var body : some View {
        // 상단 부분
        HStack{
            HStack{
                Button(action: {
                    store.send(.openSand)
                }) {
                    HStack {
                        Image("Sand")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 12, height: 12)
                        Text("\(store.sand)")
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
            
            if let profile = store.profileStore.profile
            {
                Text("\(profile.roomName) 방")
                    .padding(.bottom , 15)
                    .font(Font.customFont(Font.h6))
                    .shadow(radius: 4,x:0,y: 1)
                    .frame(width: geometry.size.width * 0.4, alignment: .center)
            }
            
            // 공유, 꾸미기
            HStack(spacing: 10){
                Button(action: {
                    store.send(.openShare)
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
                    if store.enable {
                        store.send(.openDecoration)
                    }
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
    }
}

struct DolContentView : View {
    let store : StoreOf<HomeFeature>
    let geometry : GeometryProxy
    var body : some View {
        // MARK: 새로온 편지
        ZStack(alignment: .center){
            Image("Vector").resizable().scaledToFit()
            
            Text("\(store.mailStore.unreadCount)")
                .font(Font.customFont(Font.signCount))
                .foregroundColor(Color(hex: "837C74"))
                .padding(.bottom,2)
            
        }
        .frame(width: 32,height: 32)
        .offset(x: geometry.size.width * 0.35 ,y: geometry.size.height * -0.12)
        
        if let basicInfo = store.profileStore.profile {
            Text("\(basicInfo.dolName)")
                .font(Font.customFont(Font.dolname)).shadow(color: Color(red: 0.60, green: 0.60, blue: 0.60, opacity: 1.00), radius: 4, x: 0, y: 1)
            
                .offset(x: 0 ,y: geometry.size.height * 0.2)
            
            // 친밀도 게이지
            ZStack(alignment: .leading){
                //                ProgressView(value: Double(basicInfo.friendShip % 100), total: 100)
                //                    .progressViewStyle(LinearProgressViewStyle())
                //                    .frame(width: 100)
                //                    .accentColor(Color.init(hex: "A5CD3B"))
                Image("progressWhite")
                    .resizable()
                    .frame(width: 136, height: 24)
                VStack(alignment: .leading){
                    Image("progressGreen")
                        .resizable()
                        .frame(width: Double(basicInfo.friendShip % 100) * 1.3 + 126 ,height: 14)
                    Spacer().frame(height:4)
                }
                
                Text("\(basicInfo.friendShip / 100)")
                    .font(Font.customFont(Font.dollevel))
                    .foregroundColor(Color(hex: "618501"))
                    .frame(width: 26, height: 26) // 흰색 블록 크기
                    .background(Color(red: 0.98, green: 0.98, blue: 0.97)) // 흰색 블록
                    .clipShape(Circle()) // 블록을 원으로 자르기
                    .shadow(
                        color: Color(red: 0.60, green: 0.60, blue: 0.60, opacity: 1),
                        radius: 4,
                        y: 2
                    )
                    .offset(x:-4)
            }
            .offset(x: 0 ,y: geometry.size.height * 0.23)
            
        }
        
    }
}

struct HomeBottom : View {
    @State var store : StoreOf<HomeFeature>
    let geometry : GeometryProxy
    let rollDol : () -> Void
    let frontRollDol : () -> Void
    
    @State private var activeRoll: RollType? = nil
    
    var body : some View {
        VStack{
            HStack{
                Spacer()
                if store.ability
                {
                    Button(action: {
                        rollDol()
                        store.send(.clickRollDol)
                    })
                    {
                        
                        HStack(alignment: .center){
                            // 구르기추가
                            Text("구르기")
                                .font(Font.customFont(Font.caption1))
                                .foregroundColor(store.ability ? Color(hex: "7F5D1A"): .white)
                        }
                        .padding()
                        .frame(height: geometry.size.height * 0.05)
                    }
                    
                    .buttonStyle(RollButtonStyle())
                    .hapticFeedback(.impact(.medium), trigger: store.isSuccess)
                    .transition(.opacity) // 애니메이션 전환 효과
                    .animation(.easeInOut, value: store.ability)
                    
                    Button(action: {
                        frontRollDol()
                        store.send(.clickRollDol)
                    })
                    {
                        HStack(alignment: .center){
                            // 구르기추가
                            Text("앞구르기")
                                .font(Font.customFont(Font.caption1))
                                .foregroundColor(store.ability ? Color(hex: "7F5D1A"): .white)
                        }
                        .padding()
                        .frame(height: geometry.size.height * 0.05)
                    }
                    .buttonStyle(RollButtonStyle())
                    .hapticFeedback(.impact(.medium), trigger: store.isSuccess)
                    .transition(.opacity) // 애니메이션 전환 효과
                    .animation(.easeInOut, value: store.ability)
                }
                else{
                    Text("")
                        .frame(height: geometry.size.height * 0.05)
                }
                Spacer()
            }
            HStack(spacing : 5){
                Button(action: {
                    store.send(.clickAbility)
                }) {
                    //                    ZStack {
                    //                        Image(store.ability ? "Star2" : "Star")
                    //                            .resizable()
                    //                            .scaledToFit()
                    //                            .frame(width: 30, height: 30)
                    //                            .padding(.bottom,10)
                    //                        Text("능력")
                    //                            .font(Font.customFont(Font.caption1))
                    //                            .foregroundColor(store.ability ? Color.ability1: Color.ability2)
                    //                            .padding(.top,20)
                    //                    }
                    // 사진박기 추가
                    Image(store.ability ? "Star11" : "Star22")
                        .resizable()
                        .scaledToFit()
                        .frame(width: geometry.size.width * 0.15, height: geometry.size.width * 0.15)
                    // 사진박기 종료, 주석 제거하면 기존 코드
                    //                    .frame(width: geometry.size.width * 0.12, height: geometry.size.width * 0.12)
                    //                    .overlay(
                    //                        Ellipse()
                    //                            .inset(by: 0.25)
                    //                            .stroke(.white, lineWidth: 0.25)
                    //                    )
                    //                    .background(store.ability ? Color.ability2 : Color.ability1)
                    //                    .clipShape(Circle())
                    //                    .shadow(color: Color(hex:"CECECE") , radius: 5, x:0, y:1)
                }
                //                .padding(.trailing,10)
                
                CustomTextField(
                    text: $store.message,
                    placeholder: "돌에게 말을 걸어보세요",
                    placeholderColor: Color(hex:"C8BEB2").toUIColor(),
                    backgroundColor: .coreWhite,
                    maxLength: 40,
                    useDidEndEditing: false,
                    customFontStyle: Font.body35Bold,
                    alignment: Align.leading,
                    leftPadding : 15,
                    rightPadding : 15
                )
                .frame(width: geometry.size.width * 0.64, height: geometry.size.width * 0.1)
                .cornerRadius(25)
                .shadow(color: Color(hex:"B4B8BF"), radius: 5, x:0, y:1)
                
                
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
            .padding(.vertical, geometry.size.width * 0.005)
            .padding(.bottom , geometry.size.height * 0.02)
        }
        // 키보드 focus시 오프셋 변경
        .offset(y: store.isKeyboardVisible ? -geometry.size.height * 0.22 : 0)
        .animation(.easeInOut, value: store.isKeyboardVisible)
        Spacer().frame(height: geometry.size.height * 0.12)
    }
}


enum RollType: Hashable {
    case normal
    case front
    case side
}

struct RollButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        ZStack {
            // 이미지가 텍스트 크기에 맞게 크기 결정
            Image(configuration.isPressed ? "ability22" : "ability11")
                .resizable()
                .layoutPriority(-1) // 이미지 우선순위 낮춤
            
            configuration.label
                .padding(.vertical,2)
                .layoutPriority(1) // 텍스트 우선순위 높임
        }
        .fixedSize() // 내용물 크기에 맞게 ZStack 크기 고정
        .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
