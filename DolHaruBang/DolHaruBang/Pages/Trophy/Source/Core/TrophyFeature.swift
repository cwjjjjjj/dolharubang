//
//  TrophyFeature.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/21/24.
//

import ComposableArchitecture

@Reducer
struct TrophyFeature {
    
    @ObservableState
    struct State : Equatable {
        @Shared(.inMemory("background")) var selectedBackground: Background = .December
        
        var trophyListFeatureState: TrophyListFeature.State = TrophyListFeature.State()
       
    }
    
    enum Action {
        case goBack
        
        case trophyListFeatureAction(TrophyListFeature.Action)
    }
    
    
    
    var body: some ReducerOf<Self> {
        
        Scope(state: \.trophyListFeatureState, action: \.trophyListFeatureAction) {
            TrophyListFeature()
        }
        
        Reduce { state, action in
            switch action {
                
            case .goBack:
                return .none
           
            case .trophyListFeatureAction:
                return .none
            }
        }
        
    }
}
