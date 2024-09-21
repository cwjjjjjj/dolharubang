import ComposableArchitecture
import Foundation

@Reducer
struct HaruBangFeature {
  
    @ObservableState
    struct State: Equatable {
        // 선택된 배경을 관리하는 @Shared 속성
        @Shared(.inMemory("background")) var selectedBackground: Background = .December
        
        // TalkFeature와 관련된 상태를 포함
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
                // TalkFeature 액션 처리 (필요 시 추가 로직 작성)
                return .none
            }
        }
    }
}
