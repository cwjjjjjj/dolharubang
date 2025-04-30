//
//  APIConstants.swift
//  DolHaruBang
//
//  Created by 양희태 on 4/14/25.
//

import Foundation

struct APIConstants {
    // 우진 로컬
//    static let baseURL = "https://sole-organic-singularly.ngrok-free.app/api/v1"
    // 표준
    static let baseURL = "https://dolharubang.shop/api/v1"
    
    // 토큰 관련 키
    static let accessTokenKey = "ACCESS_TOKEN"
    static let refreshTokenKey = "REFRESH_TOKEN"
    
    // API 경로
    struct Endpoints {
        static let kakaoLogin = "/auth/kakao-login"
        static let appleLogin = "/auth/apple-login"
        static let refresh = "/auth/reissue"
        
        // MARK: HaruBang(Diary)
        static let harubang = "/diaries"
        
        // MARK: Schedule(Calendar)
        static let schedule = "/schedules"
        

        // MARK: Park(Doljanchi(contests) + Friends)
        static let feed = "/contests/feed"
        static let contest = "/contests"

        // MARK: Mail
        static let mail = "/notifications"
        static let read = "/notifications"
        static let unread = "/notifications/unread-count"
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
        static let search = "/members/search"
        static let check = "/members/check"
        
        // MARK: Stones
        static let dolprofile = "/stones/profile" // 돌 프로필 조회
        static let sign = "/stones/sign-text"
        static let dolname = "/stones/name"
        static let adopt = "/stones/adopt"
        static let basic = "/stones/stone-info"

        
        // MARK: Missions
        static let trophy = "/member-missions"
        
    }
}
