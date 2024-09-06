//
//  CalendarUtil.swift
//  DolHaruBang
//
//  Created by 안상준 on 8/30/24.
//

import Foundation

let dateFormatterYear: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년"
    return formatter
}()

let dateFormatterMonth: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "M월"
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

let days = ["일", "월", "화", "수", "목", "금", "토"]
