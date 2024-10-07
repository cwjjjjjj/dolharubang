import SwiftUI
import ComposableArchitecture

struct ParkView: View {
    @State var store: StoreOf<ParkFeature>
    
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
                        
                        if (store.selectedTap == 1) {
                            HStack {
                                Spacer()
                                Button(action: {
                                    store.send(.toggleHistory)
                                    print("toggle되었습니다.")
                                }) {
                                    ZStack(alignment: .topTrailing) {
                                        Image("friendsHistory")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 40, height: 40)
                                        
                                        if store.hasHistory {
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
                        // Custom tab bar
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
                
                if store.showHistory {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            if (store.showHistory) {
                                store.send(.toggleHistory)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(1)

                    HistoryPopupView(store: store)
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
