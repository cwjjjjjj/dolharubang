import ComposableArchitecture
import Foundation

struct Friend: Identifiable, Equatable, Decodable {
    let id: UUID
    let nickname: String
    let roomName: String
    let profileImageURL: URL?
}

struct FriendRequest: Identifiable, Equatable, Decodable {
    let id: Int
    let isSender: Bool // true이면 내가 보낸 요청 // false이면 내가 받은 요청
    let requesterNickname: String
    let receiverNickname: String
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
        var friendRequests: [FriendRequest] = []
        var isLoading: Bool = true
    }

    // 액션 정의
    enum Action: BindableAction {
        // 친구 목록 불러오기
        case fetchFriends
        case fetchFriendsResponse(Result<[Friend], Error>)
        // 친구 신청 내역 불러오기
        case fetchFriendRequests
        case fetchFriendRequestsResponse(Result<[FriendRequest], Error>)
        //
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
            }
        }
    }
}
