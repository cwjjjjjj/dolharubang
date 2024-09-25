//
//  HomeEnviroment.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/4/24.
//
import Foundation
import ComposableArchitecture
import Alamofire


struct CustomizeItem: Hashable, Codable {
    let name: String
    let isOwned: Bool
    let isSelected: Bool
    let price : Int
}


@DependencyClient
struct HomeClient {
    var background: @Sendable () async throws -> [CustomizeItem]
    var face : @Sendable () async throws -> [CustomizeItem]
    var faceShape : @Sendable () async throws -> [CustomizeItem]
}

// 실제 통신 전 테스트
extension HomeClient: TestDependencyKey {
    static let previewValue = Self()

    static let testValue = Self()
}

extension DependencyValues {
    var homeClient: HomeClient {
        get { self[HomeClient.self] }
        set { self[HomeClient.self] = newValue }
    }
}

extension HomeClient: DependencyKey {
    static let liveValue = HomeClient(
        background: {
            
            let url = "http://211.49.26.51:8080/api/v1/pepperoni"
            
            
//            return try await fetch(url: url, model: Background.self, method: .get)
            
            return CustomizeItem.mockBackItem
        },
        face: {
            let url = "http://211.49.26.51:8080/api/v1/pepperoni"
            
            
//            return try await fetch(url: url, model: Background.self, method: .get)
            
            return CustomizeItem.mockFaceItem
        },
        faceShape: {
            let url = "http://211.49.26.51:8080/api/v1/pepperoni"
            
            
//            return try await fetch(url: url, model: Background.self, method: .get)
            
            return CustomizeItem.mockFaceItem
        }
    )
}


extension CustomizeItem {
    static let mockBackItem: [CustomizeItem] = [
        CustomizeItem(name: "7월의 푸른 잔디", isOwned: true, isSelected: false, price: 50),
        CustomizeItem(name: "4월의 분홍빛 노을", isOwned: false, isSelected: true, price: 53),
        CustomizeItem(name: "12월의 하얀 잔디", isOwned: true, isSelected: false, price: 54)
    ]
    
    static let mockFaceItem : [CustomizeItem] = [
        CustomizeItem(name: Face.sparkle.description, isOwned: true, isSelected: false, price: 50),
              CustomizeItem(name: Face.sosim.description, isOwned: false, isSelected: true, price: 50),
              CustomizeItem(name: Face.saechim.description, isOwned: true, isSelected: false, price: 24),
              CustomizeItem(name: Face.nareun.description, isOwned: false, isSelected: false, price: 15),
              CustomizeItem(name: Face.meong.description, isOwned: true, isSelected: false, price: 27),
              CustomizeItem(name: Face.cupid.description, isOwned: false, isSelected: false, price: 84),
              CustomizeItem(name: Face.bboombboom.description, isOwned: true, isSelected: false, price: 23),
              CustomizeItem(name: Face.balral.description, isOwned: false, isSelected: true, price: 12),
              CustomizeItem(name: Face.chic.description, isOwned: true, isSelected: false, price: 50)
         
    ]
}

private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  let formatter = DateFormatter()
  decoder.dateDecodingStrategy = .formatted(formatter)
  return decoder
}()
