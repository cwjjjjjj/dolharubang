//
//  SignFeature.swift
//  DolHaruBang
//
//  Created by 양희태 on 11/20/24.
//

import UIKit
import SwiftUI
import ComposableArchitecture

@Reducer
struct SignFeature {
    
    @ObservableState
    struct State: Equatable {
        var signInfo : String = ""
    }
    
    enum Action: BindableAction {
        case fetchSign(String)
        case fetchSignResponse(Result<SignInfo, Error>)
        case applySign(String)
        case fetchfistSign
        
        case binding( BindingAction < State >)
    }
    
    @Dependency(\.signClient) var signClient
    
    var body : some ReducerOf <Self> {
        BindingReducer ()
        Reduce { state, action in
        
            switch action {
            case .binding( _ ):
               return .none
                
            case let .fetchSign(text):
                state.signInfo = text
                return .none
                
            case let .applySign(text):
                return .run { send in
                    do {
                        let signText = try await signClient.applySign(text)
                        await send(.fetchSignResponse(.success(signText)))
                    } catch {
                        await send(.fetchSignResponse(.failure(error)))
                    }
                }
                
                // MARK: 팻말
            case .fetchfistSign:
                return .run { send in
                    do {
                        let signText = try await signClient.fetchSign()
                        await send(.fetchSignResponse(.success(signText)))
                    } catch {
                        await send(.fetchSignResponse(.failure(error)))
                    }
                }
                
            case let .fetchSignResponse(.success(signText)):
                state.signInfo = signText.signText
                return .none
                
            case let .fetchSignResponse(.failure(error)):
                print("Sign \(error)")
                return .none
                
            
       
            }
        }
    }
}
