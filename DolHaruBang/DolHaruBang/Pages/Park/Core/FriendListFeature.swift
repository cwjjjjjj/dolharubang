import ComposableArchitecture
import Foundation

struct MemberInfo: Equatable, Decodable {
    let memberId: Int
    let nickname: String
    let profileImageURL: URL?
    let spaceName: String
    let isFriend: Bool
    let isRequested: Bool?
    let isReceived: Bool?
}

struct Friend: Identifiable, Equatable, Decodable {
    let id: Int
    let isSender: Bool // true이면 내가 보낸 요청 // false이면 내가 받은 요청
    let requesterNickname: String
    let receiverNickname: String
    let requesterSpaceName: String
    let receiverSpaceName: String
    let requesterProfileImageURL: URL?
    let receiverProfileImageURL: URL?
    let modifiedAt: Date
    let acceptedAt: Date?
}

@Reducer
struct FriendListFeature {
    @Dependency(\.parkClient) var parkClient
  
    @ObservableState
    struct State: Equatable {
        var searchKeyword: String = ""
        var friends: [Friend] = []
        var friendRequests: [Friend] = []
        var isLoading: Bool = true
        var searchResults: [MemberInfo] = []
        var isSearching: Bool = false
    }

    // 액션 정의
    enum Action: BindableAction {
        // 친구 목록 불러오기
        case fetchFriends
        case fetchFriendsResponse(Result<[Friend], Error>)
        // 친구 신청 내역 불러오기
        case fetchFriendRequests
        case fetchFriendRequestsResponse(Result<[Friend], Error>)
        // 친구 검색
        case searchKeywordChanged(String)
        case searchFriends
        case searchFriendsResponse(Result<[MemberInfo], Error>)
        // 친구 요청 관련(요청 / 수락 / 거절)
        case requestFriend(Int)
        case requestFriendResponse(Result<Friend, Error>)
        case cancelFriendRequest(Int)
        case cancelFriendRequestResponse(Result<Friend, Error>)
        case acceptFriend(Int)
        case acceptFriendResponse(Result<Friend, Error>)
        case declineFriend(Int)
        case declineFriendResponse(Result<Friend, Error>)
        // 친구 삭제
        case deleteFriend(Int)
        case deleteFriendResponse(Result<Friend, Error>)
        case binding(BindingAction<State>)
    }

    // 리듀서 정의
    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
                case .binding(\.searchKeyword):
//                   print ("writing searchKeyword: " , state.searchKeyword)
                   return .none
                case .binding:
                    return .none
                // 친구 관련
                case .fetchFriends:
                    state.isLoading = true
                    print("친구 목록 불러오기 시작")
                    return .run { send in
                        do {
                            let friends = try await parkClient.fetchFriends()
                            
                            print("친구 목록 불러 오기 성공")
                            await send (.fetchFriendsResponse(.success(friends)))
                        }
                        catch {
                            print("친구 목록 불러오기 실패")
                            await send (.fetchFriendsResponse(.failure(error)))
                        }
                    }
                case let .fetchFriendsResponse(.success(friends)):
                    state.isLoading = false
                    state.friends = friends
                    print("친구 목록 갱신 성공")
                    return .none
                case let .fetchFriendsResponse(.failure(error)):
                    state.isLoading = false
                    print(error)
                    print("친구 목록 갱신 실패")
                    return .none
                // 친구 요청 관련
                case .fetchFriendRequests:
                    state.isLoading = true
                    print("친구 요청 목록 불러오기 시작")
                    return .run { send in
                        do {
                            let friendRequests = try await parkClient.fetchFriendRequests()
                            
                            await send(.fetchFriendRequestsResponse(.success(friendRequests)))
                        } catch  {
                            await send(.fetchFriendRequestsResponse(.failure(error)))
                        }
                    }
                case let .fetchFriendRequestsResponse(.success(friendRequests)):
                    state.isLoading = false
                    state.friendRequests = friendRequests
                    print("친구 요청 목록 갱신 성공")
                    return .none
                case let .fetchFriendRequestsResponse(.failure(error)):
                    state.isLoading = false
                    print(error)
                    print("친구 요청 목록 갱신 실패")
                    return .none
                // 친구 검색 관련
                case let .searchKeywordChanged(keyword):
                    state.searchKeyword = keyword
                    // 비워있지 않고, 검색 가능한 상태인 경우에만 검색 요청
                    if !keyword.isEmpty, keyword.endsWithSearchableCharacter {
                        state.isSearching = true
                        return .send(.searchFriends)
                             .debounce(id: "search", for: 0.3, scheduler: DispatchQueue.main)
                    } else if keyword.isEmpty {
                        state.isSearching = false
                        state.searchResults = []
                        return .none
                    } else {
                        return .none
                    }
                // 친구 검색 API 호출
                case .searchFriends:
                    state.isSearching = true
                    return .run { [keyword = state.searchKeyword] send in
                        do {
                            let results = try await parkClient.searchFriends(keyword)
                            await send(.searchFriendsResponse(.success(results)))
                        } catch {
                            await send(.searchFriendsResponse(.failure(error)))
                        }
                    }
                // 친구 검색 결과 처리
                case let .searchFriendsResponse(.success(results)):
                    state.isSearching = false
                    state.searchResults = results
                    return .none
                case .searchFriendsResponse(.failure):
                    state.isSearching = false
                    state.searchResults = []
                    return .none
                    
