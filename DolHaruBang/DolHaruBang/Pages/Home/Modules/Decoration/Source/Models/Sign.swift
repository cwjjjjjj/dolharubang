//
//  Sign.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/2/24.
//

import ComposableArchitecture


// 표정
// MARK: 펫말 모델
enum Sign : String, Customizable {
    func performAction(with store: ComposableArchitecture.StoreOf<HomeFeature>) {
        store.send(.selectSign(self))
    }
    
    case none = "없음"
    case woodensign = "나무 우체통"
    
    var description: String {
            return self.rawValue
        }
}
