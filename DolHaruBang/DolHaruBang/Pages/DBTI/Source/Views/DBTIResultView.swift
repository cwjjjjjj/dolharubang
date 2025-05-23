import SwiftUI
import ComposableArchitecture

struct DBTIResultView: View {
    let store: StoreOf<DBTIFeature>
    @ObservedObject private var keyboardGuardian = KeyboardGuardian()
    
    var body: some View {
        ZStack {
            Color.mainWhite
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    if store.isEditingRoomName {
                        store.send(.setSpaceName(store.originalRoomName))
                        store.send(.setIsEditingRoomName(false))
                    }
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
                                   textAlign: .center)
                        Spacer()
                    }
                    .position(x: UIScreen.main.bounds.width / 2, y: 77)
                    Spacer().frame(height: geometry.size.height * 0.21)
                    
                    if keyboardGuardian.keyboardHeight == 0 {
                        HStack {
                            Spacer()
                            ResultDolView(selectedFaceShape: store.selectedFaceShape)
                                .frame(width: 270, height: 270)
                            Spacer()
                        }
                    }
                    
                    VStack {
                        HStack(alignment: .center, spacing: 5) {
                            HStack {
                                CustomText(text: store.stoneName,
                                           font: Font.uiFont(for: Font.subtitle1)!,
                                           textColor: .coreBlack,
                                           letterSpacingPercentage: -2.5,
                                           lineSpacingPercentage: 160,
                                           textAlign: .center)
                                    .font(.system(size: 24))
                                    .fixedSize()
                                    .lineLimit(1)
                            }
                            HStack {
                                Button(action: {
                                    store.send(.setIsEditingName(true))
                                    store.send(.setOriginalStoneName(store.stoneName))
                                }) {
                                    Image("editIcon")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                }
                                .disabled(store.isEditingName || keyboardGuardian.keyboardHeight != 0)
                            }
                            .offset(y: 8)
                        }
                        Spacer().frame(height: geometry.size.height * 0.02)
                        HStack(spacing: 8) {
                            
                            //성격, 초기능력
                            VStack(spacing:10){
                                    HStack(spacing: 10) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.mainGreen)
                                        
                                        Text("성격").font(Font.customFont(Font.body1Bold)).foregroundStyle(.coreBlack)
                                        Spacer()
                                    }
                                    .frame(width:geometry.size.width * 0.27)
                                    HStack(spacing: 10) {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.mainGreen)
                                        
                                        Text("초기능력").font(Font.customFont(Font.body1Bold)).foregroundStyle(.coreBlack)
                                        Spacer()
                                    }
                                    .frame(width:geometry.size.width * 0.27)
                                }
                                .padding(.leading, 20)
                            //성격내용, 초기능력 내용
                            VStack(spacing:10){
                                HStack{
                                    Text("\(store.score.character.personality)").font(Font.customFont(Font.body1Bold)).foregroundStyle(Color.mainGreen)
                                    Spacer()
                                }
                                HStack{
                                    Text("\(store.score.character.baseAbilityTypeKorean)").font(Font.customFont(Font.body1Bold)).foregroundStyle(.coreBlack)
                                    Spacer()
                                    
                                }
                            }.frame(width:geometry.size.width * 0.23)
                                .padding(.trailing, 20)
                        }
                        .frame(width: geometry.size.width * 0.7, height: UIDevice.isPad ? 160 : 120)
                        .background(Color.ffffff)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.5), lineWidth: 0.05)
                        )
                    }
                    
                    Spacer().frame(height: 24)
                    
                    CustomTextField(
                        text: Binding(
                            get: { store.spaceName },
                            set: {
                                store.send(.setSpaceName($0))
                            }
                        ),
                        placeholder: "방 이름",
                        font: .customFont(Font.button1),
                        textColor: UIColor.coreDarkGreen,
                        maxLength: 15,
                        alertTitle: "글자 수 오류",
                        alertMessage: "방이름은 1~15자 사이로 설정해주세요.",
                        dismissButtonTitle: "확인",
                        onSubmit: {
                            store.send(.setIsEditingRoomName(false))
                        }
                    )
                    .frame(width: 320, height: 48)
                    .cornerRadius(30)
                    .onTapGesture {
                        store.send(.setIsEditingRoomName(true))
                        if !store.spaceName.isEmpty {
                            store.send(.setOriginalRoomName(store.spaceName))
                        }
                    }
                    
                    Spacer().frame(height: 16)
                    
                    HStack {
                        Button(action: {
                            guard store.finalButtonAvailable else { return }
                            store.send(.setFinalButton(false))
                            store.send(.adoptStone)
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                store.send(.setFinalButton(true))
                            }
                        }) {
                            HStack {
                                Spacer()
                                Text("함께 시작하기!")
                                    .font(.customFont(Font.button1))
                                    .foregroundColor(.mainWhite)
                                Spacer()
                            }
                        }
                        .frame(width: 320, height: 48)
                        .background(store.isFinalButtonDisabled ? Color.gray : Color.mainGreen)
                        .cornerRadius(24)
                        .disabled(store.isFinalButtonDisabled)
                    }
                    
                    Spacer().frame(height: geometry.size.height * 0.29)
                }
                .padding(.bottom, keyboardGuardian.keyboardHeight)
                .animation(.easeOut(duration: 0.3), value: keyboardGuardian.keyboardHeight)
            }
            
            // 이름 변경 창
            if store.isEditingName {
                Color.black.opacity(0.7).edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        if store.isEditingName {
                            store.send(.setStoneName(store.originalStoneName))
                            store.send(.setIsEditingName(false))
                        }
                        self.hideKeyboard()
                    }
                VStack(alignment: .center) {
                    VStack {
                        Spacer()
                        CustomText(text: "돌 이름 변경",
                                   font: Font.uiFont(for: Font.subtitle2)!,
                                   textColor: .coreDarkGreen,
                                   letterSpacingPercentage: -2.5,
                                   lineSpacingPercentage: 160,
                                   textAlign: .center)
                        Spacer()
                        CustomTextField(
                            text: Binding(
                                get: { store.stoneName },
                                set: {
                                    if $0.count > 6 {
                                        store.send(.setStoneName(String($0.prefix(6))))
                                    } else {
                                        store.send(.setStoneName($0))
                                    }
                                }
                            ),
                            placeholder: store.originalStoneName,
                            font: .customFont(Font.subtitle2),
                            maxLength: 6,
                            alertTitle: "소중한 이름",
                            alertMessage: "돌 이름은 1~6자 사이로 설정해주세요.",
                            dismissButtonTitle: "확인",
                            onSubmit: {
                                if store.stoneName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    store.send(.setEmptyNameAlert(true))
                                } else {
                                    store.send(.setIsEditingName(false))
                                }
                            }
                        )
                        .frame(width: 250, height: 48)
                        .cornerRadius(10)
                        CustomText(text: "돌 이름은 최대 6글자입니다.",
                                   font: Font.uiFont(for: Font.body3Bold)!,
                                   textColor: .coreDisabled,
                                   letterSpacingPercentage: -2.5,
                                   lineSpacingPercentage: 160,
                                   textAlign: .center)
                        CustomButton(
                            title: "완료",
                            font: .customFont(Font.button1),
                            textColor: .coreWhite,
                            action: {
                                if store.stoneName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                    store.send(.setEmptyNameAlert(true))
                                } else {
                                    store.send(.setIsEditingName(false))
                                }
                            }
                        )
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
                    .alert(isPresented: Binding(
                        get: { store.emptyNameAlert },
                        set: { store.send(.setEmptyNameAlert($0)) }
                    )) {
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
        .navigationBarBackButtonHidden(true)
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
        .alert(
            isPresented: Binding(
                get: { store.showResultAlert },
                set: { store.send(.setShowResultAlert($0)) }
            ),
            content: {
                Alert(
                    title: Text(store.resultAlertTitle),
                    message: Text(store.resultAlertMessage),
                    dismissButton: .default(Text("확인"), action: {
                        store.send(.setShowResultAlert(false))
                    })
                )
            }
        )
    }
}


