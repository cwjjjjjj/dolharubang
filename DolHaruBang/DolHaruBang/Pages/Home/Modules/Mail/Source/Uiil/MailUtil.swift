//
//  MailUtil.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/26/24.
//
import Foundation

// 메일 타입에 따른 이미지 선택 함수
func getImageName(for mailType: String) -> String {
    switch mailType {
//    case "Read":
//        return "ReadMail" // 프로모션 이미지 파일명
    case "readMail":
        return "ReadMail"
    case "RECEIVED_CLOVER":
        return "CloverMail" // 클로버 이미지 파일명
    case "SCHEDULE_ALERT":
        return "CalendarMail" // 달력 이미지 파일명
    case "FRIEND_ACCEPTED":
        return "FriendMail" // 시스템 이미지 파일명인데 일단 친구로
    case "FRIEND_REQUEST":
        return "FriendMail" // 시스템 이미지 파일명인데 일단 친구로
    case "MISSION_COMPLETED":
        return "TrophyMail" // 업적 이미지 파일명
    case "WELCOME":
        return "SystemMail" // 시스템 이미지 파일명
    default:
        return "ReadMail" // 기본 이미지 파일명
    }
}

// 메일 타입에 따른 이미지 선택 함수
func getSelectImageName(for mailType: String) -> String {
    switch mailType {
//    case "Read":
//        return "ReadMail" // 프로모션 이미지 파일명
    case "RECEIVED_CLOVER":
        return "Clover" // 클로버 이미지 파일명
    case "SCHEDULE_ALERT":
        return "Calendar" // 달력 이미지 파일명
    case "FRIEND_ACCEPTED":
        return "Trophy" // 시스템 이미지 파일명인데 일단 친구로
    case "FRIEND_REQUEST":
        return "Clover" // 시스템 이미지 파일명인데 일단 친구로
    case "MISSION_COMPLETED":
        return "Trophy" // 업적 이미지 파일명
    case "WELCOME":
        return "Clover" // 시스템 이미지 파일명
    default:
        return "ReadMail" // 기본 이미지 파일명
    }
}

extension String {
    func splitCharacter() -> String {
        return self.split(separator: "").joined(separator: "\u{200B}")
    }
}

    func formatRelativeTime(from backendDateString: String) -> String {
        // DateFormatter 세팅
          let dateFormatter = DateFormatter()
          dateFormatter.locale = Locale(identifier: "en_US_POSIX")
//          dateFormatter.timeZone = TimeZone(secondsFromGMT: 0) 이걸뺴니까되네
          dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSSSS"
          
          // 파싱 시도, 마이크로초 6자리
          var date = dateFormatter.date(from: backendDateString)
          
          // 파싱 실패 시(마이크로초 3자리 등), 포맷 변경해서 재시도
          if date == nil {
              print("실패1")
              dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
              date = dateFormatter.date(from: backendDateString)
          }
          // 파싱 실패 시(마이크로초 없는 경우), 포맷 변경해서 재시도
          if date == nil {
              
              print("실패2")
              dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
              date = dateFormatter.date(from: backendDateString)
          }
          // 그래도 실패하면 원본 반환
          guard let backendDate = date else { return backendDateString }
          
          let now = Date()
          let diff = now.timeIntervalSince(backendDate)
          let minute = 60.0
          let hour = 60 * minute
          let day = 24 * hour
          
          if diff < day {
              if diff < hour {
                  let minutes = Int(diff / minute)
                  return "\(minutes)분전"
              } else {
                  let hours = Int(diff / hour)
                  return "\(hours)시간전"
              }
          } else if diff < 3 * day {
              let days = Int(diff / day)
              return "\(days)일전"
          } else {
              let outputFormatter = DateFormatter()
              outputFormatter.dateFormat = "yyyy-MM-dd"
              return outputFormatter.string(from: backendDate)
          }
      }
