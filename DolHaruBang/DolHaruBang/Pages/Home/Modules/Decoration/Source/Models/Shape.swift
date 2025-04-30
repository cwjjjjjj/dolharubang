//
//  Shape.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/22/24.
//

import ComposableArchitecture

// 얼굴형
enum FaceShape : String,Customizable {
    func performAction(with store: ComposableArchitecture.StoreOf<HomeFeature>) {
        store.send(.selectFaceShape(self))
    }
    
    case sparkle = "반짝이"
    case sosim = "소심이"
    case saechim = "새침이"
    case nareun = "나른이"
    case meong = "멍이"
    case cupid = "큐피드"
    case bboombboom = "뿜뿜이"
    case balral = "발랄이"
    case chic = "시크"
    
    var description: String {
            return self.rawValue
        }
}

extension FaceShape {
    var toDBTIModel: DBTIModel {
        switch self {
            case .sparkle:    return .banzzag
            case .sosim:      return .sosim
            case .saechim:    return .saechim
            case .nareun:     return .nareun
            case .meong:      return .meong
            case .cupid:      return .cupid
            case .bboombboom: return .bboombboom
            case .balral:     return .ballal
            case .chic:       return .chic
        }
    }
}
