import ComposableArchitecture
import Foundation

struct History: Identifiable, Equatable {
    let id: UUID
    let email: String
    let nickname: String
    let profileImg: URL?
    let modifiedAt: Date
    let isRequest: Bool
}

@Reducer
struct ParkFeature {
  
    @ObservableState
    struct State: Equatable {
        @Shared(.inMemory("background")) var selectedBackground: Background = .December
        var selectedTap: Int = 0
        var showHistory: Bool = false
        var hasHistory: Bool = true
        var history: [History] = []
        var isLoading: Bool = true
        
        var doljanchiFeatureState : DoljanchiFeature.State = DoljanchiFeature.State()
        var friendListFeatureState : FriendListFeature.State = FriendListFeature.State()
        
    }

    // 액션 정의
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case doljanchiFeatureAction(DoljanchiFeature.Action)
        case friendListFeatureAction(FriendListFeature.Action)
        case tapDoljanchi
        case tapFriendList
        case toggleHistory
        case loadHistory
        case historyLoaded([History])
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
                    
                case .toggleHistory:
                    state.showHistory.toggle()
                    return .none
                
                case .loadHistory:
                    state.isLoading = true
                    return .run { send in
                        do {
                            var dummyHistories = [History]()
                            // 첫 번째 이미지만 API에서 가져옴
                            let firstImageURL = try await UnsplashAPI.getRandomImageURL()
                            
                            for i in 0..<6 {
                                let imageURL: URL?
                                if i == 0 {
                                    imageURL = firstImageURL
                                } else {
                                    imageURL = nil // 나머지는 빈 URL
                                }
                                
                                let histories = History(
                                    id: UUID(),
                                    email: ["abc@naver.com", "def@naver.com", "qwer@naver.com","asdf@naver.com","doldol@apple.com","haru123@naver.com",][i],
                                    nickname: ["해인", "우진", "희태", "상준", "성재", "영규"][i],
                                    profileImg: imageURL,
                                    modifiedAt: Date(),
                                    isRequest: [true, true, false, true, false, false][i]
                                )
                                dummyHistories.append(histories)
                            }
                            await send(.historyLoaded(dummyHistories))
                        } catch {
                            print("Unknown error: \(error)")
                            await send(.historyLoaded([]))
                        }
                    }
                    
                case let .historyLoaded(loadedHistory):
                    state.history = loadedHistory
                    state.isLoading = false
                    return .none
            }
        }
    }
}
