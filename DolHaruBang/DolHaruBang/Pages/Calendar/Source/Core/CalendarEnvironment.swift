import UIKit
import Foundation
import ComposableArchitecture

struct Schedule: Identifiable, Codable, Equatable, Sendable {
    let id: Int
    var contents: String
    var startScheduleDate: Date
    var endScheduleDate: Date
    var isAlarm: Bool
    var alarmTime: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case contents
        case startScheduleDate
        case endScheduleDate
        case isAlarm
        case alarmTime
    }
}

@DependencyClient
struct ScheduleClient {
    var fetchSchedulesById: @Sendable (Int, Int, Int) async throws -> [Schedule]
    var addSchedule: @Sendable (Schedule) async throws -> Schedule
    var editSchedule: @Sendable (Schedule) async throws -> Schedule
    var deleteSchedule: @Sendable (Int) async throws -> Void
}

extension DependencyValues {
    var scheduleClient: ScheduleClient {
        get { self[ScheduleClient.self] }
        set { self[ScheduleClient.self] = newValue }
    }
}

extension ScheduleClient: DependencyKey {
    static let liveValue = ScheduleClient(
        fetchSchedulesById: { year, month, memberId in
            let url = "https://sole-organic-singularly.ngrok-free.app/api/v1/schedules"
            var components = URLComponents(string: url)!
            components.queryItems = [
                URLQueryItem(name: "year", value: String(year)),
                URLQueryItem(name: "month", value: String(month)),
                URLQueryItem(name: "memberId", value: String(memberId))
            ]
            guard let url = components.url else { throw URLError(.badURL) }
            return try await fetch(url: url, method: .get)
        },
        
        addSchedule: { schedule in
            let url = URL(string: "https://sole-organic-singularly.ngrok-free.app/api/v1/schedules")!
            let jsonData = try encode(schedule: schedule, memberId: 1)
            return try await post(url: url, body: jsonData)
        },
        
        editSchedule: { schedule in
            let url = URL(string: "https://sole-organic-singularly.ngrok-free.app/api/v1/schedules/\(schedule.id)")!
            print("\(schedule.id)번 일정 수정 요청")
            let jsonData = try encode(schedule: schedule, memberId: 1)
            return try await patch(url: url, body: jsonData)
        },
        
        deleteSchedule: { scheduleId in
            let url = URL(string: "https://sole-organic-singularly.ngrok-free.app/api/v1/schedules/\(scheduleId)")!
            print("\(scheduleId)번 일정 삭제 요청")
            try await delete(url: url, body: nil)
        }
    )
}


private func encode(schedule: Schedule, memberId: Int) throws -> Data {
    print("--------------------------------------------------------------------------")
    print("Encoding Schedule...")
    print("--------------------------------------------------------------------------")
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .custom { date, encoder in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul") // KST로 명시적 설정
        let dateString = formatter.string(from: date)
        var container = encoder.singleValueContainer()
        try container.encode(dateString)
    }
    
    // 모든 Date 필드를 KST로 출력
    let kstFormatter = DateFormatter()
    kstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    kstFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    
    print("<<인코딩 전, KST 기준 일정 시간>>")
    print("startScheduleDate: \(kstFormatter.string(from: schedule.startScheduleDate))")
    print("endScheduleDate: \(kstFormatter.string(from: schedule.endScheduleDate))")
    print("alarmTime: \(kstFormatter.string(from: schedule.alarmTime))")
    
    let jsonData = try encoder.encode(schedule)
    var jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
    jsonDict["memberId"] = memberId
    let finalData = try JSONSerialization.data(withJSONObject: jsonDict)
    if let jsonString = String(data: finalData, encoding: .utf8) {
        if let jsonData = jsonString.data(using: .utf8),
           let jsonObject = try? JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] {
            if let startDateString = jsonObject["startScheduleDate"] as? String {
                print("인코딩 후 startScheduleDate: \(startDateString)")
            }
            if let endDateString = jsonObject["endScheduleDate"] as? String {
                print("인코딩 후 endScheduleDate: \(endDateString)")
            }
            if let alarmTimeString = jsonObject["alarmTime"] as? String {
                print("인코딩 후 alarmTime: \(alarmTimeString)")
            }
        }
        print("Request Body: \(jsonString)")
    }
    print("--------------------------------------------------------------------------")
    print("Encoding Ends...")
    print("--------------------------------------------------------------------------")
    return finalData
}

private func fetch<T: Decodable>(url: URL, method: HTTPMethod, body: Data? = nil) async throws -> T {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = body
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    print("축하합니다! 데이터 송수신에는 성공했어요. 이제 디코딩해볼까요?")
    print("HTTP Status Code: \(httpResponse.statusCode)")
    print("사용자 핸드폰 기준으로 아래와 같던 일정이")
    if let responseString = String(data: data, encoding: .utf8) {
        print("Response Body: \(responseString)")
    }
    guard (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
    
    print("--------------------------------------------------------------------------")
    print("Decoding Schedule...")
    print("--------------------------------------------------------------------------")
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        let milliFormatter = DateFormatter()
        milliFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        milliFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // KST로 변경
        
        let basicFormatter = DateFormatter()
        basicFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        basicFormatter.timeZone = TimeZone(identifier: "Asia/Seoul") // KST로 변경
        
        if let date = milliFormatter.date(from: dateString) {
            print("서버 응답 시간 by Milli \(dateString)")
            return date
        }
        if let date = basicFormatter.date(from: dateString) {
            print("서버 응답 시간 by Basic \(dateString)")
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
    }
    return try decoder.decode(T.self, from: data)
}

private func post<T: Decodable>(url: URL, body: Data) async throws -> T {
    try await fetch(url: url, method: .post, body: body)
}

private func put<T: Decodable>(url: URL, body: Data) async throws -> T {
    try await fetch(url: url, method: .put, body: body)
}

private func patch<T: Decodable>(url: URL, body: Data) async throws -> T {
    try await fetch(url: url, method: .patch, body: body)
}

// DELETE 요청은 Response Body를 반환하지 않으므로 Void
private func delete(url: URL, body: Data? = nil) async throws {
    var request = URLRequest(url: url)
    request.httpMethod = "DELETE"
    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
    request.httpBody = body
    
    let (_, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse else {
        throw URLError(.badServerResponse)
    }
    print("HTTP Status Code: \(httpResponse.statusCode)")
    guard httpResponse.statusCode == 204 || (200...299).contains(httpResponse.statusCode) else {
        print("삭제 실패!")
        throw URLError(.badServerResponse)
    }
    print("삭제 성공!")
}

