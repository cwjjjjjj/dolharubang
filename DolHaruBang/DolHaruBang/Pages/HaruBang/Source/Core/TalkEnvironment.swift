import Foundation
import UIKit
import ComposableArchitecture
import Alamofire

struct Talk: Codable, Equatable, Sendable {
    let diaryId: Int
    var contents: String
    var emoji: String?
    var imageUrl: String?
    var reply: String
    let createdAt: Date
    var modifiedAt: Date?
    
    enum CodingKeys: String, CodingKey {
        case diaryId
        case contents
        case emoji
        case imageUrl
        case reply
        case createdAt
        case modifiedAt
    }
}

struct NetworkMessage: Decodable, Equatable, Sendable {
    var message: String
}

@DependencyClient
struct TalkClient {
    var fetchTalk: @Sendable (_ diaryId: Int) async throws -> Talk
    var fetchTalks: @Sendable (_ memberId: Int) async throws -> [Talk]
    var registTalk: @Sendable (_ talk: Talk) async throws -> NetworkMessage
    var deleteTalk: @Sendable (_ diaryId: Int) async throws -> NetworkMessage
}

extension TalkClient: DependencyKey {
    static let liveValue = TalkClient(
        fetchTalk: { diaryId in
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/diaries/\(diaryId)"
            return try await AFRequest(url: url, model: Talk.self, method: .get)
        },
        fetchTalks: { memberId in
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/diaries/member-harubang/\(memberId)"
            return try await AFRequest(url: url, model: [Talk].self, method: .get)
        },
        registTalk: { talk in
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/diaries"
            let parameters: [String: Any] = [
                "memberId": 1,
                "contents": talk.contents,
                "emoji": talk.emoji ?? "",
                "image": talk.imageUrl ?? "",
                "reply": talk.reply,
                "createdAt": ISO8601DateFormatter().string(from: talk.createdAt),
                "modifiedAt": talk.modifiedAt.map { ISO8601DateFormatter().string(from: $0) } ?? NSNull()
            ]
            print("Sending request to \(url) with parameters: \(parameters)")
            let body = try JSONSerialization.data(withJSONObject: parameters)
            return try await AFRequest(url: url, model: NetworkMessage.self, method: .post, body: body)
        },
        deleteTalk: { diaryId in
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/diaries/\(diaryId)"
            return try await AFRequest(url: url, model: NetworkMessage.self, method: .delete)
        }
    )
}

struct UploadResponse: Decodable {
    let imageUrl: String
}

private func AFRequest<T: Decodable>(
    url: String,
    model: T.Type,
    method: Alamofire.HTTPMethod,
    body: Data? = nil
) async throws -> T {
    return try await withCheckedThrowingContinuation { continuation in
        var urlRequest = URLRequest(url: URL(string: url)!)
        urlRequest.httpMethod = method.rawValue

        if let body = body, (method == .post || method == .put || method == .patch) {
            urlRequest.httpBody = body
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        }

        // 커스텀 디코더 설정
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let dateString = try container.decode(String.self)
            
            // 밀리초 포함 ISO8601 형식 처리
            let isoFormatterWithMilli = ISO8601DateFormatter()
            isoFormatterWithMilli.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            // 밀리초 없는 ISO8601 형식 대비
            let isoFormatter = ISO8601DateFormatter()
            isoFormatter.formatOptions = [.withInternetDateTime]
            
            // 추가적인 날짜 형식 처리 (밀리초 포함/미포함)
            let fallbackFormatter = DateFormatter()
            fallbackFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS" // 밀리초 6자리까지 지원
            fallbackFormatter.timeZone = TimeZone(secondsFromGMT: 0) // UTC로 설정
            
            if let date = isoFormatterWithMilli.date(from: dateString) {
                print("디코딩 성공 (밀리초 포함 ISO8601): \(dateString) -> \(date)")
                return date
            } else if let date = isoFormatter.date(from: dateString) {
                print("디코딩 성공 (기본 ISO8601): \(dateString) -> \(date)")
                return date
            } else if let date = fallbackFormatter.date(from: dateString) {
                print("디코딩 성공 (Fallback): \(dateString) -> \(date)")
                return date
            } else {
                print("디코딩 실패: \(dateString)")
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid date format: \(dateString)"
                )
            }
        }

        AF.request(urlRequest)
            .validate()
            .responseData { response in
                switch response.result {
                case .success(let data):
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("AFRequest 응답 원문 - URL: \(url), Response: \(responseString)")
                    } else {
                        print("AFRequest 응답 디코딩 불가 - URL: \(url), Raw Data: \(data)")
                    }
                    do {
                        let value = try decoder.decode(T.self, from: data)
                        print("AFRequest 성공! - URL: \(url), Method: \(method.rawValue)")
                        continuation.resume(returning: value)
                    } catch {
                        print("디코딩 실패 - URL: \(url), Error: \(error)")
                        continuation.resume(throwing: error)
                    }
                case .failure(let error):
                    if let data = response.data, let errorString = String(data: data, encoding: .utf8) {
                        print("AFRequest 실패 응답 - URL: \(url), Error Response: \(errorString)")
                    }
                    print("AFRequest 실패 - URL: \(url), Error: \(error.localizedDescription)")
                    continuation.resume(throwing: error)
                }
            }
    }
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

extension Talk {
    static let mock = Self(
        diaryId: 0,
        contents: "청춘! 이는 듣기만 하여도 가슴이 설레는 말이다. 청춘! 너의 두 손을 가슴에 대고, 물방아 같은 심장의 고동을 들어 보라. 청춘의 피는 끓는다. 끓는 피에 뛰노는 심장은 거선(巨船)의 기관(汽罐)같이 힘있다.",
        emoji: "smileEmoji",
        imageUrl: "testImage.png",
        reply: "청춘의 피는 끓는다.",
        createdAt: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 23, hour: 23, minute: 30)) ?? Date(),
        modifiedAt: nil
    )

    static let mockTalk1 = Self(
        diaryId: 1,
        contents: "안녕하세요! 오늘은 날씨가 좋네요.",
        emoji: "heartEyedEmoji",
        imageUrl: "sunny.png",
        reply: "아니요, 너무 더운데요? 이게 추석 지난 9월 날씨가 맞다고 생각하시나요? 진짜 날씨 관리 제대로 안하나요? 에어컨 없으면 정말 살 수가 없어요. 다시 한 번 캐리어 형님의 감사함을 깨닫습니다. 노벨 평화상은 캐리어 형님이 받으셨어야 해요.",
        createdAt: Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 24, hour: 10, minute: 15)) ?? Date(),
        modifiedAt: nil
    )

    static let mockTalk2 = Self(
        diaryId: 2,
        contents: "점심 메뉴로 뭘 먹을까요?",
        emoji: "sosoEmoji",
        imageUrl: "",
        reply: "햄버거는 어떨까요?",
        createdAt: Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 31, hour: 12, minute: 30)) ?? Date(),
        modifiedAt: nil
    )
    
    static let mockTalks: [Talk] = [mock, mockTalk1, mockTalk2]
}
