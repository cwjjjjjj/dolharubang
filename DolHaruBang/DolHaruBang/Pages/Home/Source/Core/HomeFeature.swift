//
//  HomeReducer.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/4/24.
//

import ComposableArchitecture

@Reducer
struct HomeFeature {
    
    @ObservableState
    struct State: Equatable {
        var selectedFace : Face = .sparkle
        var selectedFaceShape : FaceShape = .meong
        var selectedBackground : Background = .April
        var message: String = ""
        var sendMessage : Bool = false
        var ability: Bool = false
        var decoration: Bool = false
        var profile: Bool = false
        var isKeyboardVisible: Bool = false
    }
    
    enum Action: BindableAction {
        case clickAbility
        case clickMessage
        case openDecoration
        case closeDecoration
        case selectFace(Face)
        case selectFaceShape(FaceShape)
        case selectBackground(Background)
        case clickProfile
        case updateToDol(String)
        case binding( BindingAction < State >)
    }
    
    var body : some ReducerOf <Self> {
        BindingReducer ()
        Reduce { state, action in
        
            switch action {
            case .binding(\.message):
               // 여기서 사용자 이름 관찰
               print ( "toDolMessage" , state.message)
               return .none
            case .binding(\.selectedFace) :
                print("changed Face : ", state.selectedFace)
                return .none
            case .binding(\.decoration) :
                print("click deco : ", state.decoration)
                return .none
            case .binding( _ ):
               return .none
            case let .selectFace(selectedFace) :
                state.selectedFace = selectedFace
                return .none
            case let .selectFaceShape(selectedFaceShape) :
                state.selectedFaceShape = selectedFaceShape
                return .none
            case let .selectBackground(selectedBackground) :
                state.selectedBackground = selectedBackground
                return .none
            case .clickAbility:
                state.ability.toggle()
                return .none
            case .clickMessage:
                state.sendMessage.toggle()
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
            }
        }
    }
}
