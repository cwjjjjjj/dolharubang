import SwiftUI
import ComposableArchitecture

struct FriendListView: View {
    @State var store: StoreOf<FriendListFeature>
    
    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                Spacer().frame(height: 16)
                
                HStack {
                    CustomTextField(
                        text: $store.searchKeyword,
                        placeholder: "닉네임/방 이름을 입력하세요.",
                        placeholderColor: UIColor.coreLightGray,
                        font: .customFont(Font.button2),
                        textColor: UIColor.coreBlack,
                        maxLength: 15,
                        onSubmit: {
                            
                        },
                        alignment: .leading,
                        leftPadding: 16
                    )
                    .frame(height: 40)
                    .cornerRadius(20)
                    
                    Spacer()

                    Button(action: {
                        print(store.searchKeyword, "가 검색되었습니다.")
                    }) {
                        HStack {
                            Text("찾기")
                                .font(.customFont(Font.button3))
                                .foregroundColor(.coreWhite)
                        }
                        .frame(width: 56, height: 40)
                        .background(.coreGreen)
                        .cornerRadius(24)
                    }
                }
                .padding(.horizontal, 20)
                

                LazyVStack(spacing: 16) {
                    if (store.searchKeyword.isEmpty) {
                        ForEach(store.friendsList) { friend in
                            FriendItemView(friend: friend, isLoading: store.isLoading)
                        }
                    }
                    else {
                        ForEach(store.friendsList.filter{ friend in
                            friend.nickname.lowercased().contains(store.searchKeyword.lowercased()) ||
                            friend.roomName.lowercased().contains(store.searchKeyword.lowercased())
                        }) { friend in
                            FriendItemView(friend: friend, isLoading: store.isLoading)
                        }
                    }
                }
                .padding(.horizontal, 20)
            }
        }
        .background(.coreWhite)
        .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
        .task {
            // 이미 로드되지 않았을 때만 loadFriends 액션을 보냅니다
            if store.friendsList.isEmpty {
                await store.send(.loadFriends).finish()
            }
        }
    }
}

struct FriendItemView: View {
    let friend: Friend
    let isLoading: Bool
    
    var body: some View {
        Rectangle()
            .fill(Color.ffffff)
            .frame(height: 72)
            .cornerRadius(15)
            .overlay(
                HStack(spacing: 10) {
                    ProfileImageView(imageURL: friend.profileImageURL, size: 48)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(friend.nickname)
                            .font(.customFont(Font.body4Bold))
                            .foregroundColor(.coreDarkGreen)
                        Text(friend.roomName)
                            .font(.customFont(Font.body3Bold))
                            .foregroundColor(.coreBlack)
                    }
                    Spacer()
                    Button(action: {
                        print(friend.nickname , "에게 클로버를 보냅니다.")
                    }) {
                        ZStack {
                            Circle()
                                .fill(.coreWhite)
                                .frame(width: 48, height: 48)
                                .overlay(
                                    Image("Clover")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                )
                        }
                    }
                    .padding(.horizontal, 12)
                    .opacity(isLoading ? 0 : 1)
                }
                .padding()
            )
            .shimmering(active: isLoading)
    }
}
