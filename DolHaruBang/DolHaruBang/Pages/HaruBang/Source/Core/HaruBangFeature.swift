import ComposableArchitecture
import Foundation

@Reducer
struct HaruBangFeature {
  
    @ObservableState
    struct State: Equatable {
        @Shared(.inMemory("background")) var selectedBackground: Background = .December
        var talkFeatureState: TalkFeature.State = TalkFeature.State()
    }

    // 액션 정의
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case talkFeatureAction(TalkFeature.Action)
    }

    // 의존성 추가
    @Dependency(\.talkClient) var talkClient

    // 리듀서 정의
    var body: some ReducerOf<Self> {
        BindingReducer()
        Scope(state: \.talkFeatureState, action: \.talkFeatureAction) {
            TalkFeature()
        }

        Reduce { state, action in
            switch action {
            case .binding:
                return .none
            case .talkFeatureAction:
                return .none
            }
        }
    }
}
