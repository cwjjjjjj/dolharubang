import Foundation
import ComposableArchitecture
import Alamofire

struct Talk: Decodable, Equatable, Sendable {
    var diaryId: Int
    var contents: String
    var emoji: String?
    var image: String?
    var reply: String
    var createdAt: Date
    var modifiedAt: Date?
}

struct NetworkMessage: Decodable, Equatable, Sendable {
    var message: String
}

// 통신 담당 클라이언트
@DependencyClient
struct TalkClient {
    var fetchTalk: @Sendable () async throws -> Talk
    var fetchTalks: @Sendable () async throws -> [Talk]
    var registTalk: @Sendable (_ talk: Talk) async throws -> NetworkMessage
    var editTalk: @Sendable (_ talk: Talk) async throws -> NetworkMessage
    var deleteTalk: @Sendable (_ talkID: Int) async throws -> NetworkMessage
}

// 실제 통신으로 얻어오는 값
extension TalkClient: DependencyKey {
    static let liveValue = TalkClient(
        fetchTalk: {
            let url = "https://api/v1/diary"
            return try await fetch(
                url: url,
                model: Talk.self,
                method: .get
            )
        },
//        fetchTalks: {
//            let url = "https://api/v1/diaries"
//            return try await fetch(
//                url: url,
//                model: [Talk].self,
//                method: .get)
//        },
        // 임시로 Mock 데이터들이 보이게 해둠!
        fetchTalks: {
            return Talk.mockTalks
        },
        registTalk: { talk in
            let url = "https://api/v1/diary"
            let parameters: [String: Any] = [
                "contents": talk.contents,
                "emoji": talk.emoji,
                "image": talk.image,
                "reply": talk.reply,
                "createdAt": ISO8601DateFormatter().string(from: talk.createdAt),
                "modifiedAt": talk.modifiedAt
            ]
            let body = try JSONSerialization.data(withJSONObject: parameters)

            // fetch 함수 사용하여 네트워크 요청
            return try await fetch(
                url: url,
                model: NetworkMessage.self,
                method: .post,
                body: body
            )
        },
        editTalk: { talk in
            let url = "https://api/v1/diary/\(talk.diaryId)"
            let parameters: [String: Any] = [
                "contents": talk.contents,
                "emoji": talk.emoji,
                "image": talk.image,
                "reply": talk.reply,
                "modifiedAt": ISO8601DateFormatter().string(from: talk.modifiedAt!) // 수정된 시간
            ]
            let body = try JSONSerialization.data(withJSONObject: parameters)

            // fetch 함수 사용하여 네트워크 요청
            return try await fetch(
                url: url,
                model: NetworkMessage.self,
                method: .put,
                body: body
            )
        },
        deleteTalk: { talkID in
            let url = "https://api/v1/diary/\(talkID)"

            // fetch 함수 사용하여 네트워크 요청
            return try await fetch(
                url: url,
                model: NetworkMessage.self,
                method: .delete
            )
        }
    )
}

// DependencyValues
extension DependencyValues {
    var talkClient: TalkClient {
        get { self[TalkClient.self] }
        set { self[TalkClient.self] = newValue }
    }
}

// TestDependencyKey 수정
extension TalkClient: TestDependencyKey {
    // 미리보기
    static let previewValue = Self(
        fetchTalk: {
            return Talk.mock
        },
        fetchTalks: {
            return Talk.mockTalks
        },
        registTalk: { _ in
            return NetworkMessage(message: "등록 성공!")
        },
        editTalk: { _ in
            return NetworkMessage(message: "수정 성공!")
        },
        deleteTalk: { _ in
            return NetworkMessage(message: "삭제 성공!")
        }
    )
    
    // 테스트
    static let testValue = Self()
}

extension Talk {
    static let mock = Self(
        diaryId: 0,
        contents: "청춘! 이는 듣기만 하여도 가슴이 설레는 말이다. 청춘! 너의 두 손을 가슴에 대고, 물방아 같은 심장의 고동을 들어 보라. 청춘의 피는 끓는다. 끓는 피에 뛰노는 심장은 거선(巨船)의 기관(汽罐)같이 힘있다.",
        emoji: "smileEmoji",
        image: "testImage.png",
        reply: "청춘의 피는 끓는다.",
        createdAt: Calendar.current.date(from: DateComponents(year: 2024, month: 9, day: 23, hour: 23, minute: 30)) ?? Date(),
        modifiedAt: nil
    )

    static let mockTalk1 = Self(
        diaryId: 1,
        contents: "안녕하세요! 오늘은 날씨가 좋네요.",
        emoji: "heartEyedEmoji",
        image: "sunny.png",
        reply: "아니요, 너무 더운데요? 이게 추석 지난 9월 날씨가 맞다고 생각하시나요? 진짜 날씨 관리 제대로 안하나요? 에어컨 없으면 정말 살 수가 없어요. 다시 한 번 캐리어 형님의 감사함을 깨닫습니다. 노벨 평화상은 캐리어 형님이 받으셨어야 해요.",
        createdAt: Calendar.current.date(from: DateComponents(year: 2024, month: 11, day: 24, hour: 10, minute: 15)) ?? Date(),
        modifiedAt: nil
    )

    static let mockTalk2 = Self(
        diaryId: 2,
        contents: "점심 메뉴로 뭘 먹을까요?",
        emoji: "sosoEmoji",
        image: "",
        reply: "햄버거는 어떨까요?",
        createdAt: Calendar.current.date(from: DateComponents(year: 2024, month: 12, day: 31, hour: 12, minute: 30)) ?? Date(),
        modifiedAt: nil
    )
    
    static let mockTalks: [Talk] = [mock, mockTalk1, mockTalk2]
}
