import Foundation
import UIKit
import ComposableArchitecture
import Alamofire

struct Talk: Codable, Equatable, Sendable {
    let diaryId: Int
    var contents: String?
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

            var data: [String: Any?] = [
                "contents": talk.contents,
                "emoji": talk.emoji
            ]
            
            let imageData: Data? = {
                if let base64 = talk.imageBase64, !base64.isEmpty {
                    return Data(base64Encoded: base64)
                } else {
                    return nil
                }
            }()

            let (body, boundary) = makeMultipartBody(
                dataDict: data,
                imageData: imageData
            )
            let headers: HTTPHeaders = ["Content-Type": "multipart/form-data; boundary=\(boundary)"]

            return try await fetch(url: url, model: Talk.self, method: .post, headers: headers, body: body)
        }

        ,

        deletePart: { diaryId, deleteTarget in
            let url = APIConstants.Endpoints.harubang + "/\(diaryId)/\(deleteTarget.caseName)"
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
