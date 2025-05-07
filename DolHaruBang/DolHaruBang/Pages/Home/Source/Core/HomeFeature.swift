//
//  HomeReducer.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/4/24.
//

import UIKit
import ComposableArchitecture

@Reducer
struct HomeFeature {
    
    @ObservableState
    struct State: Equatable {
        
        var profileStore = ProfileFeature.State()
        var mailStore = MailFeature.State()
        var signStore = SignFeature.State()
        var decoStore = DecoFeature.State()
        
        var sand : Int = 0
        var message: String = "" // 텍스트필드 메시지
        
        // Home Button state
        var ability: Bool = false // 잠재능력 버튼 온 오프
        var decoration: Bool = false // 꾸미기 탭 온 오프
        var enable : Bool = true // 버그 방지 Bool값
        var shareButton : Bool = false
        var sandButton : Bool = false
        
        // 3D 터치 state
        var profile: Bool = false // 돌 프로필 온 오프
        var sign : Bool = false // 펫말 온 오프
        var mail : Bool = false // 펫말 온 오프
        
        var isSuccess : Bool = false
        
        var isKeyboardVisible: Bool = false
        @Shared(.inMemory("dolprofile")) var captureDol: UIImage = UIImage() // 돌머리
        
        var isLoading : Bool = false
        
        @Presents var alert: AlertState<Action.Alert>?
        
    }
    
    enum Action: BindableAction {
        // 하위 Feature 선언
        case profileStore(ProfileFeature.Action)
        case mailStore(MailFeature.Action)
        case signStore(SignFeature.Action)
        case decoStore(DecoFeature.Action)
        case alert(PresentationAction<Alert>)
        
        enum Alert {
                case confirm
            }
        case clickAbility
        case clickMessage
        case openDecoration
        case closeDecoration
        case clickProfile
        case updateToDol(String)
        case binding( BindingAction < State >)
        
        // 팝업 열고 닫기
        case openSand
        case closeSand
        case openShare
        case closeShare
        case closeSign
        case closeProfile
        case closeMail
        
        // 잠재능력
        case clickRollDol
        
        // API통신
        case fetchSand
        case sandLoaded(Result<Int, Error>)
        case fetchDeco
        
        // 돌 프로필
        case captureDol(UIImage)
        
    }
    
    @Dependency(\.homeClient) var homeClient
    
    var body : some ReducerOf <Self> {
        BindingReducer ()
        
        Scope(state: \.profileStore, action: /Action.profileStore) {
                   ProfileFeature()
               }
        Scope(state: \.mailStore, action: /Action.mailStore) {
                   MailFeature()
               }
        Scope(state: \.signStore, action: /Action.signStore) {
                   SignFeature()
               }
        Scope(state: \.decoStore, action: /Action.decoStore) {
                   DecoFeature()
               }
        
        Reduce { state, action in
            
            switch action {
            case .binding( _ ):
                return .none
            // 하위 FeatureAction
            case .profileStore:
                return .none
            case .mailStore:
                return .none
            case .signStore:
                return .none
                
            case .decoStore(.purchaseItemResponse):
                return .run { send in
                    await send(.fetchSand)
                }
                
            case .decoStore:
                return .none
            
            case .fetchDeco:
                return .send(.decoStore(.fetchAll))
            
                
            case .binding(\.message):
                // 여기서 사용자 이름 관찰
                print ("toDolMessage" , state.message)
                return .none
            case .binding(\.decoration) :
                print("click deco : ", state.decoration)
                return .none
            case .binding( _ ):
                return .none
            
            case .clickAbility:
                state.ability.toggle()
                return .none
            case .clickMessage:
                state.message = ""
                return .none
                
            case .fetchSand:
                return .run { send in
                    do {
                        let sandAmount = try await homeClient.sand()
                        await send(.sandLoaded(.success(sandAmount)))
                    } catch {
                        await send(.sandLoaded(.failure(error)))
                    }
                }
                
            case let .sandLoaded(.success(sandAmount)):
                state.sand = sandAmount
                return .none
                
            case let .sandLoaded(.failure(error)):
                return .none
                
            case .openDecoration:
                state.decoration = true
                return .none
            case .closeDecoration:
                state.decoration = false
                return .none
            case .clickProfile:
                state.profile.toggle()
                return .none
            case let .updateToDol(message):
                state.message = message
                return .none
                
            case let .captureDol(image):
                MainActor.assumeIsolated {
                    state.$captureDol.withLock { shared in
                        shared = image
                    }
                }
                return .none
            case .openShare:
                state.shareButton = true
                return .none
            case .closeShare:
                state.shareButton = false
                return .none
                
            case .openSand:
                state.sandButton.toggle()
                return .none
            case .closeSand:
                state.sandButton = false
                return .none
                
                // 펫말 팝업 닫기
            case .closeSign:
                state.sign = false
                return .none
                
                // 프로필 팝업 닫기
            case .closeProfile:
                state.profile = false
                return .none
                
                // 우편함 팝업 닫기
            case .closeMail:
                state.mail = false
                return .none
                
                
            case .alert(.presented(.confirm)):
                state.alert = nil
                return .none
            
            case .alert(.dismiss):
                return .none
                
            case .clickRollDol:
                state.isSuccess.toggle()
                return .none
            }
        }
    }
}
