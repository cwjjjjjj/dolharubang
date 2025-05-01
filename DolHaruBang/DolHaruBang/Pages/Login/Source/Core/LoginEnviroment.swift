//
//  DBTIEnviroment.swift
//  DolHaruBang
//
//  Created by 양희태 on 4/14/25.
//

import Foundation
import ComposableArchitecture
import Alamofire

struct SocialLoginResponse: Codable, Equatable {
    var accessToken: String
    var refreshToken: String
}

// 카카오 토큰 요청 모델
struct KakaoTokenRequest: Codable, Equatable, Sendable {
    var oauthToken: String
}

// 애플 이름 요청 모델
struct appleNameRequest: Codable, Sendable {
    var nickname: String
}

@DependencyClient
struct LoginClient {
    var kakaoLogin: @Sendable (String) async throws -> SocialLoginResponse
    var appleLogin: @Sendable (String,String) async throws -> SocialLoginResponse
    
    var isFirst : @Sendable () async throws -> Bool
}

// 테스트용 구현
extension LoginClient: TestDependencyKey {
    static let previewValue = Self()
    static let testValue = Self()
}

// 실제 구현
extension LoginClient: DependencyKey {
    static let liveValue = LoginClient(
        kakaoLogin: { token in
            let url = APIConstants.Endpoints.kakaoLogin
            do {
                let headers: HTTPHeaders = [
                            "Authorization": "Bearer \(token)",
                            "Content-Type" : "applications/json"
                            
                        ]
                print(token)
                return try await fetch(url: url, model: SocialLoginResponse.self, method: .post, headers: headers,skipAuth: true)
                } catch {
                    print("로그인 실패 :", error)
                    return SocialLoginResponse(accessToken: "no", refreshToken: "no")
                }
        },
        appleLogin: { idTokenString,userName in
            let url = APIConstants.Endpoints.appleLogin
            do {
                let headers: HTTPHeaders = [
                            "Authorization": "Bearer \(idTokenString)",
                            "Content-Type" : "applications/json"
                        ]
                print("userName",userName)
                let requestBody = appleNameRequest(nickname:userName)
                let bodyData = try JSONEncoder().encode(requestBody)
                
                return try await fetch(url: url, model: SocialLoginResponse.self, method: .post, headers: headers,body:bodyData,skipAuth: true)
                } catch {
                    print("로그인 실패 :", error)
                    return SocialLoginResponse(accessToken: "no", refreshToken: "no")
                }
        },
        isFirst: {
            let url = APIConstants.Endpoints.isfirst
            return try await fetch(url: url, model: Bool.self, method: .get)
        }
    )
}

// DependencyValues 확장
extension DependencyValues {
    var loginClient: LoginClient {
        get { self[LoginClient.self] }
        set { self[LoginClient.self] = newValue }
    }
}
