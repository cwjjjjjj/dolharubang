import SwiftUI
import ComposableArchitecture

struct CalendarView: View {
    @State private var currentDate = Date() // 현재 날짜
    @State private var selectedDate: Date? = nil // 선택된 날짜
    @State private var records: [Date: [String]] = [:] // 날짜별로 일정 저장
    @State private var showPopup = false // 일정 작성용 팝업 표시 여부

    private let calendar = Calendar.current // 현재 Locale의 캘린더 객체

    // 현재 월의 날짜 배열을 반환
    private var daysInMonth: [Date?] {
        // 특정 날짜(currentDate)를 기준으로 해당 달의 일(day) 수의 범위를 반환
        guard let range = calendar.range(of: .day, in: .month, for: currentDate) else { return [] } // 1 ~ 29,30,31
        let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate))! // 해당 월의 시작 날짜 // day를 비워두면 1일로 자동 설정
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
    
    // 이전 월
    private func previousMonthText() -> String {
        let previousMonthDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
        return dateFormatterMonth.string(from: previousMonthDate)
    }

    // 다음 월
    private func nextMonthText() -> String {
        let nextMonthDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
        return dateFormatterMonth.string(from: nextMonthDate)
    }

    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let calendarHeight = totalHeight
            let coverHeight = calendarHeight * 72 / 608
            
            ZStack {
                VStack(spacing: 0) {
                    
                    ZStack {
                        
                        // 달력 커버
//                        Rectangle()
//                            .fill(Color.calendarCover)
//                            .frame(height: coverHeight)
//                            .clipShape(
//                                RoundedCorner(radius: 15, corners: [.topLeft, .topRight])
//                            )
//                        .overlay(
//                            ShadowView(
//                                color: UIColor(Color(hex: "794F1D")),
//                                alpha: 0.5,
//                                x: -1,
//                                y: -1,
//                                blur: 7,
//                                spread: 0,
//                                isInnerShadow: true
//                            )
//                            .clipShape(
//                                RoundedCorner(radius: 15, corners: [.topLeft, .topRight])
//                            )
//                        )
//                        .overlay(
//                            ShadowView(
//                                color: UIColor(Color(hex: "F5D0A4")),
//                                alpha: 1.0,
//                                x: 1,
//                                y: 1,
//                                blur: 7,
//                                spread: 0,
//                                isInnerShadow: true
//                            )
//                            .clipShape(
//                                RoundedCorner(radius: 15, corners: [.topLeft, .topRight])
//                            )
//                        )
//                        .compositingGroup()
                        Image("CalendarCover")
                            .resizable()
                            .frame(height: coverHeight)
                            .ignoresSafeArea()
                            .cornerRadius(15, corners: [.topLeft, .topRight])
                        
                        // 현재 년월
                        VStack {
                            Spacer().frame(height: 16)
                            
                            Text(dateFormatterYear.string(from: currentDate))
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
                            
                            Text(dateFormatterMonth.string(from: currentDate))
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
                                .frame(width: 20, height: 35)
                            Spacer().frame(width: 95)
                            Image("CalendarHanger")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 20, height: 35)
                        }
                        .compositingGroup()
                        .zIndex(5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .offset(y: -24)
                        
                        // 달력 이전 / 다음 월 버튼 부분
                        HStack {
                            Button(action: {
                                currentDate = calendar.date(byAdding: .month, value: -1, to: currentDate)!
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
                                Text(previousMonthText())
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
                                currentDate = calendar.date(byAdding: .month, value: 1, to: currentDate)!
                            }) {
                                Text(nextMonthText())
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
                        .offset(y: 8)
                    } // 커버 부분 ZStack
                    .compositingGroup()
                    .frame(height: coverHeight)
                    
                    // 달력 요일 및 날짜 부분
                    CalendarGridView(daysInMonth: daysInMonth, records: $records, selectedDate: $selectedDate, showPopup: $showPopup)
                        .frame(height: calendarHeight - coverHeight) // 남은 공간을 요일 및 날짜 부분으로 설정
                        .background(Color.coreWhite.gradient.shadow(.drop(color: Color(hex: "CECECE").opacity(0.5), radius: 10, x: 0, y: 4)))
                    
                }
                .padding(.top, 8)
                .background(Color.clear)
                .cornerRadius(15)
                .frame(height: calendarHeight)
                
                if showPopup {
                    Color.black.opacity(0.3)
                        .ignoresSafeArea()
                        .onTapGesture {
                            showPopup = false
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .zIndex(1)
                    RecordPopupView(date: selectedDate ?? Date(), records: $records, showPopup: $showPopup)
                        .background(Color.white)
                        .cornerRadius(25)
                        .shadow(radius: 10)
                        .zIndex(2)
                }
                
            }
            
        }
    }
}


