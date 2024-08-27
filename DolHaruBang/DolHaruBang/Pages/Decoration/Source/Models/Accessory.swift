//
//  Accessory.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/26/24.
//

import ComposableArchitecture

// Accessory
enum Accessory : String, Customizable {
    func performAction(with store: ComposableArchitecture.StoreOf<HomeFeature>) {
        store.send(.selectAccessory(self))
    }
    
    case none = "없음"
    case black_glasses = "검은 안경"
    
    var description: String {
            return self.rawValue
        }
}
