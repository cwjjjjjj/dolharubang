import ComposableArchitecture
import Foundation

struct BasicInfo : Hashable, Codable {
    let dolName : String
    let mailCount : Int
    let friendShip : Int
}

@Reducer
struct ParkFeature {
    @Dependency(\.parkClient) var parkClient
    
    
    @ObservableState
    struct State: Equatable {
        @Shared(.inMemory("background")) var selectedBackground: Background = .December
        var selectedTap: Int = 0
        var isLoading: Bool = true
        var showFriendRequests: Bool = false
        var doljanchiFeatureState : DoljanchiFeature.State = DoljanchiFeature.State()
        var friendListFeatureState : FriendListFeature.State = FriendListFeature.State()
        var isPublic: Bool = false
        var showImageErrorAlert = false
        var showDolNameErrorAlert = false
        var dolInfo: BasicInfo?
    }

    // 액션 정의
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case doljanchiFeatureAction(DoljanchiFeature.Action)
        case friendListFeatureAction(FriendListFeature.Action)
        case tapDoljanchi
        case tapFriendList
        case toggleFriendRequests
        case toggleIsPublic
        case toggleImageErrorAlert
        case toggleDolNameErrorAlert
        case fetchDolInfo
        case fetchDolInfoResponse(Result<BasicInfo, Error>)
    }

    // 리듀서 정의
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.doljanchiFeatureState, action: \.doljanchiFeatureAction) {
            DoljanchiFeature()
        }
        Scope(state: \.friendListFeatureState, action: \.friendListFeatureAction) {
            FriendListFeature()
        }

        Reduce { state, action in
            switch action {
                case .binding:
                    return .none
                    
                case .doljanchiFeatureAction:
                    return .none
                    
                case .friendListFeatureAction:
                    return .none
                    
                case .tapDoljanchi:
                    state.selectedTap = 0
                    return .none
                    
                case .tapFriendList:
                    state.selectedTap = 1
                    return .none
                    
                case .toggleFriendRequests:
                    state.showFriendRequests.toggle()
                    return .none
                
                case .toggleIsPublic:
                    state.isPublic.toggle()
                    return .none
                
                case .toggleImageErrorAlert:
                    state.showImageErrorAlert.toggle()
                    return .send(.doljanchiFeatureAction(.toggleJarangPopup))
//                    return .none
                
                case .toggleDolNameErrorAlert:
                    state.showDolNameErrorAlert.toggle()
                    return .send(.doljanchiFeatureAction(.toggleJarangPopup))
//                    return .none
                    
                case .fetchDolInfo:
                    state.isLoading = true
                    print("돌 정보 불러오기 시작")
                    return .run { send in
                        do {
                            let dolInfo = try await parkClient.fetchDolInfo()
                            await send(.fetchDolInfoResponse(.success(dolInfo)))
                        }
                    }
                case let .fetchDolInfoResponse(.success(dolInfo)):
                    state.isLoading = false
                    state.dolInfo = dolInfo
                    return .none
                    
                case let .fetchDolInfoResponse(.failure(error)):
                    print(error)
                    state.isLoading = false
//                    state.errorMessage = error.localizedDescription
                    return .none
            }
        }
    }
}
