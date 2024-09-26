//
//  MailUtil.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/26/24.
//

// 메일 타입에 따른 이미지 선택 함수
func getImageName(for mailType: String) -> String {
    switch mailType {
    case "Read":
        return "ReadMail" // 프로모션 이미지 파일명
    case "Clover":
        return "CloverMail" // 업데이트 이미지 파일명
    case "Calendar":
        return "CalendarMail" // 소셜 이미지 파일명
    case "System":
        return "SystemMail" // 소셜 이미지 파일명
    case "Trophy":
        return "TrophyMail" // 소셜 이미지 파일명
    default:
        return "defaultImage" // 기본 이미지 파일명
    }
}

extension String {
    func splitCharacter() -> String {
        return self.split(separator: "").joined(separator: "\u{200B}")
    }
}
