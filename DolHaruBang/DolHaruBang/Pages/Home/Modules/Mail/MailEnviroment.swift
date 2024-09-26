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
    let mailType: String
    let description: String
    let dateAgo : String
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
            
            return ProfileInfo.mockProfileInfo
        }
   
    )
}

extension MailInfo {
    static let mockMailInfo: [MailInfo] = [
        MailInfo(mailType: "Read", description: "Welcome to our service!", dateAgo: "2 days ago"),
        MailInfo(mailType: "Clover", description: "Special promotion for you.", dateAgo: "1 day ago"),
        MailInfo(mailType: "Calender", description: "Don't forget to check this out!", dateAgo: "3 hours ago"),
        MailInfo(mailType: "Alert", description: "Important update regarding your account.", dateAgo: "5 minutes ago"),
        MailInfo(mailType: "Newsletter", description: "Our latest news and updates.", dateAgo: "1 week ago")
    ]
}

private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  let formatter = DateFormatter()
  decoder.dateDecodingStrategy = .formatted(formatter)
  return decoder
}()
