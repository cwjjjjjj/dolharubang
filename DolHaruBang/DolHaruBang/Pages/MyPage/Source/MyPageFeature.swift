//
//  MyPageFeature.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/31/24.
//

import ComposableArchitecture
import UIKit


@Reducer
struct MyPageFeature {
    
    
    @Dependency(\.myPageClient) var myPageClient
    
    
    @ObservableState
    struct State : Equatable {
        @Shared(.inMemory("background")) var selectedBackground: Background = .December
        
        var selectedProfileEdit : Bool = false
        var clickPlus : Bool = false
        var selectedImage: UIImage?
        var isLoading : Bool = false
        
        var userInfo : UserInfo? = UserInfo.mockUserInf
        var errorMessage: String? = nil
        var userName = ""
        var roomName = ""
        
    }
    
    enum Action : BindableAction{
        case trophyButtonTapped
        case settingButtonTapped
        case clickEditProfile
        case completeEditProfile
        case clickPlusButton
        case completeSelectPhoto
        case selectImage(UIImage)
        case binding( BindingAction < State >)
        case userNameChanged(String)
        case roomNameChanged(String)
        
        
        case fetchUserInfo
        case fetchUserInfoResponse(Result<UserInfo, Error>)
    }
    
    var body : some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .binding(\.clickPlus):
                return .none
                
                
            case .binding(\.userInfo):
                    return .none
                
            case .binding( _ ):
               return .none
                
                // 이미지 추가 버튼 클릭
            case .clickPlusButton:
                state.clickPlus = true
                return .none
                
                // 이미지 선택할당
            case let .selectImage(uiimage):
                state.selectedImage = uiimage
                return.none
                
            case .completeSelectPhoto:
                state.clickPlus = false
                return .none
                // 업적 이동
            case .trophyButtonTapped:
                return .none
                
                // 설정 이동
            case .settingButtonTapped:
                return .none
                
                // 프로필 편집 클릭
            case .clickEditProfile:
                state.selectedProfileEdit = true
                return .none
                
                // 편집완료 클릭
            case .completeEditProfile:
                state.selectedProfileEdit = false
                return .none
                
                
            case let .userNameChanged(name):
                state.userName = name
              return .none
                
            case let .roomNameChanged(name):
                state.roomName = name
              return .none
                
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
                state.userName = userinfo.userName
                state.roomName = userinfo.roomName
                return .none
                
            case let .fetchUserInfoResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
    
}
