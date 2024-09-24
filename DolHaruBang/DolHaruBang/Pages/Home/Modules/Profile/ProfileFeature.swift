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
        var captureDol: UIImage = UIImage() // 돌머리
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
//            case .binding(\.message):
//               // 여기서 사용자 이름 관찰
//               print ("toDolMessage" , state.message)
//               return .none
            case .binding( _ ):
               return .none
                
            case .fetchProfile:
                return .run { send in
                    do {
                        let dolProfile = try await profileClient.fetchProfile()
                        await send(.fetchProfileResponse(.success(dolProfile)))
                    } catch {
                        await send(.fetchProfileResponse(.failure(error)))
                    }
                }
                
            case let .fetchProfileResponse(.success(dolProfile)):
                state.profile = dolProfile // 업적 목록 갱신
                return .none
                
            case let .fetchProfileResponse(.failure(error)):
                return .none
       
            }
        }
    }
}
