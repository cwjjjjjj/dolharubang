//
//  SettingFeature.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/21/24.
//

import ComposableArchitecture

@Reducer
struct SettingFeature {
    
    @Dependency(\.myPageClient) var myPageClient
    
    @ObservableState
    struct State : Equatable {
        @Shared(.inMemory("background")) var selectedBackground: Background = .December
        var withdrawAlertOn: Bool = false
    }
    
    enum Action : BindableAction {
        case goBack
        case withdrawAlertButtonTapped
        case withdraw
        case withdrawResponse(Result<Void, Error>)
        case binding( BindingAction < State >)
    }
    
    var body : some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                case .binding:
                    return .none
                case .goBack:
                    return .none
                case .withdrawAlertButtonTapped:
                    state.withdrawAlertOn = true
                    return .none
                case .withdraw:
                    // Alert에서 "탈퇴" 버튼을 눌렀을 때 실제 탈퇴 API 호출
                    state.withdrawAlertOn = false
                    return .run { send in
                        do {
                            try await myPageClient.withdraw()
                            await send(.withdrawResponse(.success(())))
                        } catch {
                            await send(.withdrawResponse(.failure(error)))
                        }
                    }
                    
                case let .withdrawResponse(.success):
                    TokenManager.shared.clearTokens()
                    return .none
                case let .withdrawResponse(.failure(error)):
                    print("회원 탈퇴 실패")
                    return .none
            }
        }
    }
}
