//
//  CalendarUtil.swift
//  DolHaruBang
//
//  Created by 안상준 on 8/30/24.
//

import Foundation
import SwiftUI
import ComposableArchitecture

let dateFormatterYear: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy"
    return formatter
}()

let dateFormatterMonth: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "M"
    return formatter
}()

let dateFormatterDay: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "d"
    return formatter
}()

let dateFormatterWeekday: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "EEEE" // "EEEE"는 전체 요일 이름, "EEE"는 약어 요일 이름
    formatter.locale = Locale(identifier: "ko_KR") // 한글로 요일 표시
    return formatter
}()

let daysOfTheWeek = ["일", "월", "화", "수", "목", "금", "토"]

func formattedDate(_ date: Date, _ showDateComponents: Bool) -> String {
    let year = dateFormatterYear.string(from: date)
    let month = dateFormatterMonth.string(from: date)
    let day = dateFormatterDay.string(from: date)
    let weekday = dateFormatterWeekday.string(from: date)
    
    if showDateComponents {
        return "\(year)년 \(month)월 \(day)일 \(weekday)"
    } else {
        return "\(weekday)"
    }
}

func formattedDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.M.d"
    formatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일 설정
    return formatter.string(from: date)
}

func formattedDate(from string: String) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    
    var date: Date? = formatter.date(from: string)
    if date == nil {
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        date = formatter.date(from: string)
    }
    if date == nil {
        formatter.dateFormat = "yyyy-MM-dd"
        date = formatter.date(from: string)
    }
    if let date = date {
        return formattedDate(date) // 이미 있는 formattedDate(_: Date) 사용
    } else {
        return string.components(separatedBy: "T").first ?? string
    }
}

func formattedFloatingDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "a hh시 mm분" // "a"는 오전/오후를 나타냅니다.
    return formatter.string(from: date)
}

// 현재 월의 날짜 배열을 반환
func daysInMonth(calendar: Calendar, store: StoreOf<CalendarFeature>) -> [Date?] {
    // 특정 날짜(currentDate)를 기준으로 해당 달의 일(day) 수의 범위를 반환
    guard let range = calendar.range(of: .day, in: .month, for: store.currentDate) else { return [] } // 1 ~ 29,30,31
    let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: store.currentDate))! // 해당 월의 시작 날짜 // day를 비워두면 1일로 자동 설정
    let firstWeekday = calendar.component(.weekday, from: startOfMonth) - 1 // 월의 첫번째 요일 // 1 - 일요일 // 7 - 토요일// 따라서 배열 인덱스로 쓰려면 1 빼주기!

    var days: [Date?] = Array(repeating: nil, count: firstWeekday) // 첫번째 요일 값 만큼의 빈 공간 설정으로 초기화
    for day in range {
        let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth)!
        days.append(date)
    }

    let additionalDays = (7 - days.count % 7) % 7 // 달력의 마지막줄 남은 부분 nil로 채우기 위함
    days += Array(repeating: nil, count: additionalDays)
    
    return days
}

// 이전 월 텍스트 반환
func previousMonthText(calendar: Calendar, store: StoreOf<CalendarFeature>) -> String {
    let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: store.currentDate)!
    return dateFormatterMonth.string(from: previousMonthDate) + "월"
}

// 다음 월 텍스트 반환
func nextMonthText(calendar: Calendar, store: StoreOf<CalendarFeature>) -> String {
    let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: store.currentDate)!
    return dateFormatterMonth.string(from: nextMonthDate) + "월"
}

// KST 시간대로 Date 객체를 인코딩하는 커스텀 전략을 제공하는 함수
func kstDateEncodingStrategy() -> JSONEncoder.DateEncodingStrategy {
    return .custom { date, encoder in
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        let dateString = formatter.string(from: date)
        var container = encoder.singleValueContainer()
        try container.encode(dateString)
    }
}

// KST 시간대로 문자열을 Date 객체로 디코딩하는 커스텀 전략을 제공하는 함수
func kstDateDecodingStrategy() -> JSONDecoder.DateDecodingStrategy {
    return .custom { decoder in
        let container = try decoder.singleValueContainer()
        let dateString = try container.decode(String.self)
        
        let milliFormatter = DateFormatter()
        milliFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        milliFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        let basicFormatter = DateFormatter()
        basicFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        basicFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
        
        if let date = milliFormatter.date(from: dateString) {
            return date
        }
        if let date = basicFormatter.date(from: dateString) {
            return date
        }
        throw DecodingError.dataCorruptedError(in: container, debugDescription: "Invalid date format: \(dateString)")
    }
}

// 일반화된 인코딩 함수
func encodeWithKST<T: Encodable>(_ value: T, additionalFields: [String: Any]? = nil, debug: Bool = false) throws -> Data {
    if debug {
        print("--------------------------------------------------------------------------")
        print("Encoding \(T.self)...")
        print("--------------------------------------------------------------------------")
        
        // 디버깅용 KST 시간 출력
        if let dateContainingObject = value as? Schedule {
            let kstFormatter = DateFormatter()
            kstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            kstFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            
            print("<<인코딩 전, KST 기준 일정 시간>>")
            print("startScheduleDate: \(kstFormatter.string(from: dateContainingObject.startScheduleDate))")
            print("endScheduleDate: \(kstFormatter.string(from: dateContainingObject.endScheduleDate))")
            print("alarmTime: \(kstFormatter.string(from: dateContainingObject.alarmTime))")
        }
    }
    
    // JSONEncoder 설정
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = kstDateEncodingStrategy()
    
    // 기본 인코딩
    let jsonData = try encoder.encode(value)
    
    // 추가 필드가 있는 경우 처리
    if let additionalFields = additionalFields, !additionalFields.isEmpty {
        var jsonDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as! [String: Any]
        for (key, value) in additionalFields {
            jsonDict[key] = value
        }
        let finalData = try JSONSerialization.data(withJSONObject: jsonDict)
        
        if debug, let jsonString = String(data: finalData, encoding: .utf8) {
            print("Request Body: \(jsonString)")
        }
        
        return finalData
    }
    
    if debug {
        print("--------------------------------------------------------------------------")
        print("Encoding Ends...")
        print("--------------------------------------------------------------------------")
    }
    
    return jsonData
}
