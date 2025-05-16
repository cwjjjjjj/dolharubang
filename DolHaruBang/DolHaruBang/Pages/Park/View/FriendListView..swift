import SwiftUI
import ComposableArchitecture

struct FriendListView: View {
    @State var store: StoreOf<FriendListFeature>
    
    var body: some View {
        VStack(spacing: 16) {
            ScrollView {
                Spacer().frame(height: 16)
                
                // 검색창
                HStack {
                    CustomTextField(
                        text: $store.searchKeyword,
                        placeholder: "닉네임으로 친구를 찾아보세요.",
                        placeholderColor: UIColor.coreLightGray,
                        font: .customFont(Font.button2),
                        textColor: UIColor.coreBlack,
                        maxLength: 15,
                        onSubmit: {},
                        alignment: .leading,
                        leftPadding: 16
                    )
                    .frame(height: 40)
                    .cornerRadius(20)
                    .onChange(of: store.searchKeyword) {
                        store.send(.searchKeywordChanged(store.searchKeyword))
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        print(store.searchKeyword, "가 검색되었습니다.")
                        store.send(.searchFriends)
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
                
                // 본문 분기
                // 1. 친구 목록 로딩 중
                if store.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .coreGreen))
                            .scaleEffect(1.5)
                            .padding(.vertical, 40)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 400)
                }
                // 2. 친구 닉네임 검색 중이고, 아직 결과가 없을 때
                else if store.isSearching && store.searchResults.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .coreGreen))
                            .scaleEffect(1.5)
                            .padding(.vertical, 40)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 400)
                }
                // 3. 검색창이 비어있을 때 => 친구 목록 표시
                else if store.searchKeyword.isEmpty {
                    // 친구가 없을 때
                    if store.friends.isEmpty {
                        VStack {
                            Spacer()
                            Text("아직 친구가 없습니다.")
                                .font(.customFont(Font.body2Bold))
                                .foregroundColor(.coreDisabled)
                                .multilineTextAlignment(.center)
                            Spacer()
                        }
                        .frame(maxWidth: .infinity, minHeight: 400)
                    }
                    // 친구가 있을 때
                    else {
                        LazyVStack(spacing: 16) {
                            ForEach(store.friends, id: \.id) { friend in
                                SwipeableFriendItemView(
                                    friend: friend,
                                    isLoading: store.isLoading,
                                    onRequestAccept: {
                                        store.send(.acceptFriend(friend.id))
                                    },
                                    onDeleteFriend: {
                                        store.send(.deleteFriend(friend.id))
                                    })
                            }
                        }
                        .padding(.horizontal, 20)
                    }
                }
                else if store.searchResults.isEmpty {
                    // 4. 검색 결과 없음
                    VStack {
                        Spacer()
                        Text("검색 결과가 없습니다.")
                            .font(.customFont(Font.body2Bold))
                            .foregroundColor(.coreDisabled)
                            .multilineTextAlignment(.center)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, minHeight: 400)
                }
                else {
                    // 5. 친구 닉네임 검색 결과
                    LazyVStack(spacing: 16) {
                        ForEach(store.searchResults, id: \.memberId) { member in
                            SwipeableMemberItemView(
                                member: member,
                                isLoading: store.isLoading,
                                onRequestFriend: {
                                    store.send(.requestFriend(member.memberId))
                                },
                                onAcceptFriend: {
                                    store.send(.acceptFriend(member.memberId))
                                },
                                onDeclineFriend: {
                                    store.send(.declineFriend(member.memberId))
                                },
                                onDeleteFriend: {
                                    store.send(.deleteFriend(member.memberId))
                                },
                                onCancelFriend: {
                                    store.send(.cancelFriendRequest(member.memberId))
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                }
            }
        }
        .background(.coreWhite)
        .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
        .task {
            if store.friends.isEmpty {
                await store.send(.fetchFriends).finish()
            }
        }
    }
}

struct SwipeableMemberItemView: View {
    let member: MemberInfo
    let isLoading: Bool
    let onRequestFriend: () -> Void
    let onAcceptFriend: () -> Void
    let onDeclineFriend: () -> Void
    let onDeleteFriend: () -> Void
    let onCancelFriend: () -> Void

