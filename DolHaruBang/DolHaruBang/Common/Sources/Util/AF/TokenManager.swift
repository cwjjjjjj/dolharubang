//
//  TokenManager.swift
//  DolHaruBang
//
//  Created by 양희태 on 4/14/25.
//

import Foundation
import Security

class TokenManager {
    static let shared = TokenManager()
    
    private init() {}
    
    // 토큰 저장
    func saveTokens(accessToken: String, refreshToken: String) {
        KeychainHelper.standard.save(accessToken, service: "access-token", account: APIConstants.accessTokenKey)
        KeychainHelper.standard.save(refreshToken, service: "refresh-token", account: APIConstants.refreshTokenKey)
        print("토큰이 성공적으로 저장되었습니다.")
    }
    
    // 액세스 토큰 가져오기
    func getAccessToken() -> String? {
        return KeychainHelper.standard.read(service: "access-token", account: APIConstants.accessTokenKey)
    }
    
    // 리프레시 토큰 가져오기
    func getRefreshToken() -> String? {
        return KeychainHelper.standard.read(service: "refresh-token", account: APIConstants.refreshTokenKey)
    }
    
    // 토큰 삭제 (로그아웃 시)
    func clearTokens() {
        KeychainHelper.standard.delete(service: "access-token", account: APIConstants.accessTokenKey)
        KeychainHelper.standard.delete(service: "refresh-token", account: APIConstants.refreshTokenKey)
        NotificationCenter.default.post(name: NSNotification.Name("LogoutRequired"), object: nil)
        print("토큰이 성공적으로 삭제되었습니다.")
    }
}
