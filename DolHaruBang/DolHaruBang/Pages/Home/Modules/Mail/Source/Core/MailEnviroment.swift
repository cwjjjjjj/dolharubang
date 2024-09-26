//
//  MailEnviroment.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/26/24.
//


import Foundation
import ComposableArchitecture
import Alamofire


struct MailInfo: Hashable, Codable {
    let nickname : String?
    let mailType: String
    let description: String
    let dateAgo : String
    
    init(nickname: String? = nil, mailType: String, description: String, dateAgo: String) {
           self.nickname = nickname
           self.mailType = mailType
           self.description = description
           self.dateAgo = dateAgo
       }
}


@DependencyClient
struct MailClient {
    var fetchMail: @Sendable () async throws -> [MailInfo]
}

// 실제 통신 전 테스트
extension MailClient: TestDependencyKey {
    static let previewValue = Self()

    static let testValue = Self()
}

extension DependencyValues {
    var mailClient: MailClient {
        get { self[MailClient.self] }
        set { self[MailClient.self] = newValue }
    }
}

extension MailClient: DependencyKey {
    static let liveValue = MailClient(
        fetchMail: {
            
            let url = "http://211.49.26.51:8080/api/v1/pepperoni"
            
            
//            return try await fetch(url: url, model: Background.self, method: .get)
            
            return MailInfo.mockMailInfo
        }
   
    )
}

extension MailInfo {
    static let mockMailInfo: [MailInfo] = [
        MailInfo(mailType: "Read", description: "오늘은 7월 19일 할머니 생신이에용용용용용용", dateAgo: "2일 전"),
        MailInfo(nickname : "해인해인해인해인", mailType: "Clover", description: "님이 당신에게 클로버를 보냈어요!", dateAgo: "1일 전"),
        MailInfo(mailType: "Calendar", description: "오늘은 7월 19일 할머니 생신이에용용", dateAgo: "3시간 전"),
        MailInfo(mailType: "System", description: "오늘은 7월 19일 할머니 생신이에용용용용용용", dateAgo: "5분 전"),
        MailInfo(mailType: "Trophy", description: "마이 아이돌 업적을 달성했습니다. 확인해보세요.", dateAgo: "8월 20일")
    ]
}

private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  let formatter = DateFormatter()
  decoder.dateDecodingStrategy = .formatted(formatter)
  return decoder
}()
