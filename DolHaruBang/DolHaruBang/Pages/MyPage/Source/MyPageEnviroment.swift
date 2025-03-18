//
//  MyPageEnviroment.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/24/24.
//

import UIKit
import Foundation
import ComposableArchitecture
import Alamofire

struct UserInfo: Decodable, Equatable, Sendable {
    var userName: String
    var roomName: String
    var birthStone: String
    var birthDay: String
    var emailAddress: String
}

struct ChangeInfo: Codable, Equatable, Sendable {
    var nickname: String
    var spaceName: String
}

// 프로필 수정용
struct UserUpdateRequest: Codable {
    let nickname: String
    let profilePicture: String
    let spaceName: String
}

@DependencyClient
struct MyPageClient {
    var fetchMypage: @Sendable () async throws -> UserInfo
    var updateUserInfo: @Sendable (String, String) async throws -> UserInfo
    var updateUserPhoto: @Sendable (String) async throws -> UserInfo
}

// 실제 통신 전 테스트
extension MyPageClient: TestDependencyKey {
    static let previewValue = Self(
        fetchMypage: {
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/members/profile/15"
            do {
                return try await fetch(url: url, model: UserInfo.self, method: .get)
            } catch {
                print("회원불러오기 실패:", error)
                return UserInfo.mockUserInf
            }
        },
        updateUserInfo: { nickName, spaceName in
            // 테스트 환경에서는 mock 데이터 반환
            return UserInfo.mockUserInf
        },
        updateUserPhoto: { photoName in
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/members/profile-picture/15"
            do {
                // photoName을 어떻게 보낼지 처리 필요
                let body = try JSONEncoder().encode(["profilePicture": photoName])
                return try await fetch(url: url, model: UserInfo.self, method: .post, body: body)
            } catch {
                print("회원수정 실패:", error)
                return UserInfo.mockUserInf
            }
        }
    )

    static let testValue = Self()
}

extension DependencyValues {
    var myPageClient: MyPageClient {
        get { self[MyPageClient.self] }
        set { self[MyPageClient.self] = newValue }
    }
}

extension MyPageClient: DependencyKey {
    static let liveValue = MyPageClient(
        fetchMypage: {
            let url = "https://c71b-118-42-124-3.ngrok-free.app/api/v1/members/profile/1"
            do {
                return try await fetch(url: url, model: UserInfo.self, method: .get)
            } catch {
                print("회원정보 불러오기 실패:", error)
                return UserInfo.mockUserInf
            }
        },
        updateUserInfo: { nickName, spaceName in
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/members/profile/15"
            
            do {
                // ChangeInfo 객체 생성 및 인코딩
                let changeInfo = ChangeInfo(nickname: nickName, spaceName: spaceName)
                let body = try JSONEncoder().encode(changeInfo)
                
                return try await fetch(url: url, model: UserInfo.self, method: .post, body: body)
            } catch {
                print("회원수정 실패:", error)
                return UserInfo.mockUserInf
            }
        },
        updateUserPhoto: { photoName in
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/members/profile-picture/15"
            do {
                // photoName을 어떻게 보낼지 처리 필요
                let body = try JSONEncoder().encode(["profilePicture": photoName])
                return try await fetch(url: url, model: UserInfo.self, method: .post, body: body)
            } catch {
                print("사진수정 실패:", error)
                return UserInfo.mockUserInf
            }
        }
    )
}

private let jsonDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    let formatter = DateFormatter()
    decoder.dateDecodingStrategy = .formatted(formatter)
    return decoder
}()

extension UserInfo {
    static let mockUserInf = Self(
         userName: "희태",
         roomName: "돌돌이방",
         birthStone: "가넷",
         birthDay: "2023년 10월 31일",
         emailAddress: "smyang0220@naver.com"
    )
}
