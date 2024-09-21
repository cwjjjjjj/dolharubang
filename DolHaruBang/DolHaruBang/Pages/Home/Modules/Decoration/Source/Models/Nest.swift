//
//  Nest.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/11/24.
//

import ComposableArchitecture

// 얼굴형
enum Nest : String,Customizable {
    func performAction(with store: ComposableArchitecture.StoreOf<HomeFeature>) {
        store.send(.selectNest(self))
    }
    
    case cushion = "쿠션"
    case flowerpot = "꽃받침"
    case nest = "둥지"
    case woodstool = "나무"
    
    var description: String {
            return self.rawValue
        }
}
