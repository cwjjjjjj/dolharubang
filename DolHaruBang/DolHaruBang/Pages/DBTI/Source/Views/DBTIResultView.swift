import SwiftUI
import ComposableArchitecture

struct DBTIResultView: View {
    
    let store : StoreOf<DBTIFeature>
    
    @EnvironmentObject var userManager: UserManager // 유저 닉네임 불러오기 위함
    
    @State private var isEditingName = false

    @State private var isEditingRoomName = false
    @State private var stoneName = "소심이"
    @State private var originalStoneName = "소심이"
    @State private var roomName: String = ""
    @State private var originalRoomName: String = "user의 방"
    @State private var tag: Int? = nil
    @State private var emptyNameAlert = false
    
    @ObservedObject private var keyboardGuardian = KeyboardGuardian()
    
    var body: some View {
        ZStack {
            // 배경
            Color.mainWhite
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    if isEditingRoomName {
                        // 원래 값으로 돌리고 편집 상태 해제
                        roomName = originalRoomName
                        isEditingRoomName = false
                    }
                    // 키보드 내리기
                    self.hideKeyboard()
                }
            
            GeometryReader { geometry in
                VStack(alignment: .center, spacing: 0) {
                    HStack {
                        Spacer()
                        
                        CustomText(text: "반려돌 줍기 완료!",
                                   font: Font.uiFont(for: Font.subtitle2)!,
                                   textColor: .coreGreen,
                                   letterSpacingPercentage: -2.5,
                                   lineSpacingPercentage: 160,
                                   textAlign: .center
                        )
                        
                        Spacer()
                    }
                    .position(x: UIScreen.main.bounds.width / 2, y: 77)

                    Spacer().frame(height: geometry.size.height * 0.21)
                    
                    if keyboardGuardian.keyboardHeight == 0 {
                        HStack {
                            Spacer()
                            Image("Logo")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 270, height: 270)
                            Spacer()
                        }
                    }
                    
//                    if keyboardGuardian.keyboardHeight == 0 {
                    VStack {
                        HStack(alignment: .center, spacing: 5) {
                            HStack {
                                CustomText(text: stoneName,
                                           font: Font.uiFont(for: Font.subtitle1)!,
                                           textColor: .coreBlack,
                                           letterSpacingPercentage: -2.5,
                                           lineSpacingPercentage: 160,
                                           textAlign: .center
                                )
                                .font(.system(size: 24))
                                .fixedSize()
                                .lineLimit(1)
                            }
                            
                            HStack {
                                Button(action: {
                                    isEditingName = true
                                    originalStoneName = stoneName
                                }) {
                                    Image("editIcon")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                                .disabled(isEditingName || keyboardGuardian.keyboardHeight != 0)
                            }
                            .offset(y: 8)
                            //                        Spacer()
                        }
                        
                        Spacer().frame(height: geometry.size.height * 0.02)
                        
                        VStack(alignment: .leading, spacing: 0) {
                            Spacer().frame(height: 8)
                            
                            LazyHStack(spacing: 2) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.mainGreen)
                                    .padding(.horizontal, 10)
                                    .offset(y: 6)
                                CustomText(text: "성격",
                                           font: Font.uiFont(for: Font.subtitle1)!,
                                           textColor: .coreBlack,
                                           letterSpacingPercentage: -2.5,
                                           lineSpacingPercentage: 160,
                                           textAlign: .left
                                )
                                Spacer()
                                CustomText(text: "소심함",
                                           font: Font.uiFont(for: Font.body1Bold)!,
                                           textColor: .coreDarkGreen,
                                           letterSpacingPercentage: -2.5,
                                           lineSpacingPercentage: 160,
                                           textAlign: .left
                                )
                                Spacer()
                            }
                            
                            Spacer().frame(height: 8)
                            
                            LazyHStack(spacing: 2) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.mainGreen)
                                    .padding(.horizontal, 10)
                                    .offset(y: 6)
                                CustomText(text: "초기능력",
                                           font: Font.uiFont(for: Font.body1Bold)!,
                                           textColor: .coreBlack,
                                           letterSpacingPercentage: -2.5,
                                           lineSpacingPercentage: 160,
                                           textAlign: .left
                                )
                                Spacer()
                                CustomText(text: "쩝쩝박사",
                                           font: Font.uiFont(for: Font.body1Bold)!,
                                           textColor: .coreDarkGreen,
                                           letterSpacingPercentage: -2.5,
                                           lineSpacingPercentage: 160,
                                           textAlign: .left
                                )
                                Spacer()
                            }
                            
                            Spacer().frame(height: 18)
                        }
                        .frame(width: 180, height: 80)
                        .background(Color.ffffff)
                        .cornerRadius(10)
                        .overlay(  // 내부 실선
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 0.05)
                        )
                    }
