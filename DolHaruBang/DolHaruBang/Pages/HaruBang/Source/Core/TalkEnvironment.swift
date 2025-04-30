import Foundation
import UIKit
import ComposableArchitecture
import Alamofire

struct Talk: Codable, Equatable, Sendable {
    let diaryId: Int
    var contents: String
    var emoji: String?
    var imageUrl: String?
    var reply: String?
    let createdAt: Date
    var modifiedAt: Date?
}

struct TalkToCreate: Codable, Equatable, Sendable {
    var contents: String
    var emoji: String?
    var imageBase64: String?
    var reply: String?
}

struct NetworkMessage: Decodable, Equatable, Sendable {
    var message: String
}

@DependencyClient
struct TalkClient {
    var fetchTalk: @Sendable (_ diaryId: Int) async throws -> Talk
    var fetchTalks: @Sendable () async throws -> [Talk]
    var registTalk: @Sendable (_ talk: TalkToCreate) async throws -> Talk
    var deletePart: @Sendable (_ diaryId: Int, _ deleteTarget: DeleteTarget) async throws -> Talk
    var deleteTalk: @Sendable (_ diaryId: Int) async throws -> NetworkMessage
}

extension TalkClient: DependencyKey {
    static let liveValue = TalkClient(
        fetchTalk: { diaryId in
            let url = APIConstants.Endpoints.harubang + "/\(diaryId)"
            return try await fetch(url: url, model: Talk.self, method: .get)
        },
        fetchTalks: {
            let url = APIConstants.Endpoints.harubang + "/list"
            return try await fetch(url: url, model: [Talk].self, method: .get)
        },
        registTalk: { talk in
            let url = APIConstants.Endpoints.harubang

            let parameters: [String: Any] = [
                "contents": talk.contents,
                "emoji": talk.emoji ?? NSNull(),
                "imageBase64": talk.imageBase64 ?? NSNull()
            ]
            
            print("\(url)로 요청 보냄! \n parameters: \(parameters)")
            let body = try JSONSerialization.data(withJSONObject: parameters)
            return try await fetch(url: url, model: Talk.self, method: .post, body: body)
        },
        deletePart: { diaryId, deleteTarget in
            let url = APIConstants.Endpoints.harubang + "/\(deleteTarget.caseName)/\(diaryId)"
            return try await fetch(url: url, model: Talk.self, method: .patch)
        },
        deleteTalk: { diaryId in
            let url = APIConstants.Endpoints.harubang + "/\(diaryId)"
            return try await fetch(url: url, model: NetworkMessage.self, method: .delete)
        }
    )
}

struct UploadResponse: Decodable {
    let imageUrl: String
}

// DependencyValues
extension DependencyValues {
    var talkClient: TalkClient {
        get { self[TalkClient.self] }
        set { self[TalkClient.self] = newValue }
    }
}

//// TestDependencyKey 수정
//extension TalkClient: TestDependencyKey {
//    // 미리보기
//    static let previewValue = Self(
//        fetchTalk: {
//            return Talk.mock
//        },
//        fetchTalks: {
//            return Talk.mockTalks
//        },
//        registTalk: { _ in
//            return NetworkMessage(message: "등록 성공!")
//        },
//        editTalk: { _ in
//            return NetworkMessage(message: "수정 성공!")
//        },
//        deleteTalk: { _ in
//            return NetworkMessage(message: "삭제 성공!")
//        }
//    )
//    
//    // 테스트
//    static let testValue = Self()
//}
