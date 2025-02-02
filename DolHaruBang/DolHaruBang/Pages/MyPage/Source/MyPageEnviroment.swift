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
    var userName : String
    var roomName : String
    var birthStone : String
    var birthDay : String
    var emailAddress : String
}

// 프로필 수정용
struct UserUpdateRequest: Codable {
    let nickname: String
    let profilePicture: String
    let spaceName: String
}


@DependencyClient
struct MyPageClient {
    var fetchMypage: @Sendable () async throws -> UserInfo
    var updateUserInfo: @Sendable (UserUpdateRequest) async throws -> UserInfo
}

// 실제 통신 전 테스트
extension MyPageClient: TestDependencyKey {
    // 여기서의 Self는 TmpClient
    static let previewValue = Self(
        fetchMypage: {
            return UserInfo.mockUserInf
        },
        updateUserInfo: { request in
            return UserInfo.mockUserInf
        }
    )

    static let testValue = Self()
}

extension DependencyValues {
    var myPageClient: MyPageClient {
        get { self[MyPageClient.self] }
        set { self[MyPageClient.self] = newValue }
    }
}

extension MyPageClient: DependencyKey {
    static let liveValue = MyPageClient(
        
        fetchMypage: {
            
            let url = "https://c71b-118-42-124-3.ngrok-free.app/api/v1/members/profile/1"
            
            return try await fetch(url: url, model: UserInfo.self, method: .get)
            }
        ,
       
        updateUserInfo: { request in
            
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/members/profile/update"
                        
            let jsonEncoder = JSONEncoder()
                let jsonData = try jsonEncoder.encode(request)
            
                   
                    return try await fetch(
                       url: url,
                       model: UserInfo.self,
                       method: .post,
                       body: jsonData
                   )
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
         userName : "희태",
         roomName : "돌돌이방",
         birthStone : "가넷",
         birthDay : "2023년 10월 31일",
         emailAddress : "smyang0220@naver.com"
    )


}
