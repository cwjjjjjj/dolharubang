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
        var selectedFace: Face = {
               if let selectedItem = CustomizeItem.mockFaceItem.first(where: { $0.isSelected }) {
                   return Face.allCases.first { $0.description == selectedItem.name } ?? .sparkle
               }
               return .sparkle
           }()
        
        var selectedFaceShape : FaceShape = .sosim
        
        @Shared(.inMemory("background")) var selectedBackground: Background = {
            if let selectedItem = CustomizeItem.mockFaceItem.first(where: { $0.isSelected }) {
            return Background.allCases.first { $0.description == selectedItem.name } ?? .December
        }
        return .December
    }()
    
        var selectedAccessory : Accessory = .black_glasses
        var selectedSign : Sign = .woodensign
        var selectedMail : Mail = .mailbox
        var selectedNest : Nest = .nest
        
        var needCapture : Bool = false
        
        var message: String = "" // 텍스트필드 메시지
        
        // Home Button state
        var ability: Bool = false // 잠재능력 버튼 온 오프
        var decoration: Bool = false // 꾸미기 탭 온 오프
        var enable : Bool = true // 버그 방지 Bool값
        
        // 3D 터치 state
        var profile: Bool = false // 돌 프로필 온 오프
        var sign : Bool = false // 펫말 온 오프
        var mail : Bool = false // 펫말 온 오프
        
        var isKeyboardVisible: Bool = false
        @Shared(.inMemory("dolprofile")) var captureDol: UIImage = UIImage() // 돌머리
        
        var shareButton : Bool = false
       
        // 배경, 돌굴, 돌굴형 따로따로 담는 변수 생성
        var customizeInfo : [CustomizeItem] = CustomizeItem.mockBackItem
        
        var backItems : [CustomizeItem] = CustomizeItem.mockBackItem
        var faceItems : [CustomizeItem] = CustomizeItem.mockBackItem
        var faceShapeItems : [CustomizeItem] = CustomizeItem.mockBackItem
        var nestItems : [CustomizeItem] = CustomizeItem.mockBackItem
        var accesoryItems : [CustomizeItem] = CustomizeItem.mockBackItem
    }
    
    enum Action: BindableAction {
        case clickAbility
        case clickMessage
        case openDecoration
        case closeDecoration
        case selectFace(Face)
        case selectFaceShape(FaceShape)
        case selectBackground(Background)
        case selectAccessory(Accessory)
        case selectNest(Nest)
        case selectSign(Sign)
        case selectMail(Mail)
        case clickProfile
        case updateToDol(String)
        case binding( BindingAction < State >)
        
        // 팝업 열고 닫기
        case openShare
        case closeShare
        case closeSign
        case closeProfile
        case closeMail
        
        // 커스터마이즈 통신
        case fetchFaceShape
        case fetchFace
        case fetchBackground
        
        case faceItemsResponse(Result<[CustomizeItem], Error>)
        case backItemsResponse(Result<[CustomizeItem], Error>)
        case customizeInfoResponse(Result<[CustomizeItem], Error>)
        
        
        case captureDol(UIImage)
    }
    
    @Dependency(\.homeClient) var homeClient
    
    var body : some ReducerOf <Self> {
        BindingReducer ()
        Reduce { state, action in
        
            switch action {
            case .binding(\.message):
               // 여기서 사용자 이름 관찰
               print ("toDolMessage" , state.message)
               return .none
            case .binding(\.selectedFace) :
                print("changed Face : ", state.selectedFace)
                return .none
             case .binding(\.selectedAccessory) :
                 print("changed Accessory : ", state.selectedAccessory)
                 return .none
            case .binding(\.decoration) :
                print("click deco : ", state.decoration)
                return .none
            case .binding( _ ):
               return .none
            case let .selectFace(selectedFace) :
                state.selectedFace = selectedFace
                state.needCapture = false
                return .none
            case let .selectFaceShape(selectedFaceShape) :
                state.selectedFaceShape = selectedFaceShape
                state.needCapture = false
                return .none
            case let .selectBackground(selectedBackground) :
                state.selectedBackground = selectedBackground
                return .none
            case let .selectAccessory(selectedAccessory) :
                state.selectedAccessory = selectedAccessory
                return .none
            case let .selectSign(selectedSign) :
                state.selectedSign = selectedSign
                return .none
            case let .selectMail(selectedMail) :
                state.selectedMail = selectedMail
                return .none
            case let .selectNest(selectedNest) :
                state.selectedNest = selectedNest
                return .none
            case .clickAbility:
                state.ability.toggle()
                return .none
            case .clickMessage:
                state.message = ""
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
                state.captureDol = image
                return .none
            case .openShare:
                state.shareButton = true
                return .none
            case .closeShare:
                state.shareButton = false
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
            
            // 상점에서 아이템들 갱신하는 로직
            case .fetchFaceShape:
                return .run { send in
                    do {
                        let customizeInfo = try await homeClient.faceShape()
                        await send(.customizeInfoResponse(.success(customizeInfo)))
                    } catch {
                        await send(.customizeInfoResponse(.failure(error)))
                    }
                }
            case .fetchFace:
                return .run { send in
                    do {
                        let customizeInfo = try await homeClient.face()
                        await send(.faceItemsResponse(.success(customizeInfo)))
                    } catch {
                        await send(.faceItemsResponse(.failure(error)))
                    }
                }
            case .fetchBackground:
                return .run { send in
                    do {
                        let customizeInfo = try await homeClient.background()
                        await send(.backItemsResponse(.success(customizeInfo)))
                    } catch {
                        await send(.backItemsResponse(.failure(error)))
                    }
                }
                
            case let .faceItemsResponse(.success(customizeInfo)):
                state.faceItems = customizeInfo
                return .none
                
            case let .faceItemsResponse(.failure(error)):
                return .none
                
            case let .backItemsResponse(.success(customizeInfo)):
                state.backItems = customizeInfo
                return .none
                
            case let .backItemsResponse(.failure(error)):
                return .none
                
            case let .customizeInfoResponse(.success(customizeInfo)):
                state.customizeInfo = customizeInfo
                return .none
                
            case let .customizeInfoResponse(.failure(error)):
                return .none
                
                
                
           
            }
        }
    }
}
