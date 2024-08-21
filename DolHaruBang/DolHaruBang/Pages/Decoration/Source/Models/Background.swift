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
    case Jan = "1월의 하얀 눈빛"
    
    var description: String {
            return self.rawValue
        }
}
