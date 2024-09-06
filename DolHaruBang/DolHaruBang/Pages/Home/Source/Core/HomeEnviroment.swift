//
//  HomeEnviroment.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/4/24.
//

import Foundation
import ComposableArchitecture
import Alamofire
    
struct User : Decodable, Equatable, Sendable {
    var user : Info
    
    struct Info : Decodable, Equatable, Sendable{
        var memberID : Int? = 0
        var nickname : String = "d"
        var birthday : String = "1998-09-10"
        var sands : Int = 0
        var totalLoginDays : Int = 5
        var profilePicture : String = "ds"
        var spaceName : String = "g"
        var memberEmail : String = "naver"
    }
 }

@DependencyClient
struct TmpClient
{
    var regist : @Sendable (_ regist : User.Info) async throws -> Void
}

// 실제 통신 전 테스트
extension TmpClient: TestDependencyKey {
    // 여기서의 Self는 WeatherClient
  static let previewValue = Self()

  static let testValue = Self()
}

extension DependencyValues{
    var tmpClient : TmpClient {
        get { self[TmpClient.self] }
        set { self[TmpClient.self] = newValue}
    }
}



extension TmpClient: DependencyKey {
  static let liveValue = TmpClient(
    regist: { userInfo in
        let url = "http://dolharubang.store/api/api/v1/schedules"
        let parameters: [String: Any] = [
            "year": "1",
            "month": "2",
            "day": "1998",
            "email": "sma",
        ]
        
        return try await withCheckedThrowingContinuation { continuation in
            AF.request(url, method: .get, parameters: parameters, encoding: JSONEncoding.default)
                .response {
                    response in
                    print("프린트 \(response)")
                }
        }

    }
  )
}
