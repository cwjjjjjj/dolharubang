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
    let price : Int
    let imageUrl : String
    let itemId : String
    let name: String
    let isOwned: Bool
    let isSelected: Bool
}


@DependencyClient
struct HomeClient {
    var background: @Sendable () async throws -> [CustomizeItem]
    var face : @Sendable () async throws -> [CustomizeItem]
    var faceShape : @Sendable () async throws -> [CustomizeItem]
    var nest: @Sendable () async throws -> [CustomizeItem]
    var accessory : @Sendable () async throws -> [CustomizeItem]
    var purchaseItem : @Sendable (String) async throws -> [CustomizeItem]
    var selectItem : @Sendable (String) async throws -> [CustomizeItem]
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
        background: {
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/memberItems/customs/15/BACKGROUND"
                do {
                    return try await fetch(url: url, model: [CustomizeItem].self, method: .get)
                } catch {
                    print("Background items fetch error:", error)
                    return CustomizeItem.mockBackItem
                }
        },
        face: {
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/memberItems/customs/15/FACE"
                do {
                    return try await fetch(url: url, model: [CustomizeItem].self, method: .get)
                } catch {
                    print("Face items fetch error:", error)
                    return CustomizeItem.mockBackItem
                }
        },
        faceShape: {
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/memberItems/customs/15/SHAPE"
                do {
                    return try await fetch(url: url, model: [CustomizeItem].self, method: .get)
                } catch {
                    print("faceShape items fetch error:", error)
                    return CustomizeItem.mockBackItem
                }
        },
        nest: {
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/memberItems/customs/15/NEST"
                do {
                    return try await fetch(url: url, model: [CustomizeItem].self, method: .get)
                } catch {
                    print("Nest items fetch error:", error)
                    return CustomizeItem.mockBackItem
                }
        },
        accessory: {
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/memberItems/customs/15/ACCSESORY"
                do {
                    return try await fetch(url: url, model: [CustomizeItem].self, method: .get)
                } catch {
                    print("accessory items fetch error:", error)
                    return CustomizeItem.mockBackItem
                }
        },
        purchaseItem : { itemId in
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/memberItems/buy/15?itemId=\(itemId)"
                do {
                        return try await fetch(url: url, model: [CustomizeItem].self, method: .post)
                    } catch {
                        print("아이템 구매 실패:", error)
                        return CustomizeItem.mockBackItem
                    }
        },
        selectItem : { itemId in
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/memberItems/wear/15?itemId=\(itemId)"
                print("입는 아이템 아이디 \(itemId)")
                do {
                        return try await fetch(url: url, model: [CustomizeItem].self, method: .post)
                    } catch {
                        print("아이템 입기 실패:", error)
                        return CustomizeItem.mockBackItem
                    }
        },
        sand : {
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/members/sands/15"
            do {
                return try await fetch(url: url, model: Int.self, method: .get)
                } catch {
                    print("모래불러오기 실패:", error)
                    return 5
                }
        }
        
    )
}


extension CustomizeItem {
   static let mockBackItem: [CustomizeItem] = [
       CustomizeItem(
           price: 50,
           imageUrl: "https://cdn.pixabay.com/photo/2023/11/30/10/52/bears-8421343_1280.jpg",
           itemId: "67bb2c0605072c0c7c37a3f1",
           name: "7월의 푸른 잔디",
           isOwned: true,
           isSelected: false
       ),
       CustomizeItem(
           price: 53,
           imageUrl: "https://cdn.pixabay.com/photo/2023/11/30/10/52/bears-8421343_1280.jpg",
           itemId: "67bb2c0605072c0c7c37a3f2",
           name: "4월의 분홍빛 노을",
           isOwned: true,
           isSelected: true
       ),
       CustomizeItem(
           price: 54,
           imageUrl: "https://cdn.pixabay.com/photo/2023/11/30/10/52/bears-8421343_1280.jpg",
           itemId: "67bb2c0605072c0c7c37a3f3",
           name: "12월의 하얀 잔디",
           isOwned: true,
           isSelected: false
       )
   ]
   
   static let mockFaceItem: [CustomizeItem] = [
       CustomizeItem(
           price: 50,
           imageUrl: "face_sparkle_url",
           itemId: "face_sparkle_id",
           name: Face.sparkle.description,
           isOwned: true,
           isSelected: false
       ),
       CustomizeItem(
           price: 50,
           imageUrl: "face_sosim_url",
           itemId: "face_sosim_id",
           name: Face.sosim.description,
           isOwned: false,
           isSelected: false
       ),
       CustomizeItem(
           price: 24,
           imageUrl: "face_saechim_url",
           itemId: "face_saechim_id",
           name: Face.saechim.description,
           isOwned: true,
           isSelected: false
       ),
       CustomizeItem(
           price: 15,
           imageUrl: "face_nareun_url",
           itemId: "face_nareun_id",
           name: Face.nareun.description,
           isOwned: false,
           isSelected: false
       ),
       CustomizeItem(
           price: 27,
           imageUrl: "face_meong_url",
           itemId: "face_meong_id",
           name: Face.meong.description,
           isOwned: true,
           isSelected: false
       ),
       CustomizeItem(
           price: 84,
           imageUrl: "face_cupid_url",
           itemId: "face_cupid_id",
           name: Face.cupid.description,
           isOwned: false,
           isSelected: false
       ),
       CustomizeItem(
           price: 23,
           imageUrl: "face_bboombboom_url",
           itemId: "face_bboombboom_id",
           name: Face.bboombboom.description,
           isOwned: true,
           isSelected: false
       ),
       CustomizeItem(
           price: 12,
           imageUrl: "face_balral_url",
           itemId: "face_balral_id",
           name: Face.balral.description,
           isOwned: false,
           isSelected: true
       ),
       CustomizeItem(
           price: 50,
           imageUrl: "face_chic_url",
           itemId: "face_chic_id",
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
