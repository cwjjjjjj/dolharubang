import ComposableArchitecture
import SwiftUI

struct ProfileView: View {
    @Binding var showPopup: Bool // 팝업 표시 여부
    @State var store: StoreOf<ProfileFeature> // Store로 상태 및 액션 전달

    var body: some View {
        VStack(alignment: .center) {
            Spacer().frame(height: 24)
            
            HStack {
                Text("돌 프로필")
                    .font(Font.customFont(Font.subtitle3))
                    .foregroundColor(.decoSheetGreen)
                    .padding(.leading, 24)
                
                Spacer()
                
                Button(action: {
                    showPopup = false
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.placeHolder)
                }
                .padding(.trailing, 24)
            } // <--- 괄호 닫음
            
            Spacer().frame(height: 20)
            
            Divider()
            if let profile = store.profile {
                VStack {
                    // 상단 부분
                    HStack(spacing: 14) { // 이미지랑 정보 공간
                        // 이미지
                        Image(uiImage: store.captureDol)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80)
                            .padding(14)
                            .background(Color.init(hex: "F2EEE7"))
                            .clipShape(Circle())
                        
                        VStack {
                            HStack(spacing: 8) {
                                if store.selectedProfileEdit {
                                            HStack(alignment: .center) {
                                                TextField("", text: $store.dolName.sending(\.dolNameChanged))
                                                    .font(.customFont(Font.button2))
                                                    .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                                                    .multilineTextAlignment(.center)
                                                    .textFieldStyle(PlainTextFieldStyle())
                                            }
                                            .padding(EdgeInsets(top: 11, leading: 0, bottom: 11, trailing: 0))
                                            .frame(width: 128, height: 22)
                                } else {
                                Text(profile.dolName)
                                        .font(Font.customFont(Font.subtitle3))
                                        .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                                }
                                buttonView()
                            }
                            .frame(width: 156)
                            .padding(.vertical, 8)
                            
                            VStack(alignment: .leading, spacing: 12) {
                                HStack(spacing: 6) {
                                    Text("· 성격")
                                        .font(Font.customFont(Font.body4Bold))
                                        .lineSpacing(19.80)
                                        .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                                    Text("\(profile.personality)")
                                        .font(Font.customFont(Font.body4Bold))
                                        .lineSpacing(19.80)
                                        .foregroundColor(Color(red: 0.38, green: 0.52, blue: 0))
                                    Spacer()
                                }
                                .frame(width: 156)
                                HStack(spacing: 6) {
                                    Text("· 초기능력")
                                        .font(Font.customFont(Font.body4Bold))
                                        .lineSpacing(19.80)
                                        .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                                    Text("\(profile.baseAbility)")
                                        .font(Font.customFont(Font.body4Bold))
                                        .lineSpacing(19.80)
                                        .foregroundColor(Color(red: 0.38, green: 0.52, blue: 0))
                                    Spacer()
                                }
                                .frame(width: 156)
                                HStack(spacing: 6) {
                                    Text("· 주운 날")
                                        .font(Font.customFont(Font.body4Bold))
                                        .lineSpacing(19.80)
                                        .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                                    Text("\(profile.dolBirth)")
                                        .font(Font.customFont(Font.body4Bold))
                                        .lineSpacing(19.80)
                                        .foregroundColor(Color(red: 0.38, green: 0.52, blue: 0))
                                    Spacer()
                                }
                                .frame(width: 156)
                            }
                        }
                    }
                    .frame(width: 272)
                    .padding(.top, 12)
                    
                    // 게이지
                    VStack(spacing: 10) {
                        HStack(spacing: 4) {
                            Text("친밀도")
                                .font(Font.customFont(Font.body3Bold))
                                .lineSpacing(21.60)
                                .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                            Text("\(profile.friendShip / 100)Lv")
                                .font(Font.customFont(Font.body3Bold))
                                .lineSpacing(21.60)
                                .foregroundColor(Color(red: 0.38, green: 0.52, blue: 0))
                            Spacer()
                            Text("\(profile.friendShip % 100)%")
                                .font(Font.customFont(Font.body3Bold))
                                .lineSpacing(21.60)
                                .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                        }
                        .frame(width: 272)
                        
                        // 게이지바
                        ProgressView(value: Double(profile.friendShip % 100), total: 100)
                            .progressViewStyle(LinearProgressViewStyle())
                            .frame(width: 272)
                            .accentColor(Color.init(hex: "A5CD3B"))
                    }
                    .padding(.bottom, 12)
                    .padding(.top, 20)
                    
                    Divider()
                        .frame(width: 272)
                        .background(Color(red: 0.90, green: 0.87, blue: 0.84))
                    
                    // 활성능력탭
                    VStack(spacing: 8) {
                        HStack {
                            Text("활성 능력")
                                .font(Font.customFont(Font.body3Bold))
                                .lineSpacing(21.60)
                                .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                            Spacer()
                        }
                        .frame(width: 272)
                        HStack {
                            // activeAbility 반복문
                            ForEach(profile.activeAbility, id: \.self) { ability in
                                HStack {
                                    Text("\(ability)")
                                        .font(Font.customFont(Font.body5Bold))
                                        .lineSpacing(18)
                                        .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                                }
                                .padding(8)
                                .background(.white)
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .inset(by: 0.25)
                                        .stroke(Color(red: 0.51, green: 0.49, blue: 0.45), lineWidth: 0.25)
                                )
                            }
                            Spacer()
                        }
                        .frame(width: 272)
                    }
                    .padding(.vertical, 6)
                    
                    Divider()
                        .frame(width: 272)
                        .background(Color(red: 0.90, green: 0.87, blue: 0.84))
                    
                    // 잠재능력탭
                    VStack(spacing: 8) {
                        HStack {
                            Text("잠재 능력")
                                .font(Font.customFont(Font.body3Bold))
                                .lineSpacing(21.60)
                                .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                            Spacer()
                        }
                        .frame(width: 272)
                        
                        HStack {
                            ForEach(profile.potential, id: \.self) { ability in
                                HStack(spacing: 10) {
                                    Text("🔒 \(ability)")
                                        .font(Font.customFont(Font.body5Bold))
                                        .lineSpacing(18)
                                        .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                                }
                                .padding(8)
                                .background(.white)
                                .cornerRadius(15)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 15)
                                        .inset(by: 0.25)
                                        .stroke(Color(red: 0.51, green: 0.49, blue: 0.45), lineWidth: 0.25)
                                )
                            }
                            Spacer()
                        }
                        .frame(width: 272)
                    }
                    .padding(.vertical, 6)
                }
            }
            Spacer()
        }
        .frame(width: 320, height: 417)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 10)
        .onAppear {
            store.send(.fetchProfile)
        }
    }
    
    @ViewBuilder
    private func buttonView() -> some View {
        let buttonAction: () -> Void = store.selectedProfileEdit ? {
            store.send(.completeEditProfile)
        } : {
            store.send(.clickEditProfile)
        }
        
        Button(action: buttonAction) {
                Image(store.selectedProfileEdit ? "complete" : "edit")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 20)
        }
    }

}
