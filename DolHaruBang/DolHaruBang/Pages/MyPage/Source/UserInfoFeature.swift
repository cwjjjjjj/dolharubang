//
//  UserInfoFeature.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/24/24.
//

import ComposableArchitecture

@Reducer
struct UserInfoFeature {
    
    
    @Dependency(\.myPageClient) var myPageClient
    
    
    @ObservableState
    struct State : Equatable {
        
        var isLoading : Bool = false
        var userInfo : UserInfo? = nil
        var errorMessage: String? = nil
        
    }
    
    enum Action {
        case fetchUserInfo
        case fetchUserInfoResponse(Result<UserInfo, Error>)
    }
    
    var body : some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                
            case .fetchUserInfo:
                return .run { send in
                    do {
                        let userinfo = try await myPageClient.fetchMypage()
                        await send(.fetchUserInfoResponse(.success(userinfo)))
                    } catch {
                        await send(.fetchUserInfoResponse(.failure(error)))
                    }
                }
            case let .fetchUserInfoResponse(.success(userinfo)):
                state.isLoading = false
                state.userInfo = userinfo // 업적 목록 갱신
                return .none
                
            case let .fetchUserInfoResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
    
}
