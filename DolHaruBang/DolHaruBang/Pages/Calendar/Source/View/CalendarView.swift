import SwiftUI
import ComposableArchitecture

struct CalendarView: View {
    @State var store: StoreOf<CalendarFeature>
    
    var calendar = Calendar.current

    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height // 852
            let totalWidth = geometry.size.width // 375
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
                            Spacer().frame(width: totalWidth * 95 / 375)
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
                        schedules: $store.schedules,
                        selectedDate: $store.selectedDate,
                        showPopup: $store.showPopup
                    )
                    .frame(height: calendarHeight) // 남은 공간을 요일 및 날짜 부분으로 설정
                    .background(Color.coreWhite.gradient.shadow(.drop(color: Color(hex: "CECECE").opacity(0.5), radius: 10, x: 0, y: 4)))
                    .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
                    .onAppear() {
                        store.send(.fetchSchedulesForMonth(year: 2025, month: 2, memberId: 1))
                    }
                    
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
                    
                    SchedulePopupView(
                        store: store,
                        date: store.selectedDate ?? Date(),
                        schedules: $store.schedules,
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

extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
