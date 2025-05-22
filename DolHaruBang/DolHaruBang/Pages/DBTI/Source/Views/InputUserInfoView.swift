import SwiftUI
import ComposableArchitecture

struct InputUserInfoView: View {
    let store: StoreOf<DBTIFeature>
    @FocusState private var isUsernameFieldFocused: Bool
    
    var isFormComplete: Bool {
        store.isNameConfirmed
    }
    
    var body: some View {
        ZStack {
            Color.mainWhite
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                VStack (alignment: .center, spacing: 0){
                    Spacer().frame(height: geometry.size.height * 0.285)
                    
                    HStack {
                        Spacer()
                        CustomText(text: "돌하루방에서 사용할\n닉네임을 정해주세요.", font: Font.uiFont(for: Font.subtitle2)!, textColor: .coreBlack)
                            .frame(width: 187, height: 87)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }.padding(.bottom, 48)
                    
//                    HStack {
//                        Spacer()
//                        CustomText(text: "(선택) 태어난 달(월)을 고르면\n내 탄생석을 알 수 있어요!", font: Font.uiFont(for: Font.body3Regular)!, textColor: .coreDisabled)
//                            .frame(width: 187, height: 48)
//                            .fixedSize(horizontal: false, vertical: true)
//                        Spacer()
//                    }.padding(.bottom, 16)
                    
                    AnimatedArrowView()
                    
                    Spacer().frame(height: 32)
                    
                    HStack {
                        CustomTextField(
                            text: Binding(
                                get: { store.username },
                                set: { store.send(.setUsername($0)) }
                            ),
                            placeholder: "닉네임",
                            font: .customFont(Font.button1),
                            maxLength: 12,
                            alertTitle: "글자 수 오류",
                            alertMessage: "닉네임은 1~6자로 입력해주세요.",
                            onSubmit: { store.send(.checkUsername(store.username)) }
                        )
                        .frame(width: 210, height: 48)
                        .alert(isPresented: Binding(
                            get: { store.showAlert },
                            set: { store.send(.setShowAlert($0)) }
                        )) {
                            if store.showConfirmation {
                                return Alert(
                                    title: Text(store.inputAlertTitle),
                                    message: Text(store.inputAlertMessage),
                                    primaryButton: .default(Text("네"), action: {
                                        isUsernameFieldFocused = false
                                        store.send(.setIsNameConfirmed(true))
                                    }),
                                    secondaryButton: .cancel(Text("아니요")) {
                                        store.send(.setUsername(""))
                                    }
                                )
                            } else {
                                return Alert(
                                    title: Text(store.inputAlertTitle),
                                    message: Text(store.inputAlertMessage),
                                    dismissButton: .default(Text("OK"))
                                )
                            }
                        }
                        .cornerRadius(24)
                        
                        Spacer().frame(width: 10)
                        
                        CustomButton(
                            title: "중복확인",
                            font: .customFont(Font.button1),
                            textColor: .coreWhite,
                            action: { store.send(.checkUsername(store.username)) }
                        )
                        .frame(width:110,height:52) // 4씩늘려둠
                        .background(store.username.isEmpty ? Color.disabled : Color.mainGreen)
                        .cornerRadius(24)
                        .disabled(store.username.isEmpty)
                        .onTapGesture { store.send(.checkUsername(store.username)) }
                    }
                    
//                    HStack (spacing: 24) {
//                        Text("태어난 달")
//                            .font(Font.customFont(Font.subtitle3))
//                            .foregroundStyle(.coreBlack)
//                        
//                        CustomMonthButton(
//                            selectedMonth: Binding(
//                                get: { store.selectedMonth},
//                                set: { store.send(.setSelectedMonth($0)) }
//                            ),
//                            isPresented: Binding(
//                                get: { store.showMonthPicker },
//                                set: { store.send(.setShowMonthPicker($0)) }
//                            ),
//                            font: .customFont(Font.button1)
//                        )
//                        .onAppear {
//                            store.send(.setSelectedMonth("선택 안함"))
//                        }
//                        .background(Color.mainGray)
//                        .frame(width: 100, height: 48)
//                        .cornerRadius(24)
//                        .onTapGesture { store.send(.setShowMonthPicker(true)) }
//                        .sheet(isPresented: Binding(
//                            get: { store.showMonthPicker },
//                            set: { store.send(.setShowMonthPicker($0)) }
//                        )) {
//                            let months: [String] = ["선택 안함"] + (1...12).map { String($0) }
//                            MonthPicker(
//                                selectedMonth: Binding(
//                                    get: { store.selectedMonth},
//                                    set: { store.send(.setSelectedMonth($0)) }
//                                ),
//                                isPresented: Binding(
//                                    get: { store.showMonthPicker },
//                                    set: { store.send(.setShowMonthPicker($0)) }
//                                ),
//                                months: months
//                            )
//                            {
//                                
//                            }
//                        }
//                    }
//                    .padding(.horizontal, 16)
                    
                    Spacer().frame(height: 40)
                    
                    HStack {
                        NavigationLink(state: NavigationFeature.Path.State.DBTIGuideView(store.state)) {
                            ZStack {
                                HStack {
                                    Spacer()
                                    Text("완료")
                                        .font(.customFont(Font.button1))
                                        .foregroundColor(.mainWhite)
                                    Spacer()
                                }
                            }
                        }
                        .frame(width: 320, height: 48)
                        .background(isFormComplete ? Color.mainGreen : Color.disabled)
                        .cornerRadius(24)
                        .disabled(!isFormComplete)
                        .simultaneousGesture(TapGesture().onEnded {
                            if isFormComplete {
                                let nickname = store.username
                                let birthStone: String? = (store.selectedMonth == "선택 안함") ? nil : birthStones[store.selectedMonth]
                                store.send(.submitMemberInfo(nickname, birthStone))
                            }
                        })
                    }
                    Spacer()
                }
            }
            .alert(isPresented: Binding(
                get: { store.showAlert },
                set: { store.send(.setShowAlert($0)) }
            )) {
                // 중복 check 결과에 따라서 다르게!
                if store.showConfirmation {
                    return Alert(
                        title: Text(store.inputAlertTitle),
                        message: Text(store.inputAlertMessage),
                        primaryButton: .default(Text("네"), action: {
                            store.send(.setIsNameConfirmed(true))
                            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        }),
                        secondaryButton: .cancel(Text("아니요")) {
                            store.send(.setUsername(""))
                        }
                    )
                } else {
                    return Alert(
                        title: Text(store.inputAlertTitle),
                        message: Text(store.inputAlertMessage),
                        dismissButton: .default(Text("OK"))
                    )
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true)
    }
}

struct AnimatedArrowView: View {
    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 1.0
    let animationDistance: CGFloat = 40      // 아래로 이동 거리
    let animationDuration: Double = 1.2      // 한 번 내려가는 데 걸리는 시간
    
    var body: some View {
        Image(systemName: "chevron.down")
            .foregroundColor(.gray)
            .font(.system(size: 24))
            .offset(y: offsetY)
            .opacity(opacity)
            .onAppear {
                animateArrow()
            }
            .padding(.bottom, 72)
    }
    
    func animateArrow() {
        // 1. 아래로 이동하며 투명해짐
        withAnimation(.linear(duration: animationDuration)) {
            offsetY = animationDistance
            opacity = 0.0
        }
        // 2. 애니메이션 끝나면 다시 위로 순간 이동, 다시 반복
        DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration) {
            offsetY = 0
            opacity = 1.0
            animateArrow()
        }
    }
}


