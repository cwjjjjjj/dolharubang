//
//  Mail.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/2/24.
//

import ComposableArchitecture


// 표정
// MARK: 펫말 모델
enum Mail : String, Customizable {
    func performAction(with store: ComposableArchitecture.StoreOf<DecoFeature>) {
        store.send(.selectMail(self))
    }
    
    case none = "없음"
    case mailbox = "기본 우체통"
    
    var description: String {
            return self.rawValue
        }
}
