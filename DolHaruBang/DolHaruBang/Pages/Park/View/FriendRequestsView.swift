import SwiftUI
import ComposableArchitecture

private func formattedDateF(_ date: Date) -> String {
    let year = dateFormatterYear.string(from: date)
    let month = dateFormatterMonth.string(from: date)
    let day = dateFormatterDay.string(from: date)
//    let weekday = dateFormatterWeekday.string(from: date)
    
    return "\(year).\(month).\(day)."
}

struct FriendRequestsView: View {
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
                    store.showFriendRequests = false
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
                    ForEach(store.friendListFeatureState.friendRequests, id: \.id) { req in
                        HStack(alignment: .center, spacing: 12) {
                            ProfileImageView(
                                imageURL: req.isSender ? req.receiverProfileImageURL : req.requesterProfileImageURL,
                                size: 48
                            )
                            
                            VStack(alignment: .leading, spacing: 4) {

                                Text(formattedDateF(req.modifiedAt))
                                    .font(Font.customFont(.init(customFont: .nanumSquareRoundBold, size: 7)))
                                    .foregroundStyle(Color(hex: "BAAC9B"))
                                
                                if req.isSender {
                                    // 내가 보낸 요청일 경우
                                    HStack(spacing: 0) {
                                        Text(req.receiverNickname)
                                            .font(.customFont(Font.body2Bold))
                                            .foregroundColor(.decoSheetGreen)
                                        Text("님에게")
                                            .font(.customFont(Font.body2Bold))
                                            .foregroundColor(.coreDisabled)
                                    }
                                    Text("친구 신청을 보냈습니다.")
                                        .font(.customFont(Font.body2Bold))
                                        .foregroundColor(.coreDisabled)
                                } else {
                                    // 내가 받은 요청일 경우
                                    HStack(spacing: 0) {
                                        Text(req.requesterNickname)
                                            .font(.customFont(Font.body2Bold))
                                            .foregroundColor(.decoSheetGreen)
                                        Text("님이")
                                            .font(.customFont(Font.body2Bold))
                                            .foregroundColor(.coreDisabled)
                                    }
                                    Text("당신과 친구가 되고 싶어합니다.")
                                        .font(.customFont(Font.body2Bold))
                                        .foregroundColor(.coreDisabled)
                                    
                                    // 수락/거절 버튼은 내가 받은 요청일 경우에만 표시
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
            if store.friendListFeatureState.friendRequests.isEmpty {
                await store.send(.friendListFeatureAction(.fetchFriendRequests)).finish()
            }
        }
    }
}
