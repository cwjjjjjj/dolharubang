//
//  ProfileEnviroment.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/25/24.
//

import Foundation
import ComposableArchitecture
import Alamofire


struct ProfileInfo: Hashable, Codable {
    let dolName: String
    let personality: String
    let baseAbility: String
    let dolBirth : String
    let friendShip : Int
    let activeAbility : [String]
    let potential : [String]
}


@DependencyClient
struct ProfileClient {
    var fetchProfile: @Sendable () async throws -> ProfileInfo
}

// 실제 통신 전 테스트
extension ProfileClient: TestDependencyKey {
    static let previewValue = Self()

    static let testValue = Self()
}

extension DependencyValues {
    var profileClient: ProfileClient {
        get { self[ProfileClient.self] }
        set { self[ProfileClient.self] = newValue }
    }
}

extension ProfileClient: DependencyKey {
    static let liveValue = ProfileClient(
        fetchProfile: {
            
            let url = "http://211.49.26.51:8080/api/v1/pepperoni"
            
            
//            return try await fetch(url: url, model: Background.self, method: .get)
            
            return ProfileInfo.mockProfileInfo
        }
   
    )
}

extension ProfileInfo {
    static let mockProfileInfo = ProfileInfo(
        dolName: "찬이",
        personality: "사교적",
        baseAbility: "친화력",
        dolBirth: "2022-05-15",
        friendShip: 80,
        activeAbility: ["재치있는 대화", "즉흥적인 연주"],
        potential: ["리더십", "창의성"]
    )
}

private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  let formatter = DateFormatter()
  decoder.dateDecodingStrategy = .formatted(formatter)
  return decoder
}()
