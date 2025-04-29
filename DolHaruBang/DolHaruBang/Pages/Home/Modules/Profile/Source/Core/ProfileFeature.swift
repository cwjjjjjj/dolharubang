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
        var profile : ProfileInfo?
        var isLoading : Bool = false
        var selectedProfileEdit : Bool = false
        var dolName = ""
    }
    
    enum Action: BindableAction {
        case dolNameChanged(String)
        case fetchProfile
        case fetchProfileResponse(Result<ProfileInfo, Error>)
        case clickEditProfile
        case completeEditProfile
        case changeDolInfo(String)
        case binding( BindingAction < State >)
    }
    
    @Dependency(\.profileClient) var profileClient
    
    var body : some ReducerOf <Self> {
        BindingReducer ()
        Reduce { state, action in
        
            switch action {
            case .binding( _ ):
               return .none
                
            case let .dolNameChanged(name):
                state.dolName = name
              return .none
                
                // 프로필 편집 클릭
            case .clickEditProfile:
                state.selectedProfileEdit = true
                return .none
                
                // 편집완료 클릭
            case .completeEditProfile:
                state.selectedProfileEdit = false
                return .send(.changeDolInfo(state.dolName))
                
            case let .changeDolInfo(dolName):
                return .run { send in
                    do {
                        let dolinfo = try await profileClient.editdolname(dolName)
                        await send(.fetchProfileResponse(.success(dolinfo)))
                    } catch {
                        await send(.fetchProfileResponse(.failure(error)))
                    }
                }
                
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
                state.dolName = dolProfile.dolName
                return .none
                
            case let .fetchProfileResponse(.failure(error)):
                return .none
       
            }
        }
    }
}
