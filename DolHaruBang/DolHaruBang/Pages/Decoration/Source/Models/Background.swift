//
//  Background.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/22/24.
//
import ComposableArchitecture

// 배경
enum Background : String,Customizable {
    
    func performAction(with store: ComposableArchitecture.StoreOf<HomeFeature>) {
        store.send(.selectBackground(self))
    }
    
    case July = "7월의 푸른 잔디"
    case April = "4월의 분홍빛 노을"
    case December = "12월의 하얀 잔디"
//    case December2 = "12월의 하얀 잔디2" // ipad
//    case Jan = "1월의 하얀 눈빛"
    
    var fileName: String {
        switch self {
        case .July:
            return "background"
        case .April:
            return "bg_lawn_iphone"
        case .December:
            return "bg_winter_iphone2"
//        case .December2:
//            return "bg_winter_ipad2"
        }
    }
    
    var description: String {
            return self.rawValue
        }
}
