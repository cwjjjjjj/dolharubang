//
//  DecoFeature.swift
//  DolHaruBang
//
//  Created by 양희태 on 5/2/25.
//

import UIKit
import ComposableArchitecture

@Reducer
struct DecoFeature {
    
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
            return Background.allCases.first { $0.description == selectedItem.name } ?? .July
            }
            return .July
        }()
    
        var selectedAccessory : Accessory = .black_glasses
        var selectedSign : Sign = .woodensign
        var selectedMail : Mail = .mailbox
        var selectedNest : Nest = .nest
       
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
        case alert(PresentationAction<Alert>)
        enum Alert {
                case confirm
            }
        case selectFace(Face)
        case selectFaceShape(FaceShape)
        case selectBackground(Background)
        case selectAccessory(Accessory)
        case selectNest(Nest)
        case selectSign(Sign)
        case selectMail(Mail)
        case binding(BindingAction < State >)
        
        // 커스터마이즈 통신
        case fetchAll
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
        indirect case purchaseItem(Int64, refreshAction: Action)
        case purchaseItemResponse(Result<String, Error>)
        // 아이템 선택
        indirect case selectItem(Int64, refreshAction: Action)
        
        
    }
    
    @Dependency(\.decoClient) var decoClient
    
    var body : some ReducerOf <Self> {
        Reduce { state, action in
            
            switch action {
            case .binding( _ ):
                return .none
            case .binding(\.selectedFace) :
                print("changed Face : ", state.selectedFace)
                return .none
            case .binding(\.selectedAccessory) :
                print("changed Accessory : ", state.selectedAccessory)
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
                
            case .fetchAll:
                return .merge(
                    .send(.fetchFaceShape),
                    .send(.fetchFace),
                    .send(.fetchBackground),
                    .send(.fetchAccessory),
                    .send(.fetchNest)
                )
    
                
                // MARK: 얼굴형 아이템 조회
            case .fetchFaceShape:
                return .run { send in
                    do {
                        let customizeInfo = try await decoClient.faceShape()
                        await send(.faceShapeItemsResponse(.success(customizeInfo)))
                    } catch {
                        await send(.faceShapeItemsResponse(.failure(error)))
                    }
                }
                
            case let .faceShapeItemsResponse(.success(customizeInfo)):
//                print("얼굴형아이템 ", customizeInfo)
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
                        let customizeInfo = try await decoClient.face()
                        await send(.faceItemsResponse(.success(customizeInfo)))
                    } catch {
                        await send(.faceItemsResponse(.failure(error)))
                    }
                }
                
            case let .faceItemsResponse(.success(customizeInfo)):
                state.faceItems = customizeInfo
                
//                    print("얼굴아이템 ", customizeInfo)
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
                        let customizeInfo = try await decoClient.background()
                        await send(.backItemsResponse(.success(customizeInfo)))
                    } catch {
                        await send(.backItemsResponse(.failure(error)))
                    }
                }
                
            case let .backItemsResponse(.success(customizeInfo)):
                
//                    print("배경아이템 ", customizeInfo)
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
                        let customizeInfo = try await decoClient.accessory()
                        await send(.accessoryItemsResponse(.success(customizeInfo)))
                    } catch {
                        await send(.accessoryItemsResponse(.failure(error)))
                    }
                }
                
            case let .accessoryItemsResponse(.success(customizeInfo)):
                
//                    print("악세서리 아이템 ", customizeInfo)
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
                        let customizeInfo = try await decoClient.nest()
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
                        print("둥지 선택",nest)
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
                        let updatedItems = try await decoClient.purchaseItem(itemId)
                        
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
                print("구매성공")
                state.isLoading = false
//                state.alert = AlertState {
//                        TextState("구매 완료")
//                    } actions: {
//                        ButtonState(role: .cancel, action: .confirm) {
//                            TextState("확인")
//                        }
//                    }
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
                        let updatedItems = try await decoClient.selectItem(itemId)
                        
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
