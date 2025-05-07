//
//  ProfileEnviroment.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/25/24.
//

import Foundation
import ComposableArchitecture
import Alamofire

let personalityKoreanDict: [String: String] = [
    "picky": "까다로움",
    "chic": "시크함",
    "timid": "소심함",
    "cheerful": "명랑함",
    "affectionate": "애정넘침",
    "energetic": "에너지넘침",
    "sleepy": "나른함",
    "blank": "멍함",
    "romantic": "낭만파"
]

let baseAbilityKoreanDict: [String: String] = [
    "ROCKSTAR": "Rock스타",
    "ADVISOR": "고민해결사",
    "WEATHERCASTER": "기상캐스터",
    "WISESAYING": "오늘의명언",
    "FOODEXPERT": "쩝쩝박사",
    "FORTUNETELLING": "탄생석운세"
]

struct ProfileInfo: Hashable, Codable {
    let dolName: String
    let personality: String
    let baseAbility: String
    let dolBirth : String
    let friendShip : Int
    let activeAbility : [String]
    let potential : [String]
    let roomName : String
}

extension ProfileInfo {
    var personalityKorean: String {
        personalityKoreanDict[personality] ?? personality
    }
    var baseAbilityKorean: String {
        baseAbilityKoreanDict[baseAbility] ?? baseAbility
    }
}

// 프로필 수정용
struct dolRequestBody: Codable, Equatable, Sendable {
    let text: String
}

@DependencyClient
struct ProfileClient {
    var dolprofile: @Sendable () async throws -> ProfileInfo
    var editdolname: @Sendable (String) async throws -> ProfileInfo
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
        dolprofile : {
            let url = APIConstants.Endpoints.dolprofile
            
            return try await fetch(url: url, model: ProfileInfo.self, method: .get)
        },
        editdolname : { dolName in
            let url = APIConstants.Endpoints.dolname
            
            let requestBody = dolRequestBody(text:dolName)
            let bodyData = try JSONEncoder().encode(requestBody)
            return try await fetch(url: url, model: ProfileInfo.self, method: .post,body: bodyData)
        }
   
    )
}

extension ProfileInfo {
    static let mockProfileInfo = ProfileInfo(
        dolName: "찬이",
        personality: "사교적",
        baseAbility: "친화력",
        dolBirth: "2022-05-15",
        friendShip: 365,
        activeAbility: ["재치있는 대화", "즉흥적인 연주"],
        potential: ["리더십", "창의성"], roomName: "fsfs"
    )
}

private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  let formatter = DateFormatter()
  decoder.dateDecodingStrategy = .formatted(formatter)
  return decoder
}()
