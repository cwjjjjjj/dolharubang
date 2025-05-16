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
    // 돌 잔치 관련
    var checkCanRegistJarang: @Sendable (_ stoneId: Int) async throws -> Bool
    var fetchFeed: @Sendable (_ lastContestId: Int?, _ contestFeedSortType: String?, _ size : Int?) async throws -> [Jarang]
    var fetchDolInfo: @Sendable () async throws -> BasicInfo
    var registJarang: @Sendable (_ isPublic: Bool, _ profileImgUrl: String, _ stoneName: String, _ stoneId: Int) async throws -> Void
    // 친구 관련
    var fetchFriends: @Sendable() async throws -> [Friend]
    var fetchFriendRequests: @Sendable() async throws -> [Friend]
    var searchFriends: @Sendable(_ keyword: String) async throws -> [MemberInfo]
    // 친구 요청 관련
    var requestFriend: @Sendable(_ id: Int) async throws -> Friend
    var cancelFriendRequest: @Sendable(_ id: Int) async throws -> Friend
    var acceptFriend: @Sendable(_ id: Int) async throws -> Friend
    var declineFriend: @Sendable(_ id: Int) async throws -> Friend
    var deleteFriend: @Sendable(_ id: Int) async throws -> Friend
}

extension DependencyValues {
    var parkClient: ParkClient {
        get { self[ParkClient.self] }
        set { self[ParkClient.self] = newValue }
    }
}

extension ParkClient: DependencyKey {
    static let liveValue = ParkClient(
        
        checkCanRegistJarang: { stoneId in
            var url = APIConstants.Endpoints.canRegist
            let params = ["stoneId": String(stoneId)]
            let body = try JSONSerialization.data(withJSONObject: params, options: [])
            return try await fetch(
                url: url,
                model: Bool.self,
                method: .get,
                queryParameters: params
            )
        }
        ,
        
        fetchFeed: { lastContestId, contestFeedSortType, size in
            var url = APIConstants.Endpoints.feed
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
        ,
        
        fetchDolInfo: {
            var url = APIConstants.Endpoints.basic
            return try await fetch(url: url, model: BasicInfo.self, method: .get)
        }
        ,
        
        registJarang: { isPublic, imageBase64, stoneName, stoneId in
            let url = APIConstants.Endpoints.contest

            // 1. data 객체 준비
            let dataDict: [String: Any] = [
                "isPublic": isPublic,
                "stoneName": stoneName,
                "stoneId": stoneId
            ]

            // 2. 이미지 데이터 변환
            let imageData = Data(base64Encoded: imageBase64)

            // 3. multipart body 생성
            let (body, boundary) = makeMultipartBody(
                dataDict: dataDict,
                imageData: imageData
            )

            let headers: HTTPHeaders = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]

            try await fetch(
                url: url,
                model: EmptyResponse.self,
                method: .post,
                headers: headers,
                body: body
            )
        }
        ,
        
        fetchFriends: {
            let url = APIConstants.Endpoints.friends
            return try await fetch(url: url, model: [Friend].self, method: .get)
        }
        ,
        
        fetchFriendRequests: {
            let url = APIConstants.Endpoints.friendsRequest
            return try await fetch(url: url, model: [Friend].self, method: .get)
        }
        ,
        
        searchFriends: { keyword in
            let url = APIConstants.Endpoints.search
            return try await fetch(
                url: url,
                model: [MemberInfo].self,
                method: .get,
                queryParameters: ["keyword": keyword]
            )
        }
        ,
        
        requestFriend: { id in
            let url = APIConstants.Endpoints.friendControl + "/request"
            let queryParams = ["receiverId": String(id)]
            return try await fetch(
                url: url,
                model: Friend.self,
                method: .post,
                queryParameters: queryParams
            )
        }
        ,
        
        cancelFriendRequest: { id in
            let url = APIConstants.Endpoints.friendControl + "/request"
            let queryParams = ["friendId": String(id)]
            return try await fetch(
                url: url,
                model: Friend.self,
                method: .delete,
                queryParameters: queryParams
            )
        }
        ,
        
        acceptFriend: { id in
            let url = APIConstants.Endpoints.friendControl + "/accept"
            let params = ["requesterId": String(id)]
            let body = try JSONSerialization.data(withJSONObject: params, options: [])
            return try await fetch(
                url: url,
                model: Friend.self,
                method: .post,
                queryParameters: params
            )
        }
        ,
        
        declineFriend: { id in
            let url = APIConstants.Endpoints.friendControl + "/decline"
            let params = ["requesterId": String(id)]
            return try await fetch(
                url: url,
                model: Friend.self,
                method: .post,
                queryParameters: params
            )
        },
        
        deleteFriend: { id in
            let url = APIConstants.Endpoints.friendControl + "/delete"
            let params = ["friendId": String(id)]
            return try await fetch(
                url: url,
                model: Friend.self,
                method: .delete,
                queryParameters: params
            )
        }

    )
}
