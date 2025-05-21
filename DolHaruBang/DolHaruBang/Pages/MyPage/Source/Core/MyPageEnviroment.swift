//
//  MyPageEnviroment.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/24/24.
//

import UIKit
import Foundation
import ComposableArchitecture
import Alamofire

struct UserInfo: Decodable, Equatable, Sendable {
    var userName: String
    var roomName: String
    var birthStone: String
    var birthday: String
    var emailAddress: String
    var closeness : Int
    var profilePicture : String?
}

struct ChangeInfo: Codable, Equatable, Sendable {
    var nickname: String
    var spaceName: String
}

// 프로필 수정용
struct InfoRequestBody: Codable, Equatable, Sendable {
    let nickname: String
    let spaceName: String
}


struct photoRequestBody: Codable, Equatable,Sendable {
    let image : String
}

@DependencyClient
struct MyPageClient {
    var fetchMypage: @Sendable () async throws -> UserInfo
    var updateUserInfo: @Sendable (String, String) async throws -> UserInfo
    var updateUserPhoto: @Sendable (String) async throws -> UserInfo
    var withdraw: @Sendable () async throws -> Void
}

// 실제 통신 전 테스트
//extension MyPageClient: TestDependencyKey {
//    static let previewValue = Self(
//        fetchMypage: {
//            let url = APIConstants.Endpoints.info
//            do {
//                return try await fetch(url: url, model: UserInfo.self, method: .get)
//            } catch {
//                print("회원불러오기 실패:", error)
//                return UserInfo.mockUserInf
//            }
//        },
//        updateUserInfo: { nickName, spaceName in
//            // 테스트 환경에서는 mock 데이터 반환
//            return UserInfo.mockUserInf
//        },
//        updateUserPhoto: { photoName in
//            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/members/profile-picture/15"
//            do {
//                // photoName을 어떻게 보낼지 처리 필요
//                let body = try JSONEncoder().encode(["profilePicture": photoName])
//                return try await fetch(url: url, model: UserInfo.self, method: .post, body: body)
//            } catch {
//                print("회원수정 실패:", error)
//                return UserInfo.mockUserInf
//            }
//        }
//    )
//
//    static let testValue = Self()
//}

extension DependencyValues {
    var myPageClient: MyPageClient {
        get { self[MyPageClient.self] }
        set { self[MyPageClient.self] = newValue }
    }
}

extension MyPageClient: DependencyKey {
    static let liveValue = MyPageClient(
        fetchMypage: {
            let url = APIConstants.Endpoints.info
            
            return try await fetch(url: url, model: UserInfo.self, method: .get)
        }
        ,
        
        updateUserInfo: { nickName, spaceName in
            let url = APIConstants.Endpoints.info
            
            let requestBody = InfoRequestBody(nickname: nickName, spaceName: spaceName)
            let bodyData = try JSONEncoder().encode(requestBody)
            return try await fetch(url: url, model: UserInfo.self, method: .post,body: bodyData)
        }
        ,
        
        updateUserPhoto: { base64String in
            let url = APIConstants.Endpoints.photo
            
            let imageData: Data? = {
                if !base64String.isEmpty {
                    return Data(base64Encoded: base64String)
                } else {
                    return nil
                }
            }()
            
            let (body, boundary) = makeMultipartBody(
                dataDict: [:],
                imageData: imageData
            )
            let headers: HTTPHeaders = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]
            

            return try await fetch(
                url: url,
                model: UserInfo.self,
                method: .post,
                headers: headers,
                body: body
            )
        }
        ,
        
        withdraw: {
            let url = APIConstants.Endpoints.withdraw
            
            _  = try await fetch (url: url, model: EmptyResponse.self, method: .delete)
        }
        
    )
}

private let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    let formatter = DateFormatter()
    decoder.dateDecodingStrategy = .formatted(formatter)
    return decoder
}()

extension UserInfo {
    static let mockUserInf = Self(
         userName: "",
         roomName: "",
         birthStone: "돌맹",
         birthday: "2000년 09월 10일",
         emailAddress: "",
         closeness: 0,
         profilePicture: ""
    )
}


private func ImagetoStirngBody(
    imageData: Data?,
    imageMimeType: String = "image/jpeg"
) -> (body: Data, boundary: String) {
    let boundary = "Boundary-\(UUID().uuidString)"
    var body = Data()
    let lineBreak = "\r\n"
    
    // 1. 이미지 필드 (파일)
    if let imageData = imageData {
        body.append("--\(boundary)\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Type: \(imageMimeType)\(lineBreak)\(lineBreak)".data(using: .utf8)!)
        body.append(imageData)
        body.append(lineBreak.data(using: .utf8)!)
    }
    
    // 종료 바운더리
    body.append("--\(boundary)--\(lineBreak)".data(using: .utf8)!)
    return (body, boundary)
}
