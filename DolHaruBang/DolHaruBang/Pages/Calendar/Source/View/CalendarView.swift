import SwiftUI
import ComposableArchitecture

struct CalendarView: View {
    @State var store: StoreOf<CalendarFeature>
    
    var calendar = Calendar.current

    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let coverHeight = 72.0
            let calendarHeight = totalHeight * 580 / 852

            ZStack {
                Image(Background(rawValue: store.selectedBackground.rawValue)!.fileName)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Spacer().frame(height: totalHeight * 77 / 852)
                    
                    HStack {
                        Spacer()

                        Text("달력")
                            .padding(.bottom , 15)
                            .font(Font.customFont(Font.h6))
                            .shadow(radius: 4,x:0,y: 1)
                            .frame(width: geometry.size.width * 0.4, alignment: .center)
                        
                        Spacer()
                    }
                    
                    Spacer().frame(height: totalHeight * 8 / 852)
                    
                    ZStack {
                        Image("CalendarCover")
                            .resizable()
                            .frame(height: coverHeight)
                            .ignoresSafeArea()
                            .cornerRadius(15, corners: [.topLeft, .topRight])
                        
                        // 현재 년월
                        VStack {
                            Spacer().frame(height: 16)
                            
                            Text(dateFormatterYear.string(from: store.currentDate))
                                .font(.customFont(Font.body3Regular))
                                .overlay(
                                    ShadowView(
                                        color: UIColor(Color(hex: "7F501A")),
                                        alpha: 0.6,
                                        x: 0,
                                        y: 0,
                                        blur: 4,
                                        spread: 0,
                                        isInnerShadow: false
                                    )
                                    .compositingGroup()
                                )
                            
                            Text(dateFormatterMonth.string(from: store.currentDate))
                                .font(.customFont(Font.h6))
                                .overlay(
                                    ShadowView(
                                        color: UIColor(Color(hex: "7F501A")),
                                        alpha: 0.6,
                                        x: 0,
                                        y: 0,
                                        blur: 4,
                                        spread: 0,
                                        isInnerShadow: false
                                    )
                                    .compositingGroup()
                                )
                            Spacer().frame(height: 10)
                        }
                        
                        // 달력 고리 부분
                        HStack {
                            Image("CalendarHanger")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: totalHeight * 35 / 852)
                            Spacer().frame(width: 95)
                            Image("CalendarHanger")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: totalHeight * 35 / 852)
                        }
                        .compositingGroup()
                        .zIndex(5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .offset(y: -28)
                        
                        // 달력 이전 / 다음 월 버튼 부분
                        HStack {
                            Button(action: {
                                store.send(.changeMonth(by: -1))
                            }) {
                                Image("backIconWhite")
                                    .resizable()
                                    .frame(width: 16, height: 24)
                                    .overlay(
                                        ShadowView(
                                            color: UIColor(Color(hex: "7F501A")),
                                            alpha: 0.6,
                                            x: 0,
                                            y: 0,
                                            blur: 4,
                                            spread: 0,
                                            isInnerShadow: false
                                        )
                                    )
                                Text(previousMonthText(calendar: calendar, store: store))
                                    .font(.customFont(Font.body2Bold))
                                    .overlay(
                                        ShadowView(
                                            color: UIColor(Color(hex: "7F501A")),
                                            alpha: 0.6,
                                            x: 0,
                                            y: 0,
                                            blur: 4,
                                            spread: 0,
                                            isInnerShadow: false
                                        )
                                    )
                            }
                            .buttonStyle(PlainButtonStyle())
                            Spacer()
                            Button(action: {
                                store.send(.changeMonth(by: +1))
                            }) {
                                Text(nextMonthText(calendar: calendar, store: store))
                                    .font(.customFont(Font.body2Bold))
                                    .modifier(CustomShadowModifier(
                                        color: Color(hex: "7F501A"),
                                        alpha: 0.6,
                                        x: 0,
                                        y: 0,
                                        blur: 4,
                                        spread: 0,
                                        isInnerShadow: false
                                    ))
                                Image("backIconWhite")
                                    .resizable()
                                    .frame(width: 16, height: 24)
                                    .rotationEffect(.degrees(180))
                                    .modifier(CustomShadowModifier(
                                        color: Color(hex: "7F501A"),
                                        alpha: 0.6,
                                        x: 0,
                                        y: 0,
                                        blur: 4,
                                        spread: 0,
                                        isInnerShadow: false
                                    ))
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 20)
                        .offset(y: 12)
                    } // 커버 부분 ZStack
                    .compositingGroup()
                    .frame(height: coverHeight)
                    
                    // 달력 요일 및 날짜 부분
                    CalendarGridView(
                        daysInMonth: daysInMonth(calendar: calendar, store: store),
                        records: $store.records,
                        selectedDate: $store.selectedDate,
                        showPopup: $store.showPopup
                    )
                    .frame(height: calendarHeight) // 남은 공간을 요일 및 날짜 부분으로 설정
                    .background(Color.coreWhite.gradient.shadow(.drop(color: Color(hex: "CECECE").opacity(0.5), radius: 10, x: 0, y: 4)))
                    .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                    
                    Spacer().frame(minHeight: totalHeight * 64 / 804)
                }
                .background(Color.clear)
                
