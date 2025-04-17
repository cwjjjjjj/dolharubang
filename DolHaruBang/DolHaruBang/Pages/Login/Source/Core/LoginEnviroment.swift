////
////  LoginEnviroment.swift
////  DolHaruBang
////
////  Created by 양희태 on 4/17/25.
////
//
//import Foundation
//import ComposableArchitecture
//import Alamofire
//
//struct KakaoLoginResponse: Codable, Equatable {
//    var accessToken: String
//    var refreshToken: String
//}
//
//// 카카오 토큰 요청 모델
//struct KakaoTokenRequest: Codable, Equatable, Sendable {
//    var oauthToken: String
//}
//
//@DependencyClient
//struct LoginClient {
//    var kakaoLogin: @Sendable (String) async throws -> KakaoLoginResponse
//}
//
//// 테스트용 구현
//extension LoginClient: TestDependencyKey {
//    static let previewValue = Self()
//    
//    static let testValue = Self()
//}
//
//// 실제 구현
//extension LoginClient: DependencyKey {
//    static let liveValue = LoginClient(
//        kakaoLogin: { token in
//            let url = "/auth/kakao-login"
//            do {
//                let headers: HTTPHeaders = [
//                            "Authorization": "Bearer \(token)",
//                            "Content-Type" : "applications/json"
//                            
//                        ]
//                print(token)
//                return try await fetch(url: url, model: KakaoLoginResponse.self, method: .post, headers: headers,skipAuth: true)
//                } catch {
//                    print("로그인 실패 :", error)
//                    return KakaoLoginResponse(accessToken: "no", refreshToken: "no")
//                }
//        }
//    )
//}
//
//// DependencyValues 확장
//extension DependencyValues {
//    var loginClient: LoginClient {
//        get { self[LoginClient.self] }
//        set { self[LoginClient.self] = newValue }
//    }
//}
