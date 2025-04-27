import Foundation
import UIKit
import ComposableArchitecture
import Alamofire

struct Jarang: Codable, Equatable, Sendable {
    let contestNo: Int
    var nickname: String
    var isPublic: Bool
    var profileImgUrl: String?
    var stoneName: String
    let createdAt: Date
    var modifiedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case contestNo = "contestNo"
        case nickname = "nickname"
        case isPublic = "isPublic"
        case profileImgUrl = "profileImgUrl"
        case stoneName = "stoneName"
        case createdAt = "createdAt"
        case modifiedAt = "modifiedAt"
    }
}

@DependencyClient
struct ParkClient {
    var fetchFeed: @Sendable (_ memberId: Int, _ lastContestId: Int?, _ contestFeedSortType: String?, _ size : Int?) async throws -> [Jarang]
//    var registJarang: @Sendable (_ jarang: Jarang) async throws -> NetworkMessage
}

extension DependencyValues {
    var parkClient: ParkClient {
        get { self[ParkClient.self] }
        set { self[ParkClient.self] = newValue }
    }
}

extension ParkClient: DependencyKey {
    static let liveValue = ParkClient(
        fetchFeed: { memberId, lastContestId, contestFeedSortType, size in
            var url = "/contests/feed/\(memberId)"
            var queryItems: [String] = []
            
            // nil이 아닌 값만 쿼리로 추가
            if let lastContestId = lastContestId {
                queryItems.append("lastContestId=\(lastContestId)")
            }
            if let contestFeedSortType = contestFeedSortType {
                queryItems.append("contestFeedSortType=\(contestFeedSortType)")
            }
            if let size = size {
                queryItems.append("size=\(size)")
            }
            
            if !queryItems.isEmpty {
                url += "?" + queryItems.joined(separator: "&")
            }
            
            return try await fetch(url: url, model: [Jarang].self, method: .get)
        }
//        ,
//        registJarang: { jarang in
//            let url = "/api/v1/contests"
//            let parameters: [String: Any] = [
//                "contentsNo": jarang.contentsNo,
//                "isPublic": jarang.isPublic,
//                "profileImgUrl": jarang.profileImgUrl ?? NSNull(),
//                "memberNickname": jarang.memberNickname,
//                "stoneName": jarang.stoneName,
//                "createdAt": ISO8601DateFormatter().string(from: jarang.createdAt),
//                "modifiedAt": jarang.modifiedAt.map { ISO8601DateFormatter().string(from: $0) } ?? NSNull()
//            ]
//            
//            let body = try JSONSerialization.data(withJSONObject: parameters)
//            return try await fetch(url: url, model: NetworkMessage.self, method: .post, body: body)
//        }
    )
}
