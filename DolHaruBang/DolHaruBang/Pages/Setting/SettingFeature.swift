//
//  SettingFeature.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/21/24.
//

import ComposableArchitecture

@Reducer
struct SettingFeature {
    
    @ObservableState
    struct State : Equatable {
        @Shared(.inMemory("background")) var selectedBackground: Background = .December
    }
    
    enum Action {
        case goBack
    }
    
    var body : some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
            case .goBack:
              return .none
            }
        }
    }
    
}
