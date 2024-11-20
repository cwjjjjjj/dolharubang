//
//  SignFeature.swift
//  DolHaruBang
//
//  Created by 양희태 on 11/20/24.
//

import UIKit
import ComposableArchitecture

@Reducer
struct SignFeature {
    
    @ObservableState
    struct State: Equatable {
        var signInfo : SignInfo? = nil
    }
    
    enum Action: BindableAction {
        case fetchSign
        case fetchSignResponse(Result<SignInfo, Error>)
        case binding( BindingAction < State >)
    }
    
    @Dependency(\.signClient) var signClient
    
    var body : some ReducerOf <Self> {
        BindingReducer ()
        Reduce { state, action in
        
            switch action {
            case .binding( _ ):
               return .none
                
            case .fetchSign:
                return .run { send in
                    do {
                        let signText = try await signClient.fetchSign()
                        await send(.fetchSignResponse(.success(signText)))
                    } catch {
                        await send(.fetchSignResponse(.failure(error)))
                    }
                }
                
            case let .fetchSignResponse(.success(signText)):
                state.signInfo = signText // 업적 목록 갱신
                return .none
                
            case let .fetchSignResponse(.failure(error)):
                return .none
       
            }
        }
    }
}
