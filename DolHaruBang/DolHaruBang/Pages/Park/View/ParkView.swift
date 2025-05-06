import SwiftUI
import ComposableArchitecture

struct ParkView: View {
    @State var store: StoreOf<ParkFeature>
    @Shared(.inMemory("dolprofile")) var captureDol: UIImage = UIImage()
    
    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            
            ZStack {
                Image(Background(rawValue: store.state.selectedBackground.rawValue)!.fileName)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Spacer().frame(height: totalHeight * 77 / 852)
                    
                    ZStack {
                        HStack {
                            Spacer()
                            Text("공원")
                                .padding(.bottom, 15)
                                .font(Font.customFont(Font.h6))
                                .shadow(radius: 4, x: 0, y: 1)
                            Spacer()
                        }
                        
                        // 친구 일 때 친구 신청 내역
                        if (store.selectedTap == 1) {
                            HStack {
                                Spacer()
                                Button(action: {
                                    store.send(.toggleFriendRequests)
                                }) {
                                    ZStack(alignment: .topTrailing) {
                                        Image("friendsHistory")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                        
                                        if !store.friendListFeatureState.friendRequests.isEmpty {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.ffffff.opacity(0.3))
                                                    .stroke(.ffffff.opacity(0.7), lineWidth: 0.5)
                                                    .frame(width: 14, height: 14)
                                                Text("N")
                                                    .font(Font.customFont(.init(customFont: .nanumSquareRoundExtraBold, size: 8)))
                                                    .foregroundColor(.ffffff)
                                            }
                                            .offset(x: 2.5, y: 2.5)
                                        }
                                    }
                                }
                                .padding(.bottom, 15)
                                .padding(.trailing, 20)
                            }
                        }
                    }
                    .frame(width: geometry.size.width)
                    
                    Spacer()
                    
                    VStack(spacing: 0) {
                        HStack(spacing: 0) {
                            TabBarButton(title: "돌잔치", isSelected: store.selectedTap == 0) {
                                store.send(.tapDoljanchi)
                            }
                            TabBarButton(title: "친구", isSelected: store.selectedTap == 1) {
                                store.send(.tapFriendList)
                            }
                        }
                        .frame(height: 40)
                        .cornerRadius(15, corners: [.topLeft, .topRight])
                        .background(Color.coreGreen)
                        .cornerRadius(15, corners: [.topLeft, .topRight])
                        
                        if (store.selectedTap == 0) {
                            DoljanchiView(store: store.scope(state: \.doljanchiFeatureState, action: \.doljanchiFeatureAction))
                                 .tag(0)
                         }
                        else {
                            FriendListView(store: store.scope(state: \.friendListFeatureState, action: \.friendListFeatureAction))
                                 .tag(1)
                        }
                        
                     }
                     .frame(height: totalHeight * 680 / 852)
                    
                    Spacer().frame(minHeight: totalHeight * 64 / 804)

                }
                
                // 친구 신청 내역 보여주는 팝업
                if store.showFriendRequests {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            if (store.showFriendRequests) {
                                store.send(.toggleFriendRequests)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(1)

                    FriendRequestsView(store: store)
                        .zIndex(2)
                }
                
                if store.state.doljanchiFeatureState.showJarangPopup {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            store.send(.doljanchiFeatureAction(.toggleJarangPopup))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(1)
                    
                    VStack(alignment: .center) {
                        Spacer().frame(height: 24)
                        
                        HStack {
                            Text("\(store.dolInfo?.dolName ?? "돌") 자랑하기")
                                .font(Font.customFont(Font.subtitle3))
                                .foregroundColor(.decoSheetGreen)
                                .padding(.leading, 24)

                            
                            Spacer()
                            
                            Button(action: {
                                store.send(.doljanchiFeatureAction(.toggleJarangPopup))
                            }) {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                    .foregroundColor(.placeHolder)
                            }
                            .padding(.trailing, 24)
                        }
                        
                        Spacer().frame(height: 20)
                        
                        Divider()
                
                        Image(uiImage: captureDol)
                            .resizable()
                            .scaledToFit()
                        
                        Spacer()
                        
                        
                        HStack {
                            Spacer()
                            
                            HStack(spacing: 8) {
                                Image(systemName: store.isPublic ? "globe" : "lock.fill")
                                    .foregroundColor(store.isPublic ? .coreGreen : .gray)
                                    .frame(width: 16, height: 16)
                                Toggle(isOn: $store.isPublic) {
                                    Text(store.isPublic ? "공개" : "비공개")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(store.isPublic ? .coreGreen : .gray)
                                }
                                .labelsHidden()
                                .toggleStyle(SwitchToggleStyle(tint: .coreGreen))
                            }
                            .padding(.bottom, 16)
                            
                            Spacer()
                            
                            // 최종 자랑 버튼
                            Button(action: {
                                print("돌 자랑 api 슈웃~!")
                                guard let imageBase64 = captureDol.jpegData(compressionQuality: 0.8)?.base64EncodedString() else {
                                    store.send(.toggleImageErrorAlert)
                                    return
                                }
                                guard let dolName = store.dolInfo?.dolName else {
                                    store.send(.toggleDolNameErrorAlert)
                                    return
                                }
                                store.send(.doljanchiFeatureAction(.registJarang(store.isPublic, imageBase64, dolName)))
                            }) {
                                HStack {
                                    Text("자랑하기")
                                        .font(.customFont(Font.button4))
                                        .foregroundColor(.coreWhite)
                                }
                                .frame(width: 82, height: 32)
                                .background(.coreGreen)
                                .cornerRadius(16)
                            }
                            .padding(.bottom, 16)

                            
                            Spacer()
                        }
                    }
                    .onAppear {
                        store.send(.fetchDolInfo)
                    }
                    .alert("이미지 변환 실패", isPresented: $store.showImageErrorAlert) {
                        Button("확인", role: .cancel) { }
                    } message: {
                        Text("이미지 변환에 실패했습니다. 다시 시도해 주세요.")
                    }
                    .alert("돌 이름 불러오기 실패", isPresented: $store.showDolNameErrorAlert) {
                        Button("확인", role: .cancel) { }
                    } message: {
                        Text("돌 이름을 불러오지 못했습니다. 다시 시도해 주세요.")
                    }

                    .frame(width: 320, height: 400)
                    .background(Color.white)
                    .cornerRadius(25)
                    .shadow(radius: 10)
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(radius: 10)
                        .zIndex(2)
                }
            }
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarBackButtonHidden(true)
    }
}

struct TabBarButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        HStack {
            Spacer()
            Button(action: action) {
                InnerShadowText(
                    text: title,
                    blur: 5,
                    x: 0, y: isSelected ? 4 : 0,
                    textColor: isSelected ? .coreGreen : .coreWhite,
                    shadowColor: isSelected ? Color(hex: "A5CD3B") : Color(hex: "618501"),
                    blendMode: true,
                    opacity: isSelected ? 0.5 : 0.6)
                    .font(Font.customFont(Font.h9))
                    .foregroundColor(isSelected ? .coreGreen : .coreWhite)
            }
            Spacer()
        }
        .frame(height: 40)
        .cornerRadius(15, corners: [.topLeft, .topRight])
        .background(isSelected ? .coreWhite : .coreGreen)
    }
}
