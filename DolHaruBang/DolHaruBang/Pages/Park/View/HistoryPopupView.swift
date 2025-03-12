import SwiftUI
import ComposableArchitecture

struct HistoryPopupView: View {
    @State var store: StoreOf<ParkFeature>
    
    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 23)
            
            HStack {
                Text("친구 신청 내역")
                    .font(Font.customFont(Font.subtitle3))
                    .foregroundColor(.decoSheetGreen)
                    .padding(.leading, 24)
                
                Spacer()
                
                Button(action: {
                    store.showHistory = false
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
            
            ScrollView {
                LazyVStack(spacing: 24) {
                    ForEach(store.history) { req in
                        HStack (alignment: .center, spacing: 12) {
                            ProfileImageView(imageURL: req.profileImg, size: 48)
                            
                            VStack (alignment: .leading, spacing: 4) {
                                Text(formattedDate(req.modifiedAt, false))
                                    .font(Font.customFont(.init(customFont: .nanumSquareRoundBold, size: 7)))
                                    .foregroundStyle(Color(hex: "BAAC9B"))
                                HStack(spacing: 0) {
                                    Text(req.nickname)
                                        .font(.customFont(Font.body2Bold))
                                        .foregroundColor(.decoSheetGreen)
                                    Text("님이")
                                        .font(.customFont(Font.body2Bold))
                                        .foregroundColor(.coreDisabled)
                                }
                                Text("당신과 친구가 되고 싶어합니다.")
                                    .font(.customFont(Font.body2Bold))
                                    .foregroundColor(.coreDisabled)
                                
                                HStack {
                                    Button(action: {
                                        // 수락 요청
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.coreLightGray, lineWidth: 0.6)
                                                .background(Color.clear)
                                                .frame(width: 102, height: 25)
                                            Text("수락")
                                                .font(.customFont(Font.body3Bold))
                                                .foregroundStyle(.coreDisabled)
                                        }
                                    }
                                    
                                    Button(action: {
                                        // 거절 요청
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(Color.coreLightGray, lineWidth: 0.6)
                                                .background(Color.clear)
                                                .frame(width: 102, height: 25)
                                            Text("거절")
                                                .font(.customFont(Font.body3Bold))
                                                .foregroundStyle(.coreDisabled)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: 88)
                    }
                    
                    Spacer()
                }
            }
        }
        .frame(width: 320, height: 420)
        .background(Color.coreWhite)
        .cornerRadius(25)
        .shadow(radius: 10)
        .task {
            if store.history.isEmpty {
                await store.send(.loadHistory).finish()
            }
        }
    }
}