struct CalendarGridView: View {
    // 달력 표시 날짜 배열
    let daysInMonth: [Date?]
    // 달력 표시 일정 - 날짜별 문자열
    @Binding var records: [Date: [String]]
    // 선택된 날짜
    @Binding var selectedDate: Date?
    // 일정 팝업 표시 여부
    @Binding var showPopup: Bool

    private let calendar = Calendar.current

    var body: some View {
        VStack(spacing: 0) {
            
            // 일~토 요일 표시
            HStack(spacing: 0) {
                ForEach(0..<days.count, id: \.self) { index in
                    Text(days[index])
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
                                        if let dayRecords = records[date] {
                                            ForEach(0..<dayRecords.count, id: \.self) { recordIndex in
                                                Circle()
                                                    .fill(circleColors[recordIndex])
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
                                    .onAppear {
                                        print("nothing!")
                                    }
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.vertical, 5)
                
                if rowIndex < rows.count - 1 {
                    Divider()
                        .background(Color(hex: "E5DFD7"))
                }
                
            }
        } // end of VStack
        .padding(.vertical, 0)
        .onAppear {
            print("Days in month: \(daysInMonth)")
        }
    }
}

struct RecordPopupView: View {
    var date: Date
    @Binding var records: [Date: [String]] // 일정
    @Binding var showPopup: Bool // 팝업 표시 여부
    @State private var newRecord: String = "" // 작성 중 일정
    @FocusState private var isTextFieldFocused: Bool // 텍스트 필드 포커스 상태 관리

    // 일정 작성 관련 시작/종료 시간 및 오전/오후
    @State private var startHour: Int = Calendar.current.component(.hour, from: Date()) % 12
    @State private var startMinute: Int = Calendar.current.component(.minute, from: Date())
    @State private var endHour: Int = Calendar.current.component(.hour, from: Date()) % 12
    @State private var endMinute: Int = Calendar.current.component(.minute, from: Date())
    @State private var startPeriod: String = Calendar.current.component(.hour, from: Date()) < 12 ? "오전" : "오후"
    @State private var endPeriod: String = Calendar.current.component(.hour, from: Date()) < 12 ? "오전" : "오후"

    // 일정 표시용 색상 배열
    let circleColors: [Color] = [.coreBlue, .coreGreen, Color(hex:"F8BA99")]

    // 편집 상태
    @State private var isEditingRecord: Bool = false
    @State private var editingRecordIndex: Int? = nil // 현재 편집 중인 일정의 인덱스
    @State private var recordCount: Int = 0 // 일정 갯수

    // Picker 상태 관리
    @State private var showStartPicker: Bool = false // 시작 시간 선택기 표시 여부
    @State private var showEndPicker: Bool = false // 종료 시간 선택기 표시 여부

    var formattedDate: String {
        let year = dateFormatterYear.string(from: date)
        let month = dateFormatterMonth.string(from: date)
        let day = dateFormatterDay.string(from: date)
        let weekday = dateFormatterWeekday.string(from: date)

        return "\(year) \(month) \(day)일 \(weekday)"
    }
    
    private func isValidTimeRange() -> Bool {
        let startTimeInMinutes = (startHour % 12) * 60 + startMinute + (startPeriod == "오후" ? 720 : 0)
        let endTimeInMinutes = (endHour % 12) * 60 + endMinute + (endPeriod == "오후" ? 720 : 0)
        return endTimeInMinutes > startTimeInMinutes
    }

    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 24)
            
            HStack {
                Text(formattedDate)
                    .font(Font.customFont(Font.subtitle3))
                    .foregroundColor(.decoSheetGreen)
                    .padding(.leading, 24)
                
                Spacer()
                
                Button(action: {
                    showPopup = false
                    resetFields()
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.placeHolder)
                }
                .padding(.trailing, 24)
            }
            
            Spacer().frame(height: 20)
            
            Divider()
            
            if isEditingRecord {
                editRecordView() // 일정 편집 모드일 때만 보이는 뷰
            } else {
                if recordCount == 0 {
                    addRecordView(color: circleColors[0]) // 일정이 없을 때 추가용 뷰
                } else {
                    showRecordsView() // 일정이 하나 이상 있을 때 일정 목록
                    if recordCount < 3 {
                        addRecordView(color: circleColors[recordCount]) // 일정이 3개 미만일 때 추가용 뷰
                    }
                }
            }
            
            Spacer()
        }
        .frame(width: 320, height: 320)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 10)
        .onAppear {
            recordCount = records[date]?.count ?? 0
        }
        .onChange(of: records) { _ in
            recordCount = records[date]?.count ?? 0
        }
        .sheet(isPresented: $showStartPicker) {
            TimePickerSheetView(
                hour: $startHour,
                minute: $startMinute,
                period: $startPeriod,
                title: "시작 시간",
                onConfirm: {
                    showStartPicker = false
                    // 종료 시간이 시작 시간보다 이전인지 확인
                    if !isValidTimeRange() {
                        endHour = startHour
                        endMinute = startMinute
                        endPeriod = startPeriod
                    }
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showEndPicker) {
            TimePickerSheetView(
                hour: $endHour,
                minute: $endMinute,
                period: $endPeriod,
                title: "종료 시간",
                // 시작 시간이 종료 시간보다 이후인지 확인
                onConfirm: {
                    showEndPicker = false
                    if !isValidTimeRange() {
                        endHour = startHour
                        endMinute = startMinute
                        endPeriod = startPeriod
                    }
                }
            )
            .presentationDetents([.medium])
        }
    }
    
    // 일정 추가용 뷰
    private func addRecordView(color: Color) -> some View {
        VStack {
            Spacer().frame(height: 20)
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 18, height: 18)
                
                SimpleCustomTextField(
                    text: $newRecord,
                    placeholder: "일정 추가",
                    placeholderColor: Color.placeHolder.toUIColor(),
                    textColor: Color.decoSheetTextColor.toUIColor(),
                    font: Font.uiFont(for: Font.body1Bold)!,
                    maxLength: 14,
                    onEditingChanged: { editing in
                        isTextFieldFocused = editing
                    }
                )
                .focused($isTextFieldFocused)

                
                if isTextFieldFocused {
                    Button(action: {
                        addRecord()
                        isTextFieldFocused = false
                    }) {
                        Image("completeIcon")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .padding(.trailing, 24)
                }
            }
            .padding(.leading, 24)
            
            if isTextFieldFocused {
                timePickerView()
            }
        }
    }
    
    // 일정 편집용 뷰
    private func editRecordView() -> some View {
        VStack {
            Spacer().frame(height: 20)
            HStack {
                Circle()
                    .fill(circleColors[editingRecordIndex ?? 0])
                    .frame(width: 18, height: 18)
                
                SimpleCustomTextField(
                    text: $newRecord,
                    placeholder: "일정 수정",
                    placeholderColor: Color.placeHolder.toUIColor(),
                    textColor: Color.decoSheetTextColor.toUIColor(),
                    font: Font.uiFont(for: Font.body1Bold)!,
                    maxLength: 14,
                    onEditingChanged: { editing in
                        isTextFieldFocused = editing
                    }
                )
                .focused($isTextFieldFocused)
                
                if isTextFieldFocused {
                    Button(action: {
                        if let index = editingRecordIndex {
                            editRecord(at: index)
                        }
                        isTextFieldFocused = false
                    }) {
                        Image("completeIcon")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .padding(.trailing, 24)
                }
            }
            .padding(.leading, 24)
            
            if isTextFieldFocused {
                timePickerView()
            }
        }
    }
    
    // 일정 목록을 보여주는 뷰
    private func showRecordsView() -> some View {
        LazyVStack {
            ForEach(records[date]!.indices, id: \.self) { recordIndex in
                Spacer().frame(height: 20)
                HStack {
                    VStack(alignment: .leading, spacing: 0) {
                        let recordComponents = records[date]![recordIndex].split(separator: "-").map { String($0).trimmingCharacters(in: .whitespaces) }
                        
                        if recordComponents.count == 3 {
                            HStack(alignment: .top) {
                                Circle()
                                    .fill(circleColors[recordIndex % circleColors.count])
                                    .frame(width: 20, height: 20)
                                
                                Text(recordComponents[2])
                                    .font(Font.customFont(Font.body1Bold))
                                    .foregroundColor(.decoSheetTextColor)
                            }
                            
                            HStack {
                                Circle()
                                    .fill(.clear)
                                    .frame(width: 20, height: 20)
                                Text("\(recordComponents[0]) - \(recordComponents[1])")
                                    .font(Font.customFont(Font.body2Bold))
                                    .foregroundColor(.calendarCover)
                            }
                        }
                    }
                    
                    Spacer()
                    
                    VStack {
                        Button(action: {
                            enterEditMode(for: recordIndex)
                        }) {
                            Image("editIcon")
                                .resizable()
                                .frame(width: 20, height: 20)
                        }
                        Spacer()
                    }
                }
                .padding(.leading, 24)
                .padding(.trailing, 24)
            }
        }
    }
    
    // 시간 선택용 뷰
    private func timePickerView() -> some View {
        VStack(alignment: .leading) {
            Divider()
                .padding(.horizontal, 54)
                .padding(.bottom, 4)
            
            // 시작 시간 설정 버튼
            HStack(spacing: 0) {
                Text("시작")
                    .font(Font.customFont(Font.body2Bold))
                    .foregroundColor(.decoSheetTabbar)
                    .onTapGesture {
                        showStartPicker = true
                    }
                
                Spacer().frame(width: 8)
                
                Button(action: {
                    showStartPicker = true
                }) {
                    Text("\(startPeriod) \(startHour) : \(String(format: "%02d", startMinute)) ")
                        .font(Font.customFont(Font.body2Bold))
                        .foregroundColor(.calendarCover)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.leading, 52)
            
            Divider()
                .padding(.horizontal, 54)
                .padding(.bottom, 4)
            
            // 종료 시간 설정 버튼
            HStack(spacing: 0) {
                Text("종료")
                    .font(Font.customFont(Font.body2Bold))
                    .foregroundColor(.decoSheetTabbar)
                    .onTapGesture {
                        showEndPicker = true
                    }
                
                Spacer().frame(width: 8)
                
                Button(action: {
                    showEndPicker = true
                }) {
                    Text("\(endPeriod) \(endHour) : \(String(format: "%02d", endMinute))")
                        .font(Font.customFont(Font.body2Bold))
                        .foregroundColor(.calendarCover)
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.leading, 52)
            
            Divider()
                .padding(.horizontal, 56)
                .padding(.bottom, 4)
        }
    }

    private func addRecord() {
        if !newRecord.isEmpty {
            let startTime = "\(startPeriod) \(startHour):\(String(format: "%02d", startMinute))"
            let endTime = "\(endPeriod) \(endHour):\(String(format: "%02d", endMinute))"
            let record = "\(startTime) - \(endTime) - \(newRecord)"
            
            if records[date] != nil {
                records[date]?.append(record)
            } else {
                records[date] = [record]
            }
            
            resetFields()
        }
    }

    private func enterEditMode(for index: Int) {
        guard let recordComponents = records[date]?[index].split(separator: "-").map({ String($0).trimmingCharacters(in: .whitespaces) }) else { return }
        
        if recordComponents.count == 3 {
            let startComponents = recordComponents[0].split(separator: " ")
            let endComponents = recordComponents[1].split(separator: " ")
            
            if startComponents.count == 2, let startHourMinute = startComponents.last?.split(separator: ":"), startHourMinute.count == 2 {
                startPeriod = String(startComponents.first!)
                startHour = Int(startHourMinute[0]) ?? startHour
                startMinute = Int(startHourMinute[1]) ?? startMinute
            }
            
            if endComponents.count == 2, let endHourMinute = endComponents.last?.split(separator: ":"), endHourMinute.count == 2 {
                endPeriod = String(endComponents.first!)
                endHour = Int(endHourMinute[0]) ?? endHour
                endMinute = Int(endHourMinute[1]) ?? endMinute
            }
            
            newRecord = recordComponents[2]
            editingRecordIndex = index
            isEditingRecord = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                isTextFieldFocused = true
            }
        }
    }

    private func editRecord(at index: Int) {
        if !newRecord.isEmpty {
            let startTime = "\(startPeriod) \(startHour):\(String(format: "%02d", startMinute))"
            let endTime = "\(endPeriod) \(endHour):\(String(format: "%02d", endMinute))"
            let updatedRecord = "\(startTime) - \(endTime) - \(newRecord)"
            
            records[date]?[index] = updatedRecord
            
            resetFields()
        }
    }

    private func resetFields() {
        newRecord = ""
        isEditingRecord = false
        editingRecordIndex = nil
        isTextFieldFocused = false
    }
}

struct TimePickerSheetView: View {
    @Binding var hour: Int
    @Binding var minute: Int
    @Binding var period: String
    var title: String
    var onConfirm: () -> Void

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .padding()

            HStack {
                Picker("", selection: $period) {
                    Text("오전").tag("오전")
                    Text("오후").tag("오후")
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 80)
                .clipped()

                Picker("", selection: $hour) {
                    ForEach(1..<13) { hour in
                        Text("\(hour) 시").tag(hour)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 80)
                .clipped()

                Picker("", selection: $minute) {
                    ForEach(Array(stride(from: 0, to: 60, by: 5)), id: \.self) { minute in
                        Text(String(format: "%02d 분", minute)).tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(width: 80)
                .clipped()
            }
            .frame(height: 150)
            
            Button("확인") {
                onConfirm()
            }
            .padding()
        }
        .padding()
    }
}






extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0..<Swift.min($0 + size, count)])
        }
    }
}