                if store.state.showPopup {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            store.send(.togglePopup(false))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(1)
                    RecordPopupView(
                        date: store.selectedDate ?? Date(),
                        records: $store.records,
                        showPopup: $store.showPopup
                    )
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(radius: 10)
                        .zIndex(2)
                }
                
            }
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarBackButtonHidden(true)
    }
}


//struct CalendarGridView: View {
//    // 달력 표시 날짜 배열
//    let daysInMonth: [Date?]
//    // 달력 표시 일정 - 날짜별 문자열
//    @Binding var records: [Date: [String]]
//    // 선택된 날짜
//    @Binding var selectedDate: Date?
//    // 일정 팝업 표시 여부
//    @Binding var showPopup: Bool
//
//    private let calendar = Calendar.current
//
//    var body: some View {
//        VStack(spacing: 0) {
//            // 일~토 요일 표시
//            HStack(spacing: 0) {
//                ForEach(0..<days.count, id: \.self) { index in
//                    Text(days[index])
//                        .font(.customFont(Font.body3Bold))
//                        .frame(maxWidth: .infinity)
//                        .foregroundColor(index == 0 ? Color(hex:"E16631") : .coreDisabled)
//                }
//            }
//            .frame(height: 35)
//
//            Divider()
//                .background(Color(hex: "E5DFD7"))
//
//            // 7일씩 나눠서 주단위로 나눔
//            let rows = Array(daysInMonth.chunked(into: 7))
//            
//            // 각 주마다
//            ForEach(rows.indices, id: \.self) { rowIndex in
//                
//                // 한 줄을 차지함
//                HStack(spacing: 0) {
//                    
//                    // 각 날짜 별 칸은 곧 버튼
//                    ForEach(rows[rowIndex].indices, id: \.self) { index in
//                        
//                        Button(action: {
//                            if let date = rows[rowIndex][index] {
//                                selectedDate = date
//                                showPopup = true
//                                print("Button tapped: \(selectedDate!), showPopup: \(showPopup)")
//                            }
//                        }) {
//                            if let date = rows[rowIndex][index] {
//                                VStack {
//                                    Spacer().frame(height: 8)
//                                    Text(dateFormatterDay.string(from: date))
//                                        .font(.customFont(Font.body3Bold))
//                                        .foregroundColor(index == 0 ? Color(hex:"E16631") : .coreDisabled)
//                                        .gridColumnAlignment(.leading)
//                                    
//                                    // 기록 동그라미
//                                    HStack {
//                                        if let dayRecords = records[date] {
//                                            ForEach(0..<dayRecords.count, id: \.self) { recordIndex in
//                                                Circle()
//                                                    .fill(circleColors[recordIndex])
//                                                    .frame(width: 10, height: 10)
//                                            }
//                                        }
//                                    }
//                                    Spacer()
//                                }
//                                .frame(maxWidth: .infinity, maxHeight: .infinity)
//                                .contentShape(Rectangle())
//                            }
//                            else {
//                                Spacer()
//                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
//                            }
//                        }
//                        .buttonStyle(PlainButtonStyle())
//                    }
//                }
//                .padding(.vertical, 5)
//                
//                if rowIndex < rows.count - 1 {
//                    Divider()
//                        .foregroundColor(Color(hex: "E5DFD7"))
//                }
//                
//            }
//        } // end of VStack
//        .padding(.vertical, 0)
//        .onAppear {
//            print("Days in month: \(daysInMonth)")
//        }
//    }
//}

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
