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
        case clickDecoration
        case selectFace(Face)
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
            case .binding( _ ):
               return .none
            case let .selectFace(selectedFace) :
                state.selectedFace = selectedFace
                return .none
            case .clickAbility:
                state.ability.toggle()
                return .none
            case .clickMessage:
                state.sendMessage.toggle()
                state.message = ""
                return .none
            case .clickDecoration:
                state.decoration.toggle()
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
