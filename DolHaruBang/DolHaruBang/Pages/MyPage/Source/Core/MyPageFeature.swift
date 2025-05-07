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
        var showImagePicker: Bool = false // ImagePicker 표시 상태
        var selectedImage: UIImage?
        var isLoading : Bool = false
        
        var userInfo : UserInfo?
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
        //        case completeSelectPhoto
        case selectImage(UIImage)
        case binding( BindingAction < State >)
        case userNameChanged(String)
        case roomNameChanged(String)
        
        case fetchUserInfo
        case changeUserInfo(String,String)
        case changeUserPhoto(String)
        case fetchUserInfoResponse(Result<UserInfo, Error>)
        
        
        
    }
    
    var body : some Reducer<State, Action> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding:
                return .none
                
                // 이미지 추가 버튼 클릭
            case .clickPlusButton:
                state.showImagePicker = true
                return .none
                
                // 이미지 선택할당
            case let .selectImage(uiimage):
                state.selectedImage = uiimage
                return.none
                
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
                
                // 편집 완료 클릭
            case .completeEditProfile:
                state.selectedProfileEdit = false
                // 수정 요청 전송
                return .send(.changeUserInfo(state.userName, state.roomName))
                
                
                // 변수 변경 감지
            case let .userNameChanged(name):
                state.userName = name
                return .none
                
            case let .roomNameChanged(name):
                state.roomName = name
                return .none
                
                // 처음 조회하기
            case .fetchUserInfo:
                return .run { send in
                    do {
                        let userinfo = try await myPageClient.fetchMypage()
                        await send(.fetchUserInfoResponse(.success(userinfo)))
                    } catch {
                        await send(.fetchUserInfoResponse(.failure(error)))
                    }
                }
                
                // 닉네임,방 수정하기
            case let .changeUserInfo(userName, roomName):
                return .run { send in
                    do {
                        let userinfo = try await myPageClient.updateUserInfo(userName, roomName)
                        await send(.fetchUserInfoResponse(.success(userinfo)))
                    } catch {
                        await send(.fetchUserInfoResponse(.failure(error)))
                    }
                }
                
            case let .changeUserPhoto(photo):
                return .run { send in
                    do {
                        let userinfo = try await myPageClient.updateUserPhoto(photo)
                        await send(.fetchUserInfoResponse(.success(userinfo)))
                    } catch {
                        await send(.fetchUserInfoResponse(.failure(error)))
                    }
                }
                
                
                // 조회,수정 결과 적용하기
            case let .fetchUserInfoResponse(.success(userinfo)):
                print("프로필 요청 성공")
                state.isLoading = false
                state.userInfo = userinfo
                state.userName = userinfo.userName
                state.roomName = userinfo.roomName
                return .none
                
            case let .fetchUserInfoResponse(.failure(error)):
                print("프로필 조회 ",error)
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
                
                
            }
        }
    }
    
}
