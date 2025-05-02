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
        
//        var needCapture : Bool = false
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
        
        var isKeyboardVisible: Bool = false
        @Shared(.inMemory("dolprofile")) var captureDol: UIImage = UIImage() // 돌머리
        
       
        // 배경, 돌굴, 돌굴형 따로따로 담는 변수 생성
        var backItems : [CustomizeItem] = []
        var faceItems : [CustomizeItem] = []
        var faceShapeItems : [CustomizeItem] = []
        var nestItems : [CustomizeItem] = []
        var accessoryItems : [CustomizeItem] = []
        
        var isLoading : Bool = false
        
        @Presents var alert: AlertState<Action.Alert>?
        
    }
    
    enum Action: BindableAction {
        // 하위 Feature 선언
        case profileStore(ProfileFeature.Action)
        case mailStore(MailFeature.Action)
        case signStore(SignFeature.Action)
        
        case alert(PresentationAction<Alert>)
        enum Alert {
                case confirm
            }
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
        case openSand
        case closeSand
        case openShare
        case closeShare
        case closeSign
        case closeProfile
        case closeMail
        
        // 커스터마이즈 통신
        case fetchFaceShape
        case fetchFace
        case fetchBackground
        case fetchAccessory
        case fetchNest
        
        case faceShapeItemsResponse(Result<[CustomizeItem], Error>)
        case faceItemsResponse(Result<[CustomizeItem], Error>)
        case backItemsResponse(Result<[CustomizeItem], Error>)
        case accessoryItemsResponse(Result<[CustomizeItem], Error>)
        case nestItemsResponse(Result<[CustomizeItem], Error>)
        
        // 아이템 구매
        indirect case purchaseItem(String, refreshAction: Action)
        case purchaseItemResponse(Result<String, Error>)
        // 아이템 선택
        indirect case selectItem(String, refreshAction: Action)
        
        // 기본정보
        case fetchSand
        case sandLoaded(Result<Int, Error>)
        
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
        
        Reduce { state, action in
            
            switch action {
            // 하위 FeatureAction
            case .profileStore:
                return .none
            case .mailStore:
                return .none
            case .signStore:
                return .none
                
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
//                state.needCapture = false
                return .none
            case let .selectFaceShape(selectedFaceShape) :
                state.selectedFaceShape = selectedFaceShape
//                state.needCapture = false
                return .none
            case let .selectBackground(selectedBackground) :
                MainActor.assumeIsolated {
                    state.$selectedBackground.withLock { shared in
                        shared = selectedBackground
                    }
                }
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
                
                // MARK: 얼굴형 아이템 조회
            case .fetchFaceShape:
                return .run { send in
                    do {
                        let customizeInfo = try await homeClient.faceShape()
                        await send(.faceShapeItemsResponse(.success(customizeInfo)))
                    } catch {
                        await send(.faceShapeItemsResponse(.failure(error)))
                    }
                }
                
            case let .faceShapeItemsResponse(.success(customizeInfo)):
                state.faceShapeItems = customizeInfo
                if let selectedItem = customizeInfo.first(where: { $0.isSelected }) {
                    if let faceShape = FaceShape.allCases.first(where: { $0.description == selectedItem.name }) {
                        state.selectedFaceShape = faceShape
                    }
                }
                return .none
                
            case let .faceShapeItemsResponse(.failure(error)):
                return .none
                
                // MARK: 얼굴 표정 아이템 조회
            case .fetchFace:
                return .run { send in
                    do {
                        let customizeInfo = try await homeClient.face()
                        await send(.faceItemsResponse(.success(customizeInfo)))
                    } catch {
                        await send(.faceItemsResponse(.failure(error)))
                    }
                }
                
            case let .faceItemsResponse(.success(customizeInfo)):
                state.faceItems = customizeInfo
                if let selectedItem = customizeInfo.first(where: { $0.isSelected }) {
                    if let face = Face.allCases.first(where: { $0.description == selectedItem.name }) {
                        state.selectedFace = face
                    }
                }
                return .none
                
            case let .faceItemsResponse(.failure(error)):
                print("face error ",error)
                return .none
                
                // MARK: 백그라운드 아이템 조회
            case .fetchBackground:
                return .run { send in
                    do {
                        let customizeInfo = try await homeClient.background()
                        await send(.backItemsResponse(.success(customizeInfo)))
                    } catch {
                        await send(.backItemsResponse(.failure(error)))
                    }
                }
                
            case let .backItemsResponse(.success(customizeInfo)):
                state.backItems = customizeInfo         // 선택된 배경 업데이트
                if let selectedItem = customizeInfo.first(where: { $0.isSelected }) {
                    if let background = Background.allCases.first(where: { $0.description == selectedItem.name }) {
                        MainActor.assumeIsolated {
                            state.$selectedBackground.withLock { shared in
                                shared = background
                            }
                        }
                    }
                }
                
                return .none
                
            case let .backItemsResponse(.failure(error)):
                print("backItem error ",error)
                return .none
                
                // MARK: 액세서리 아이템 조회
            case .fetchAccessory:
                return .run { send in
                    do {
                        let customizeInfo = try await homeClient.accessory()
                        await send(.accessoryItemsResponse(.success(customizeInfo)))
                    } catch {
                        await send(.accessoryItemsResponse(.failure(error)))
                    }
                }
                
            case let .accessoryItemsResponse(.success(customizeInfo)):
                state.accessoryItems = customizeInfo
                if let selectedItem = customizeInfo.first(where: { $0.isSelected }) {
                    if let accessory = Accessory.allCases.first(where: { $0.description == selectedItem.name }) {
                        state.selectedAccessory = accessory
                    }
                }
                return .none
                
            case let .accessoryItemsResponse(.failure(error)):
                print("accessory error ",error)
                return .none
                
                // MARK: 둥지 아이템 조회
            case .fetchNest:
                return .run { send in
                    do {
                        let customizeInfo = try await homeClient.nest()
                        await send(.nestItemsResponse(.success(customizeInfo)))
                    } catch {
                        await send(.nestItemsResponse(.failure(error)))
                    }
                }
                
            case let .nestItemsResponse(.success(customizeInfo)):
                state.nestItems = customizeInfo
                if let selectedItem = customizeInfo.first(where: { $0.isSelected }) {
                    if let nest = Nest.allCases.first(where: { $0.description == selectedItem.name }) {
                        state.selectedNest = nest
                    }
                }
                return .none
                
            case let .nestItemsResponse(.failure(error)):
                print("nest error ",error)
                return .none
                
                
                
                
                // MARK: 아이템 구매
            case let .purchaseItem(itemId, refreshAction):
                return .run { [itemId] send in
                    do {
                        // 아이템 구매 API 호출 - 여기서는 타입 정보 필요 없음
                        let updatedItems = try await homeClient.purchaseItem(itemId)
                        
                        await send(.fetchSand)
                        
                        switch refreshAction {
                        case .fetchFace:
                            await send(.faceItemsResponse(.success(updatedItems)))
                        case .fetchFaceShape:
                            await send(.faceShapeItemsResponse(.success(updatedItems)))
                        case .fetchBackground:
                            await send(.backItemsResponse(.success(updatedItems)))
                        case .fetchAccessory:
                            await send(.accessoryItemsResponse(.success(updatedItems)))
                        case .fetchNest:
                            await send(.nestItemsResponse(.success(updatedItems)))
                        default:
                            await send(refreshAction) // 기본 동작 유지
                        }
                        await send(.purchaseItemResponse(.success("")))
                    } catch {
                        await send(.purchaseItemResponse(.failure(error)))
                    }
                }
                
            case let .purchaseItemResponse(.success(text)):
                state.isLoading = false
                state.alert = AlertState {
                        TextState("구매 완료")
                    } actions: {
                        ButtonState(role: .cancel, action: .confirm) {
                            TextState("확인")
                        }
                    }
                return .none
                
            case let .purchaseItemResponse(.failure(error)):
                print("purchase error ",error)
                state.isLoading = false
                state.alert = AlertState {
                        TextState("모래알이 부족합니다.")
                    } actions: {
                        ButtonState(role: .cancel, action: .confirm) {
                            TextState("확인")
                        }
                    }
                return .none
            
            case .alert(.presented(.confirm)):
                state.alert = nil
                return .none
            
            case .alert(.dismiss):
                return .none
                
                // MARK: 아이템 선택
            case let .selectItem(itemId, refreshAction):
                return .run { [itemId] send in
                    do {
                        let updatedItems = try await homeClient.selectItem(itemId)
                        
                        //                         구매 성공 후 해당 타입의 아이템 리스트를 새로고침하는 액션 전송
                        switch refreshAction {
                        case .fetchFace:
                            await send(.faceItemsResponse(.success(updatedItems)))
                        case .fetchFaceShape:
                            await send(.faceShapeItemsResponse(.success(updatedItems)))
                        case .fetchBackground:
                            await send(.backItemsResponse(.success(updatedItems)))
                        case .fetchAccessory:
                            await send(.accessoryItemsResponse(.success(updatedItems)))
                        case .fetchNest:
                            await send(.nestItemsResponse(.success(updatedItems)))
                        default:
                            await send(refreshAction) // 기본 동작 유지
                        }
                    } catch {
                        print("옷입기실패")
                    }
                }
                
               
                
            }
        }
    }
}
