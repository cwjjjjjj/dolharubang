//
//  Color.swift
//  DolHaruBang
//
//  Created by 안상준 on 7/29/24.
//

import SwiftUI

// 일정 표시용 색상 배열
let circleColors: [Color] = [.coreBlue, .coreGreen, Color(hex:"F8BA99")] // 일정 표시용 색상들

extension Color {
    static let mainGreen = Color("coreGreen")
    static let mainDarkGreen = Color("coreDarkGreen")
    static let mainBrown = Color("coreBrown")
    static let mainBlue = Color("coreBlue")
    
    static let mainWhite = Color("coreWhite") // FBFAF7
    static let whiteWhite = Color("ffffff")
    static let mainBlack = Color("coreBlack")
    static let mainGray = Color("coreGray") // F2EEE7
    static let mainLightGray = Color("coreLightGray") // C8BEB2
    static let disabled = Color("coreDisabled") // 837C74
    
    static let pointColor = Color("PointColor")
    static let placeHolder = Color(hex:"C8BEB2")
    
    static let ability1 = Color(hex:"FFFA80")
    static let ability2 = Color(hex:"FF9900")
    static let commit = Color(hex:"A5CD3B")
    static let semigray = Color(hex:"F2eee7")
    
    static let mainTop = Color(hex: "D2FAFF")
    static let decoSheetTabbar = Color(hex: "837C74")
    static let decoSheetGreen = Color(hex: "618501")
    static let decoSheetTextColor = Color(hex: "372A1A")
    
    static let calendarCover = Color(hex: "C68F4E")
    static let calendarHanger = Color(hex: "D7D7D7")
    static let calendarHangerRing = Color(hex: "7F501A")
}
