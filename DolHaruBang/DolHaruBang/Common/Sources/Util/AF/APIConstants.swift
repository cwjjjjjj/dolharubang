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
        static let background = "/memberItems/customs/BACKGROUND"
        static let face = "/memberItems/customs/FACE"
        static let faceShape = "/memberItems/customs/SHAPE"
        static let nest = "/memberItems/customs/NEST"
        static let accessory = "/memberItems/customs/ACCESSORY"
        static let wear = "/memberItems/wear"
        static let buy = "/memberItems/buy"
        
        // MARK: Members
        static let sand = "/members/sands"
        static let info = "/members/profile"
        static let photo = "/members/profile-picture"
        static let isfirst = "/members/is-first"
        
        // MARK: stones
        static let dolprofile = "/stones/profile" // 돌 프로필 조회
        static let sign = "/stones/sign-text"
        static let dolname = "/stones/name"
        
        
    }
}
