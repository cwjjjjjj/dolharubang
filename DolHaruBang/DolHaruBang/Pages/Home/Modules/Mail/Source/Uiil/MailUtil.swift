//
//  MailUtil.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/26/24.
//

// 메일 타입에 따른 이미지 선택 함수
func getImageName(for mailType: String) -> String {
    switch mailType {
//    case "Read":
//        return "ReadMail" // 프로모션 이미지 파일명
    case "RECEIVED_CLOVER":
        return "CloverMail" // 클로버 이미지 파일명
    case "SCHEDULE_ALERT":
        return "CalendarMail" // 달력 이미지 파일명
    case "FRIEND_REQUEST":
        return "SystemMail" // 시스템 이미지 파일명인데 일단 친구로
    case "MISSION_COMPLETED":
        return "TrophyMail" // 업적 이미지 파일명
    default:
        return "ReadMail" // 기본 이미지 파일명
    }
}

extension String {
    func splitCharacter() -> String {
        return self.split(separator: "").joined(separator: "\u{200B}")
    }
}
