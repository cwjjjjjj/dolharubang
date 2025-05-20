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
    var fetchSchedules: @Sendable (Int, Int) async throws -> [Schedule]
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
        fetchSchedules: { year, month in
            var url = APIConstants.Endpoints.schedule
            var queryItems: [String] = []
            
            // 필수 파라미터 추가
            queryItems.append("year=\(year)")
            queryItems.append("month=\(month)")
            
            // 쿼리 파라미터 URL에 추가
            if !queryItems.isEmpty {
                url += "?" + queryItems.joined(separator: "&")
            }
            
            return try await fetch(url: url, model: [Schedule].self, method: .get)
        },
        
        addSchedule: { schedule in
            let url = APIConstants.Endpoints.schedule
            let jsonData = try encodeWithKST(schedule, debug: true)
            return try await fetch(url: url, model: Schedule.self, method: .post, body: jsonData)
        },
        
        editSchedule: { schedule in
            let url = APIConstants.Endpoints.schedule + "/\(schedule.id)"
            print("\(schedule.id)번 일정 수정 요청")
            let jsonData = try encodeWithKST(schedule, debug: true)
            return try await fetch(url: url, model: Schedule.self, method: .patch, body: jsonData)
        },

        deleteSchedule: { scheduleId in
            let url = APIConstants.Endpoints.schedule + "/\(scheduleId)"
            print("\(scheduleId)번 일정 삭제 요청")
            _ = try await fetch(url: url, model: EmptyResponse.self, method: .delete)
        }
    )
}


