//
//  CalendarGridView.swift
//  DolHaruBang
//
//  Created by 안상준 on 9/11/24.
//

import SwiftUI

struct CalendarGridView: View {
    // 달력 표시 날짜 배열
    let daysInMonth: [Date?]
    // 달력 표시 일정 - 날짜별 문자열
    @Binding var schedules: [Date: [Schedule]]
    // 선택된 날짜
    @Binding var selectedDate: Date?
    // 일정 팝업 표시 여부
    @Binding var showPopup: Bool
    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 0) {
            // 일~토 요일 표시
            HStack(spacing: 0) {
                ForEach(0..<daysOfTheWeek.count, id: \.self) { index in
                    Text(daysOfTheWeek[index])
                        .font(.customFont(Font.body3Bold))
                        .frame(maxWidth: .infinity)
                        .foregroundColor(index == 0 ? Color(hex:"E16631") : .coreDisabled)
                }
            }
            .frame(height: 35)

            Divider()
                .background(Color(hex: "E5DFD7"))

            // 7일씩 나눠서 주단위로 나눔
            let rows = Array(daysInMonth.chunked(into: 7))
            
            // 각 주마다
            ForEach(rows.indices, id: \.self) { rowIndex in
                
                // 한 줄을 차지함
                HStack(spacing: 0) {
                    
                    // 각 날짜 별 칸은 곧 버튼
                    ForEach(rows[rowIndex].indices, id: \.self) { index in
                        
                        Button(action: {
                            if let date = rows[rowIndex][index] {
                                selectedDate = date
                                showPopup = true
                                print("Button tapped: \(selectedDate!), showPopup: \(showPopup)")
                            }
                        }) {
                            if let date = rows[rowIndex][index] {
                                VStack {
                                    Spacer().frame(height: 8)
                                    Text(dateFormatterDay.string(from: date))
                                        .font(.customFont(Font.body3Bold))
                                        .foregroundColor(index == 0 ? Color(hex:"E16631") : .coreDisabled)
                                        .gridColumnAlignment(.leading)
                                    
                                    // 기록 동그라미
                                    HStack {
                                        if let dailySchedules = schedules[date] {
                                            ForEach(0..<dailySchedules.count, id: \.self) { scheduleIndex in
                                                Circle()
                                                    .fill(circleColors[scheduleIndex])
                                                    .frame(width: 10, height: 10)
                                            }
                                        }
                                    }
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .contentShape(Rectangle())
                            }
                            else {
                                Spacer()
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 5)
                
                if rowIndex < rows.count - 1 {
                    Divider()
                        .foregroundColor(Color(hex: "E5DFD7"))
                }
                
            }
        }
        .padding(.vertical, 0)
    }
}
