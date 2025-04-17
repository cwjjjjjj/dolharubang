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
        
        // MARK: Customize
        static let background = "/memberItems/customs/30/BACKGROUND"
        static let face = "/memberItems/customs/30/FACE"
        static let faceShape = "/memberItems/customs/7/SHAPE"
        static let nest = "/memberItems/customs/30/NEST"
        static let accessory = "/memberItems/customs/30/ACCSESORY"
        
        // MARK: Members
        static let sand = "/members/sands/30"
        
        // MARK: stones
        static let dolprofile = "/stones/profile" // 돌 프로필 조회
        static let sign = "/stones/sign-text"
    }
}
