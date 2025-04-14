//
//  KeyChainService.swift
//  DolHaruBang
//
//  Created by 양희태 on 4/14/25.
//

import Foundation

final class KeychainHelper {
    static let standard = KeychainHelper()
    private init() {}
    
    func save(_ data: String, service: String, account: String) {
        guard let data = data.data(using: .utf8) else { return }
        
        // 쿼리 생성
        let query = [
            kSecValueData: data,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        
        // 기존 항목 삭제
        SecItemDelete(query)
        
        // 새 항목 추가
        SecItemAdd(query, nil)
    }
    
    func read(service: String, account: String) -> String? {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword,
            kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        SecItemCopyMatching(query, &result)
        
        guard let data = result as? Data,
              let string = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return string
    }
    
    func delete(service: String, account: String) {
        let query = [
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecClass: kSecClassGenericPassword
        ] as CFDictionary
        
        SecItemDelete(query)
    }
}
