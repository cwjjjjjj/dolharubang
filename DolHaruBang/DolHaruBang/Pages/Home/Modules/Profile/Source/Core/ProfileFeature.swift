//
//  ProfileFeature.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/25/24.
//

import UIKit
import ComposableArchitecture

@Reducer
struct ProfileFeature {
    
    @ObservableState
    struct State: Equatable {
        @Shared(.inMemory("dolprofile")) var captureDol: UIImage = UIImage() // 돌머리
        var profile : ProfileInfo? = nil
    }
    
    enum Action: BindableAction {
        case fetchProfile
        case fetchProfileResponse(Result<ProfileInfo, Error>)
        case binding( BindingAction < State >)
    }
    
    @Dependency(\.profileClient) var profileClient
    
    var body : some ReducerOf <Self> {
        BindingReducer ()
        Reduce { state, action in
        
            switch action {
            case .binding( _ ):
               return .none
                
            case .fetchProfile:
                return .run { send in
                    do {
                        let dolProfile = try await profileClient.dolprofile()
                        await send(.fetchProfileResponse(.success(dolProfile)))
                    } catch {
                        await send(.fetchProfileResponse(.failure(error)))
                    }
                }
                
            case let .fetchProfileResponse(.success(dolProfile)):
                state.profile = dolProfile 
                return .none
                
            case let .fetchProfileResponse(.failure(error)):
                return .none
       
            }
        }
    }
}
