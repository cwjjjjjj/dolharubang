import ComposableArchitecture
import Foundation

let maxPage: Int = 4

@Reducer
struct DoljanchiFeature {
  
    @ObservableState
    struct State: Equatable {
        var currentPage: Int = 0
    }

    // 액션 정의
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case nextPage
        case previousPage
    }

    // 리듀서 정의
    var body: some ReducerOf<Self> {
        BindingReducer()

        Reduce { state, action in
            switch action {
                case .binding:
                    return .none
                case .nextPage:
                    if state.currentPage != maxPage - 1 {
                        state.currentPage += 1
                    }
                    return .none
                case .previousPage:
                    if state.currentPage != 0 {
                        state.currentPage -= 1
                    }
                    return .none
            }
        }
    }
}
