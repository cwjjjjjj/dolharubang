import UIKit
import Foundation
import ComposableArchitecture

struct Schedule: Identifiable, Decodable, Equatable, Sendable {
    let id: Int
    let contents: String
    let startScheduleDate: Date
    let endScheduleDate: Date
    let isAlarm: Bool
    let alarmTime: Date
}

@DependencyClient
struct ScheduleClient {
    var fetchSchedulesById: @Sendable (Int, Int, Int) async throws -> [Schedule]
    var addSchedule: @Sendable (Schedule) async throws -> Schedule
    var editSchedule: @Sendable (Schedule) async throws -> Schedule
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
            return try await fetch(url: url, model: [Schedule].self, method: .get)
        },
        
        addSchedule: { schedule in
            let url = URL(string: "https://sole-organic-singularly.ngrok-free.app/api/v1/schedules")!
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.post.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            let jsonData = try JSONSerialization.data(withJSONObject: [
                "memberId": 1,
                "contents": schedule.contents,
                "startScheduleDate": dateFormatter.string(from: schedule.startScheduleDate),
                "endScheduleDate": dateFormatter.string(from: schedule.endScheduleDate),
                "isAlarm": schedule.isAlarm,
                "alarmTime": dateFormatter.string(from: schedule.alarmTime)
            ], options: [])
            
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response Body: \(responseString)")
                }
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // 밀리초 포함 형식 (yyyy-MM-dd'T'HH:mm:ss.SSS)
                let milliFormatter = DateFormatter()
                milliFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                milliFormatter.locale = Locale(identifier: "en_US_POSIX")
                milliFormatter.timeZone = TimeZone(identifier: "UTC")
                
                // 밀리초 없는 형식 (yyyy-MM-dd'T'HH:mm:ss)
                let basicFormatter = DateFormatter()
                basicFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                basicFormatter.locale = Locale(identifier: "en_US_POSIX")
                basicFormatter.timeZone = TimeZone(identifier: "UTC")
                
                // 밀리초 포함 형식을 먼저 시도
                if let date = milliFormatter.date(from: dateString) {
                    return date
                }
                // 밀리초 없는 형식을 시도
                if let date = basicFormatter.date(from: dateString) {
                    return date
                }
                
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid date format: \(dateString)"
                )
            }
            return try decoder.decode(Schedule.self, from: data)
        },
        
        editSchedule: { schedule in
            let url = URL(string: "https://sole-organic-singularly.ngrok-free.app/api/v1/schedules/\(schedule.id)")!
            
            print("\(schedule.id)번 일정 수정 시작")
            
            var request = URLRequest(url: url)
            request.httpMethod = HTTPMethod.put.rawValue
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            
            let jsonData = try JSONSerialization.data(withJSONObject: [
                "id": schedule.id,
                "memberId": 1,
                "contents": schedule.contents,
                "startScheduleDate": dateFormatter.string(from: schedule.startScheduleDate),
                "endScheduleDate": dateFormatter.string(from: schedule.endScheduleDate),
                "isAlarm": schedule.isAlarm,
                "alarmTime": dateFormatter.string(from: schedule.alarmTime)
            ], options: [])
            
            request.httpBody = jsonData
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse {
                print("HTTP Status Code: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("Response Body: \(responseString)")
                }
            }
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                throw URLError(.badServerResponse)
            }
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .custom { decoder in
                let container = try decoder.singleValueContainer()
                let dateString = try container.decode(String.self)
                
                // 밀리초 포함 형식 (yyyy-MM-dd'T'HH:mm:ss.SSS)
                let milliFormatter = DateFormatter()
                milliFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                milliFormatter.locale = Locale(identifier: "en_US_POSIX")
                milliFormatter.timeZone = TimeZone(identifier: "UTC")
                
                // 밀리초 없는 형식 (yyyy-MM-dd'T'HH:mm:ss)
                let basicFormatter = DateFormatter()
                basicFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                basicFormatter.locale = Locale(identifier: "en_US_POSIX")
                basicFormatter.timeZone = TimeZone(identifier: "UTC")
                
                // 밀리초 포함 형식을 먼저 시도
                if let date = milliFormatter.date(from: dateString) {
                    return date
                }
                // 밀리초 없는 형식을 시도
                if let date = basicFormatter.date(from: dateString) {
                    return date
                }
                
                throw DecodingError.dataCorruptedError(
                    in: container,
                    debugDescription: "Invalid date format: \(dateString)"
                )
            }
            return try decoder.decode(Schedule.self, from: data)
        }
    )
}

private func fetch<T: Decodable>(url: URL, model: T.Type, method: HTTPMethod) async throws -> T {
    var request = URLRequest(url: url)
    request.httpMethod = method.rawValue
    
    let (data, response) = try await URLSession.shared.data(for: request)
    guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
        throw URLError(.badServerResponse)
    }
    
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .custom { decoder in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        let milliFormatter = DateFormatter()
        milliFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        milliFormatter.locale = Locale(identifier: "en_US_POSIX")
        milliFormatter.timeZone = TimeZone(identifier: "UTC")
        
        let basicFormatter = DateFormatter()
        basicFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        basicFormatter.locale = Locale(identifier: "en_US_POSIX")
        basicFormatter.timeZone = TimeZone(identifier: "UTC")
        
        if let date = milliFormatter.date(from: dateString) {
            return date
        }
        if let date = basicFormatter.date(from: dateString) {
            return date
        }
        
        throw DecodingError.dataCorruptedError(
            in: container,
            debugDescription: "Invalid date format: \(dateString)"
        )
    }
    
    return try decoder.decode(T.self, from: data)
}

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
}
