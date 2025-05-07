//
//  HomeEnviroment.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/4/24.
//
import Foundation
import ComposableArchitecture
import Alamofire



@DependencyClient
struct HomeClient {
    var sand : @Sendable () async throws -> Int
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
        sand : {
            let url = APIConstants.Endpoints.sand
            return try await fetch(url: url, model: Int.self, method: .get)
        }
        
    )
}


extension CustomizeItem {
   static let mockBackItem: [CustomizeItem] = [
       CustomizeItem(
           price: 50,
           imageUrl: "https://cdn.pixabay.com/photo/2023/11/30/10/52/bears-8421343_1280.jpg",
           itemId: 1,
           name: "7월의 푸른 잔디",
           isOwned: true,
           isSelected: false
       ),
       CustomizeItem(
           price: 53,
           imageUrl: "https://cdn.pixabay.com/photo/2023/11/30/10/52/bears-8421343_1280.jpg",
           itemId: 2,
           name: "4월의 분홍빛 노응",
           isOwned: true,
           isSelected: true
       ),
       CustomizeItem(
           price: 54,
           imageUrl: "https://cdn.pixabay.com/photo/2023/11/30/10/52/bears-8421343_1280.jpg",
           itemId: 2,
           name: "12월의 하얀 잔디",
           isOwned: true,
           isSelected: false
       )
   ]
   
   static let mockFaceItem: [CustomizeItem] = [
       CustomizeItem(
           price: 50,
           imageUrl: "face_sparkle_url",
           itemId: 3,
           name: Face.sparkle.description,
           isOwned: true,
           isSelected: false
       ),
       CustomizeItem(
           price: 50,
           imageUrl: "face_sosim_url",
           itemId: 6,
           name: Face.sosim.description,
           isOwned: false,
           isSelected: false
       ),
       CustomizeItem(
           price: 24,
           imageUrl: "face_saechim_url",
           itemId: 7,
           name: Face.saechim.description,
           isOwned: true,
           isSelected: false
       ),
       CustomizeItem(
           price: 15,
           imageUrl: "face_nareun_url",
           itemId: 7,
           name: Face.nareun.description,
           isOwned: false,
           isSelected: false
       ),
       CustomizeItem(
           price: 27,
           imageUrl: "face_meong_url",
           itemId: 46,
           name: Face.meong.description,
           isOwned: true,
           isSelected: false
       ),
       CustomizeItem(
           price: 84,
           imageUrl: "face_cupid_url",
           itemId: 46,
           name: Face.cupid.description,
           isOwned: false,
           isSelected: false
       ),
       CustomizeItem(
           price: 23,
           imageUrl: "face_bboombboom_url",
           itemId: 46,
           name: Face.bboombboom.description,
           isOwned: true,
           isSelected: false
       ),
       CustomizeItem(
           price: 12,
           imageUrl: "safasf",
           itemId: 6,
           name: Face.balral.description,
           isOwned: false,
           isSelected: true
       ),
       CustomizeItem(
           price: 50,
           imageUrl: "face_chic_url",
           itemId: 7,
           name: Face.chic.description,
           isOwned: true,
           isSelected: false
       )
   ]
}

private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  let formatter = DateFormatter()
  decoder.dateDecodingStrategy = .formatted(formatter)
  return decoder
}()