    @State private var offset: CGFloat = 0
    @State private var isSwiping = false
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack(alignment: .trailing) {
            // 삭제 버튼 배경
            if member.isFriend {
                Color.ffffff
                    .frame(width: offset < 0 ? -offset : 0)
            }

            HStack(spacing: 10) {
                ProfileImageView(imageURL: member.profileImageURL, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(member.nickname)
                        .font(.customFont(Font.body4Bold))
                        .foregroundColor(.coreDarkGreen)
                    Text(member.spaceName)
                        .font(.customFont(Font.body3Bold))
                        .foregroundColor(.coreBlack)
                }
                
                Spacer()
                
                // MARK: 친구가 아니면서 아무런 관계도 아닌 경우
                if !member.isFriend && member.isReceived == false && member.isRequested == false {
                    Button(action: {
                        onRequestFriend()
                    }) {
                        Text("친구 요청")
                            .font(.customFont(Font.body4Bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.coreGreen)
                            .cornerRadius(8)
                    }
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.5 : 1)
                }
                // MARK: 내가 요청을 보낸 상대
                else if !member.isFriend && member.isRequested == true {
                    Button(action: {
                        onCancelFriend()
                    }) {
                        Text("요청 취소")
                            .font(.customFont(Font.body4Bold))
                            .foregroundColor(.coreGreen)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.white)
                            .cornerRadius(8)
                    }
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.5 : 1)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.coreGreen, lineWidth: 1.5)
                    )
                }
                // MARK: 내가 요청을 받은 상대
                else if !member.isFriend && member.isReceived == true {
                    Button(action: {
                        onAcceptFriend()
                    }) {
                        Text("수락")
                            .font(.customFont(Font.body4Bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.coreGreen)
                            .cornerRadius(8)
                    }
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.5 : 1)
                    
                    Button(action: {
                        onDeclineFriend()
                    }) {
                        Text("거절")
                            .font(.customFont(Font.body4Bold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.red)
                            .cornerRadius(8)
                    }
                    .disabled(isLoading)
                    .opacity(isLoading ? 0.5 : 1)
                }
            }
            .padding()
            .frame(height: 72)
            .background(Color.ffffff)
            .cornerRadius(15)
            .offset(x: offset)
            .shimmering(active: isLoading)
            .gesture(
                member.isFriend ?
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -80) // 최대 -80까지
                            isSwiping = true
                        }
                    }
                    .onEnded { value in
                        if value.translation.width < -40 {
                            withAnimation { offset = -80 }
                        } else {
                            withAnimation { offset = 0 }
                        }
                        isSwiping = false
                    }
                : nil
            )
            .onTapGesture {
                if isSwiping && offset < 0 {
                    withAnimation {
                        offset = 0
                    }
                    isSwiping = false
                }
            }

            // 삭제 버튼
            if member.isFriend && offset < 0 {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Text("친구 삭제")
                        .font(.customFont(Font.body4Bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .background(Color.red)
                .cornerRadius(8)
                .transition(.move(edge: .trailing))
                .alert("정말 친구를 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
                    Button("삭제", role: .destructive) {
                        onDeleteFriend()
                        withAnimation { offset = 0 }
                    }
                    Button("취소", role: .cancel) {
                        withAnimation { offset = 0 }
                    }
                }
            }
        }
    }
}

struct SwipeableFriendItemView: View {
    let friend: Friend
    let isLoading: Bool
    let onRequestAccept: () -> Void
    let onDeleteFriend: () -> Void

    // 상대방 정보
    var displayNickname: String {
        friend.isSender ? friend.receiverNickname : friend.requesterNickname
    }
    var displaySpaceName: String {
        friend.isSender ? friend.receiverSpaceName : friend.requesterSpaceName
    }
    var displayProfileImageURL: URL? {
        friend.isSender ? friend.receiverProfileImageURL : friend.requesterProfileImageURL
    }

    @State private var offset: CGFloat = 0
    @State private var isSwiping = false
    @State private var showDeleteAlert = false

    var body: some View {
        ZStack(alignment: .trailing) {
            // 삭제 버튼 배경
            if friend.acceptedAt != nil {
                Color.ffffff
                    .frame(width: offset < 0 ? -offset : 0)
            }

            HStack(spacing: 10) {
                ProfileImageView(imageURL: displayProfileImageURL, size: 48)
                VStack(alignment: .leading, spacing: 4) {
                    Text(displayNickname)
                        .font(.customFont(Font.body4Bold))
                        .foregroundColor(.coreDarkGreen)
                    Text(displaySpaceName)
                        .font(.customFont(Font.body3Bold))
                        .foregroundColor(.coreBlack)
                }
                Spacer()
                // 친구 상태
                if let _ = friend.acceptedAt {
                    Text("친구")
                        .font(.customFont(Font.body4Bold))
                        .foregroundColor(.coreGray)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.coreLightGray)
                        .cornerRadius(8)
                }
                // 친구 요청 상태
                else {
                    if friend.isSender {
                        Text("요청 보냄")
                            .font(.customFont(Font.body4Bold))
                            .foregroundColor(.coreGray)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(Color.coreLightGray)
                            .cornerRadius(8)
                    } else {
                        Button(action: {
                            onRequestAccept()
                        }) {
                            Text("수락")
                                .font(.customFont(Font.body4Bold))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color.coreGreen)
                                .cornerRadius(8)
                        }
                        .disabled(isLoading)
                        .opacity(isLoading ? 0.5 : 1)
                    }
                }
            }
            .padding()
            .frame(height: 72)
            .background(Color.ffffff)
            .cornerRadius(15)
            .offset(x: offset)
            .shimmering(active: isLoading)
            .gesture(
                // acceptedAt이 있을 때(진짜 친구일 때)만 스와이프 허용
                friend.acceptedAt != nil ?
                DragGesture()
                    .onChanged { value in
                        if value.translation.width < 0 {
                            offset = max(value.translation.width, -80)
                            isSwiping = true
                        }
                    }
                    .onEnded { value in
                        if value.translation.width < -40 {
                            withAnimation { offset = -80 }
                        } else {
                            withAnimation { offset = 0 }
                        }
                        isSwiping = false
                    }
                : nil
            )
            .onTapGesture {
                if isSwiping && offset < 0 {
                    withAnimation {
                        offset = 0
                    }
                    isSwiping = false
                }
            }

            // 삭제 버튼
            if friend.acceptedAt != nil && offset < 0 {
                Button(action: {
                    showDeleteAlert = true
                }) {
                    Text("친구 삭제")
                        .font(.customFont(Font.body4Bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                }
                .background(Color.red)
                .cornerRadius(8)
                .padding(.horizontal, 8)
                .transition(.move(edge: .trailing))
                .alert("정말 친구를 삭제하시겠습니까?", isPresented: $showDeleteAlert) {
                    Button("삭제", role: .destructive) {
                        onDeleteFriend()
                        withAnimation { offset = 0 }
                    }
                    Button("취소", role: .cancel) {
                        withAnimation { offset = 0 }
                    }
                }
            }
        }
    }
}




