//
//  AuthTokenManager.swift
//  DolHaruBang
//
//  Created by 양희태 on 3/19/25.
//

import Foundation
import Alamofire
import Combine
import ComposableArchitecture

// 토큰 모델
struct AuthTokens: Codable, Equatable {
    var accessToken: String
    var refreshToken: String
    var expiresIn: Int // 만료시간
}

// 토큰 저장 및 관리 클래스
class AuthTokenManager {
    private static let keychainService = "com.Dolharubang.auth"
    private static let accessTokenKey = "accessToken"
    private static let refreshTokenKey = "refreshToken"
    private static let expiresAtKey = "expiresAt"
    
    static let shared = AuthTokenManager()
    private init() {}
    
    // 토큰 저장
    func saveTokens(_ tokens: AuthTokens) {
        
        // 액세스 토큰 저장
        KeychainManager.save(value: tokens.accessToken, service: Self.keychainService, account: Self.accessTokenKey)
        
        // 리프레시 토큰 저장
        KeychainManager.save(value: tokens.refreshToken, service: Self.keychainService, account: Self.refreshTokenKey)
        
        // 만료 시간 저장 (현재 시간 + expiresIn)
        let expiresAt = Date().addingTimeInterval(TimeInterval(tokens.expiresIn))
        
        UserDefaults.standard.set(expiresAt.timeIntervalSince1970, forKey: Self.expiresAtKey)
    }
    
    // 액세스 토큰 조회
    func getAccessToken() -> String? {
        return KeychainManager.load(service: Self.keychainService, account: Self.accessTokenKey)
    }
    
    // 리프레시 토큰 조회
    func getRefreshToken() -> String? {
        return KeychainManager.load(service: Self.keychainService, account: Self.refreshTokenKey)
    }
    
    // 토큰 만료 여부 확인
    func isAccessTokenExpired() -> Bool {
        guard let expiresAtTimeInterval = UserDefaults.standard.object(forKey: Self.expiresAtKey) as? TimeInterval else {
            return true
        }
        
        let expiresAt = Date(timeIntervalSince1970: expiresAtTimeInterval)
        
        // 토큰 만료 10초 전에 만료된 것으로 간주
        return Date().addingTimeInterval(10) > expiresAt
    }
    
    // 로그아웃
    func clearTokens() {
        KeychainManager.delete(service: Self.keychainService, account: Self.accessTokenKey)
        KeychainManager.delete(service: Self.keychainService, account: Self.refreshTokenKey)
        UserDefaults.standard.removeObject(forKey: Self.expiresAtKey)
    }
}

// 키체인 관리 헬퍼 클래스
class KeychainManager {
    static func save(value: String, service: String, account: String) {
        guard let data = value.data(using: .utf8) else { return }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecValueData as String: data
        ]
        
        // 기존 항목 삭제
        SecItemDelete(query as CFDictionary)
        
        // 새 항목 추가
        SecItemAdd(query as CFDictionary, nil)
    }
    
    static func load(service: String, account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess, let data = result as? Data else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    static func delete(service: String, account: String) {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
        
        SecItemDelete(query as CFDictionary)
    }
}
