import Foundation
import ComposableArchitecture
import Alamofire


struct MailInfo: Hashable,Codable {
    let id: Int64
    let nickname: String?
    let content: String
    let type: String
    let createdAt: String
    let isRead : Bool
    
    //    init(nickname: String? = nil, mailType: String, description: String, dateAgo: String) {
    //           self.nickname = nickname
    //           self.mailType = mailType
    //           self.description = description
    //           self.dateAgo = dateAgo
    //       }
}


struct unReadMailCount : Codable {
    let unreadCount : Int
}

@DependencyClient
struct MailClient {
    var fetchMail: @Sendable (_ page: Int, _ size: Int) async throws -> [MailInfo]
    var readMail: @Sendable (String) async throws -> MailInfo
    var unread : @Sendable () async throws -> unReadMailCount
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
        fetchMail: { page, size in
            let url = APIConstants.Endpoints.mail
            let queryParameters : [String: String] = [
                "page": String(page),
                "size": String(size)
            ]
            
            // 테스트용 딜레이 추가 (1.5초)
            try await Task.sleep(for: .seconds(1))
            
            return try await fetch(url: url, model: [MailInfo].self, method: .get, queryParameters: queryParameters)
        },
        readMail: { id in
            let url = APIConstants.Endpoints.mail + "/\(id)" + "/read"
            return try await fetch(url: url, model: MailInfo.self, method: .post)
        },
        unread: {
            let url = APIConstants.Endpoints.unread
            
            return try await fetch(url: url, model: unReadMailCount.self, method: .get)
        }
        
    )
}

//extension MailInfo {
//    static let mockMailInfo: [MailInfo] = [
//        MailInfo(mailType: "Read", description: "오늘은 7월 19일 할머니 생신이에용용용용용용", dateAgo: "2일 전"),
//        MailInfo(nickname : "해인해인해인해인", mailType: "Clover", description: "님이 당신에게 클로버를 보냈어요!", dateAgo: "1일 전"),
//        MailInfo(mailType: "Calendar", description: "오늘은 7월 19일 할머니 생신이에용용", dateAgo: "3시간 전"),
//        MailInfo(mailType: "System", description: "오늘은 7월 19일 할머니 생신이에용용용용용용", dateAgo: "5분 전"),
//        MailInfo(mailType: "Trophy", description: "마이 아이돌 업적을 달성했습니다. 확인해보세요.", dateAgo: "8월 20일")
//    ]
//}