                // 친구 요청 및 취소
                case let .requestFriend(id):
                    state.isLoading = true
                    return .run { send in
                        do {
                            let requests = try await parkClient.requestFriend(id)
                            await send(.requestFriendResponse(.success(requests)))
                        } catch {
                            await send(.requestFriendResponse(.failure(error)))
                        }
                    }
                case let .requestFriendResponse(.success(requests)):
                    state.isLoading = false
                    if !state.searchKeyword.isEmpty {
                        return .merge(
                            .send(.fetchFriendRequests),
                            .send(.fetchFriends),
                            .send(.searchFriends)
                        )
                    } else {
                        return .merge(
                            .send(.fetchFriendRequests),
                            .send(.fetchFriends)
                        )
                    }
                case let .requestFriendResponse(.failure(error)):
                    state.isLoading = false
                    print("친구 요청 실패: \(error)")
                    return .none
                case let .cancelFriendRequest(id):
                    state.isLoading = true
                    return .run { send in
                        do {
                          let requests = try await parkClient.cancelFriendRequest(id)
                          await send(.cancelFriendRequestResponse(.success(requests)))
                        } catch {
                          await send(.cancelFriendRequestResponse(.failure(error)))
                        }
                    }
                case let .cancelFriendRequestResponse(.success(requests)):
                    state.isLoading = false
                    if !state.searchKeyword.isEmpty {
                        return .merge(
                            .send(.fetchFriendRequests),
                            .send(.fetchFriends),
                            .send(.searchFriends)
                        )
                    } else {
                        return .merge(
                            .send(.fetchFriendRequests),
                            .send(.fetchFriends)
                        )
                    }
                case let .cancelFriendRequestResponse(.failure(error)):
                    state.isLoading = false
                    print("친구 요청 취소 실패: \(error)")
                    return .none
                    
                // 친구 수락
                case let .acceptFriend(id):
                    state.isLoading = true
                    return .run { send in
                        do {
                            let requests = try await parkClient.acceptFriend(id)
                            await send(.acceptFriendResponse(.success(requests)))
                        } catch {
                            await send(.acceptFriendResponse(.failure(error)))
                        }
                    }
                case let .acceptFriendResponse(.success(requests)):
                    state.isLoading = false
                    if !state.searchKeyword.isEmpty {
                        return .merge(
                            .send(.fetchFriendRequests),
                            .send(.fetchFriends),
                            .send(.searchFriends)
                        )
                    } else {
                        return .merge(
                            .send(.fetchFriendRequests),
                            .send(.fetchFriends)
                        )
                    }
                case let .acceptFriendResponse(.failure(error)):
                    state.isLoading = false
                    print("친구 수락 실패: \(error)")
                    return .none

                // 친구 거절
                case let .declineFriend(id):
                    state.isLoading = true
                    return .run { send in
                        do {
                            let requests = try await parkClient.declineFriend(id)
                            await send(.declineFriendResponse(.success(requests)))
                        } catch {
                            await send(.declineFriendResponse(.failure(error)))
                        }
                    }
                case let .declineFriendResponse(.success(requests)):
                    state.isLoading = false
                    if !state.searchKeyword.isEmpty {
                        return .merge(
                            .send(.fetchFriendRequests),
                            .send(.fetchFriends),
                            .send(.searchFriends)
                        )
                    } else {
                        return .merge(
                            .send(.fetchFriendRequests),
                            .send(.fetchFriends)
                        )
                    }
                case let .declineFriendResponse(.failure(error)):
                    state.isLoading = false
                    print("친구 거절 실패: \(error)")
                    return .none
                case let .deleteFriend(id):
                    state.isLoading = true
                    return .run { send in
                        do {
                            let request = try await parkClient.deleteFriend(id)
                            await send(.deleteFriendResponse(.success(request)))
                        } catch {
                            await send(.deleteFriendResponse(.failure(error)))
                        }
                    }
                case let .deleteFriendResponse(.success(requests)):
                    state.isLoading = false
                    if !state.searchKeyword.isEmpty {
                        return .merge(
                            .send(.fetchFriendRequests),
                            .send(.fetchFriends),
                            .send(.searchFriends)
                        )
                    } else {
                        return .merge(
                            .send(.fetchFriendRequests),
                            .send(.fetchFriends)
                        )
                    }
                case let .deleteFriendResponse(.failure(error)):
                    state.isLoading = false
                    print("친구 삭제 실패: \(error)")
                    return .none
            }
        }
    }
}

extension String {
    /// 마지막 글자가 한글 완성형, 알파벳, 숫자 중 하나이면 true
    var endsWithSearchableCharacter: Bool {
        guard let last = self.last else { return false }
        guard let scalar = last.unicodeScalars.first else { return false }
        // 한글 완성형
        if scalar.value >= 0xAC00 && scalar.value <= 0xD7A3 {
            return true
        }
        // 알파벳 (대소문자)
        if ("a"..."z").contains(last) || ("A"..."Z").contains(last) {
            return true
        }
        // 숫자
        if ("0"..."9").contains(last) {
            return true
        }
        return false
    }
}

