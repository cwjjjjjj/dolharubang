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

@DependencyClient
struct MyPageClient {
    var fetchMypage: @Sendable () async throws -> UserInfo
}

// 실제 통신 전 테스트
extension MyPageClient: TestDependencyKey {
    // 여기서의 Self는 TmpClient
    static let previewValue = Self(
        fetchMypage: {
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
            let url = "http://211.49.26.51:8080/api/v1/pepperoni"
            
//            return try await fetch(url: url, model: [Trophy].self, method: .get)
            
            return UserInfo.mockUserInf
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