//                    }
                    
                    Spacer().frame(height: 24)
                    
                    CustomTextField(text: $roomName, placeholder: "방 이름", font: .customFont(Font.button1), textColor: UIColor.coreDarkGreen, maxLength: 15, 
                                    alertTitle: "글자 수 오류", alertMessage: "방이름은 1~15자 사이로 설정해주세요.", dismissButtonTitle: "확인",
                    onSubmit: {
                            isEditingRoomName = false
                        }
//                    , onEndEditing: {}
                    )
                        .frame(width: 320, height: 48)
                        .cornerRadius(30)
                        .onTapGesture {
                            isEditingRoomName = true
                            if (roomName != "")
                            {
                                originalRoomName = roomName
                            }
                        }
                    
                    Spacer().frame(height: 16)
                    
                    Button(action: {
                        store.send(.homeButtonTapped)
                        tag = 1
                        print("tabbed3")
                    }) {
                        CustomButton(
                            title: "함께 시작하기!",
                            font: .customFont(Font.button1),
                            textColor: .coreWhite,
                            pressedBackgroundColor: .coreDarkGreen,
                            isDisabled: Binding(
                                get: {
                                    stoneName.isEmpty || roomName.isEmpty || isEditingName || isEditingRoomName
                                },
                                set: { _ in }
                            ),
                            action: { }
                        )
                        .frame(width: 320, height: 48)
                        .cornerRadius(24)
                    }

                                  
                    
                    
                    Spacer().frame(height: geometry.size.height * 0.29)
                }
                .padding(.bottom, keyboardGuardian.keyboardHeight)
                .animation(.easeOut(duration: 0.3), value: keyboardGuardian.keyboardHeight)
                .onAppear {
                    // 방 이름 기본값 설정
                    if let nickname = userManager.nickname {
                        roomName = "\(nickname)의 방"
                    }
                }
            }
            
            // 이름 변경 창
            if isEditingName {
                Color.black.opacity(0.7).edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        if isEditingName {
                            // 원래 값으로 돌리고 편집 상태 해제
                            stoneName = originalStoneName
                            isEditingName = false
                        }
                        // 키보드 내리기
                        self.hideKeyboard()
                    }
                VStack (alignment: .center) {
                    VStack {
                        Spacer()
                        CustomText(text: "닉네임 변경",
                                   font: Font.uiFont(for: Font.subtitle2)!,
                                   textColor: .coreDarkGreen,
                                   letterSpacingPercentage: -2.5,
                                   lineSpacingPercentage: 160,
                                   textAlign: .center
                        )

                        Spacer()
                        CustomTextField(text: $stoneName, placeholder: "닉네임을 입력하세요", font: .customFont(Font.subtitle2), maxLength: 6, alertTitle: "소중한 이름", alertMessage: "닉네임을 1~6자 사이로 설정해주세요.", dismissButtonTitle: "확인", onSubmit: {
                            if stoneName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                emptyNameAlert = true
                            } else {
                                isEditingName = false
                            }
                        }, onEndEditing: {print("onEndEditing")})
                            .onChange(of: stoneName) { newValue in
                                if newValue.count > 6 {
                                    stoneName = String(stoneName.prefix(6))  // 최대 글자 수 제한
                                }
                            }
                            .frame(width: 250, height: 48)
                            .cornerRadius(10)
                        
                        CustomText(text: "닉네임은 최대 6글자입니다.",
                                   font: Font.uiFont(for: Font.body3Bold)!,
                                   textColor: .coreDisabled,
                                   letterSpacingPercentage: -2.5,
                                   lineSpacingPercentage: 160,
                                   textAlign: .center
                        )
                        
                        CustomButton(title: "완료", font: .customFont(Font.button1), textColor: .coreWhite, action: {
                            if stoneName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                emptyNameAlert = true
                            } else {
                                isEditingName = false
                            }
                        })
                        .frame(width: 150, height: 48)
                        .background(Color.mainGreen)
                        .cornerRadius(24)
                        .foregroundColor(.mainWhite)
                        Spacer()
                    }
                    .frame(width: 350, height: 220)
                    .background(Color.white)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                    .transition(.move(edge: .bottom))
                    .offset(y: keyboardGuardian.keyboardHeight > 0 ? -keyboardGuardian.keyboardHeight / 2 : 0)
                    .animation(.easeOut(duration: 0.3), value: keyboardGuardian.keyboardHeight)
                    .alert(isPresented: $emptyNameAlert) {
                        Alert(
                            title: Text("소중한 이름!"),
                            message: Text("닉네임을 1~6자 사이로 설정해주세요."),
                            dismissButton: .default(Text("확인"))
                        )
                    }
                }
            }
            
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true) // 기본 뒤로가기 버튼 숨기기
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: {
                        store.send(.goBack)
                    }) {
                        Image("backIcon")
                            .resizable()
                            .frame(width: 32, height: 32)
                    }
                }
                .offset(x: 8, y: 8)
            }
        }
    }
}

