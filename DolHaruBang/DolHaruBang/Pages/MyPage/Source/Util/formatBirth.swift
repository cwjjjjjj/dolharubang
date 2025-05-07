//
//  formatBirth.swift
//  DolHaruBang
//
//  Created by 양희태 on 5/8/25.
//

func formattedBirthday(_ birthday: String) -> String {
    if birthday.count == 8, let _ = Int(birthday) {
        let year = birthday.prefix(4)
        let month = birthday.dropFirst(4).prefix(2)
        let day = birthday.suffix(2)
        return "\(year)년 \(month)월 \(day)일"
    } else {
        return birthday
    }
}
