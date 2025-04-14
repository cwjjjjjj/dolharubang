//
//  APIConstants.swift
//  DolHaruBang
//
//  Created by 양희태 on 4/14/25.
//

import Foundation

struct APIConstants {
    static let baseURL = "https://sole-organic-singularly.ngrok-free.app/api/v1"
    
    // 토큰 관련 키
    static let accessTokenKey = "ACCESS_TOKEN"
    static let refreshTokenKey = "REFRESH_TOKEN"
    
    // API 경로
    struct Endpoints {
        static let kakaoLogin = "/auth/kakao-login"
        static let refresh = "/auth/reissue"
    }
}
