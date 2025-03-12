import SwiftUI
import ComposableArchitecture

struct SchedulePopupView: View {
    let store: StoreOf<CalendarFeature>
    let date: Date
    @Binding var schedules: [Date: [Schedule]] // 일정
    @Binding var showPopup: Bool // 팝업 표시 여부
    @State private var newScheduleContent: String = "" // 작성 중 일정
    @FocusState private var isTextFieldFocused: Bool // 텍스트 필드 포커스 상태 관리
    
    @State private var startHour: Int
    @State private var startMinute: Int
    @State private var startPeriod: String
    @State private var endHour: Int
    @State private var endMinute: Int
    @State private var endPeriod: String

    // 일정 표시용 색상 배열
    let circleColors: [Color] = [.coreBlue, .coreGreen, Color(hex:"F8BA99")]

    // 편집 상태
    @State private var isEditingSchedule: Bool = false
    @State private var editingScheduleIndex: Int? = nil // 현재 편집 중인 일정의 인덱스
    private var ScheduleCount: Int { schedules[date]?.count ?? 0 } // 일정 갯수

    // Picker 상태 관리
    @State private var showStartPicker: Bool = false // 시작 시간 선택기 표시 여부
    @State private var showEndPicker: Bool = false // 종료 시간 선택기 표시 여부
    
    init(store: StoreOf<CalendarFeature>, date: Date, schedules: Binding<[Date: [Schedule]]>, showPopup: Binding<Bool>) {
        self.store = store
        self.date = date
        self._schedules = schedules
        self._showPopup = showPopup
        let calendar = Calendar.current
        let now = Date()
        self._startHour = State(initialValue: calendar.component(.hour, from: now) % 12)
        self._startMinute = State(initialValue: calendar.component(.minute, from: now))
        self._startPeriod = State(initialValue: calendar.component(.hour, from: now) < 12 ? "오전" : "오후")
        self._endHour = State(initialValue: calendar.component(.hour, from: now) % 12)
        self._endMinute = State(initialValue: calendar.component(.minute, from: now))
        self._endPeriod = State(initialValue: calendar.component(.hour, from: now) < 12 ? "오전" : "오후")
    }
    
    // 사용자가 수정한 시간이 시작 시간인지 종료 시간인지에 따라 알맞게 조정해주는 함수
    private func correctTime(isStartTimeEdited: Bool) {
        let startTimeInMinutes = (startHour % 12) * 60 + startMinute + (startPeriod == "오후" ? 720 : 0)
        let endTimeInMinutes = (endHour % 12) * 60 + endMinute + (endPeriod == "오후" ? 720 : 0)
        
        if endTimeInMinutes < startTimeInMinutes {
            if isStartTimeEdited {
                // 시작 시간이 편집된 경우, 종료 시간을 시작 시간에 맞춤
                endHour = startHour
                endMinute = startMinute
                endPeriod = startPeriod
                print("Adjusted - End: \(endPeriod) \(endHour):\(String(format: "%02d", endMinute))")
            } else {
                // 종료 시간이 편집된 경우, 시작 시간을 종료 시간에 맞춤
                startHour = endHour
                startMinute = endMinute
                startPeriod = endPeriod
                print("Adjusted - Start: \(startPeriod) \(startHour):\(String(format: "%02d", startMinute))")
            }
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Spacer().frame(height: 24)
            
            HStack {
                Text(formattedDate(date, true))
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
            
            if isEditingSchedule { editScheduleView() } // 일정 편집 모드일 때만 보이는 뷰
            else {
                if ScheduleCount == 0 {
                    addScheduleView(color: circleColors[0]) // 일정이 없을 때 추가용 뷰
                } else {
                    showRecordsView() // 일정이 하나 이상 있을 때 일정 목록
                    if ScheduleCount < 3 {
                        addScheduleView(color: circleColors[ScheduleCount]) // 일정이 3개 미만일 때 추가용 뷰
                    }
                }
            }
            
            Spacer()
        }
        .frame(width: 320, height: 320)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 10)
        .sheet(isPresented: $showStartPicker) {
                    TimePickerSheetView(
                        hour: $startHour,
                        minute: $startMinute,
                        period: $startPeriod,
                        title: "시작 시간",
                        onConfirm: {
                            showStartPicker = false
                            correctTime(isStartTimeEdited: true) // 시작 시간 편집
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
                onConfirm: {
                    showEndPicker = false
                    correctTime(isStartTimeEdited: false) // 종료 시간 편집
                }
            )
            .presentationDetents([.medium])
        }
    }
    
    // 일정 추가용 뷰
    private func addScheduleView(color: Color) -> some View {
        VStack {
            Spacer().frame(height: 20)
            HStack {
                Circle()
                    .fill(color)
                    .frame(width: 18, height: 18)
                
                SimpleCustomTextField(
                    text: $newScheduleContent,
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
                        addSchedule()
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
    
    private func editScheduleView() -> some View {
        VStack {
            Spacer().frame(height: 20)
            HStack {
                Circle()
                    .fill(circleColors[editingScheduleIndex ?? 0])
                    .frame(width: 18, height: 18)
                
                SimpleCustomTextField(
                    text: $newScheduleContent,
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
                        if let index = editingScheduleIndex {
                            editSchedule(at: index)
                            isTextFieldFocused = false
                        }
                    }) {
                        Image("completeIcon")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .padding(.trailing, 24)
                }
            }
            .padding(.leading, 24)
            
            if isTextFieldFocused { timePickerView() }
        }
    }
    
    private func showRecordsView() -> some View {
        LazyVStack {
            if let scheduleList = schedules[date], !scheduleList.isEmpty {
                ForEach(Array(scheduleList.enumerated()), id: \.offset) { (index, schedule) in
                    SwipeableScheduleView(
                        schedule: schedule,
                        index: index,
                        circleColors: circleColors,
                        onEdit: { enterEditMode(for: index) },
                        onDelete: { store.send(.deleteSchedule(schedule)) }
                    )
                }
            } else {
                Text("아직 일정이 없습니다.")
                    .font(Font.customFont(Font.body1Bold))
                    .foregroundColor(.gray)
            }
        }
        .onTapGesture {
            if isEditingSchedule {
                isEditingSchedule = false
                resetFields()
            }
        }
    }

    // SwipeableScheduleView 커스텀 뷰
    struct SwipeableScheduleView: View {
        let schedule: Schedule
        let index: Int
        let circleColors: [Color]
        let onEdit: () -> Void
        let onDelete: () -> Void
        
        @State private var offset: CGFloat = 0
        @State private var isSwiping = false
        
        var body: some View {
            ZStack(alignment: .trailing) {
                // 삭제 버튼 배경
                Color.white
                    .frame(width: offset < 0 ? -offset : 0)
                
                // 일정 내용
                VStack {
                    Spacer().frame(height: 20)
                    HStack {
                        VStack(alignment: .leading, spacing: 0) {
                            HStack(alignment: .top) {
                                Circle()
                                    .fill(circleColors[index % circleColors.count])
                                    .frame(width: 20, height: 20)
                                Text(schedule.contents)
                                    .font(Font.customFont(Font.body1Bold))
                                    .foregroundColor(.decoSheetTextColor)
                            }
                            HStack {
                                Spacer()
                                    .frame(width: 28)
                                Text("\(formatTime(schedule.startScheduleDate)) - \(formatTime(schedule.endScheduleDate))")
                                    .font(Font.customFont(Font.body2Bold))
                                    .foregroundColor(.calendarCover)
                            }
                        }
                        
                        Spacer()
                        
                        VStack {
                            Button(action: onEdit) {
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
                .background(Color.white)
                .offset(x: offset)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            if value.translation.width < 0 { // 오른쪽에서 왼쪽으로만 슬라이드 허용
                                offset = max(value.translation.width, -40) // 최대치
                                isSwiping = true
                            }
                        }
                        // 중간 지점을 기준으로 어느 한 쪽으로 되게끔함
                        .onEnded { value in
                            if value.translation.width < -20 {
                                withAnimation {
                                    offset = -40
                                }
                            } else { // 임계값 미만이면 원래 위치로 복귀
                                withAnimation {
                                    offset = 0
                                }
                            }
                            isSwiping = false
                        }
                )
            }
            .frame(maxWidth: .infinity)
            .overlay(
                Group {
                    if offset < 0 { // 스와이프 중일 때만 삭제 버튼 표시
                        Button(action: {
                            onDelete()
                            withAnimation {
                                offset = 0 // 삭제 후 원래 위치로 복귀
                            }
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 5)
                        }
                        .foregroundColor(.red)
                        .cornerRadius(5)
                    }
                },
                alignment: .trailing
            )
            .onTapGesture {
                if isSwiping && offset < 0 {
                    withAnimation {
                        offset = 0
                    }
                    isSwiping = false
                }
            }
        }
        
        private func formatTime(_ date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "a h:mm"
            formatter.locale = Locale(identifier: "ko_KR")
            return formatter.string(from: date)
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

    // 일정 추가 함수
    private func addSchedule() {
        if !newScheduleContent.isEmpty {
            let calendar = Calendar.current

            let kstFormatter = DateFormatter()
            kstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
            kstFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
            let kstDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: date, matchingPolicy: .nextTime) ?? date
            
            // 시작 시간
            var startComponents = calendar.dateComponents([.year, .month, .day], from: kstDate)
            print("startPeriod: \(startPeriod), startHour: \(startHour), startMinute: \(startMinute)")
            
            // 종료 시간
            var endComponents = calendar.dateComponents([.year, .month, .day], from: kstDate)
            print("endPeriod: \(endPeriod), endHour: \(endHour), endMinute: \(endMinute)")
            
            // 12시간제에서 24시간제로 변환 (오후 11시 -> 23시)
            let startHour24 = startPeriod == "오후" ? (startHour % 12) + 12 : (startHour % 12)
            startComponents.hour = startHour24
            startComponents.minute = startMinute
            let endHour24 = endPeriod == "오후" ? (endHour % 12) + 12 : (endHour % 12)
            endComponents.hour = endHour24
            endComponents.minute = endMinute
            
            // 객체 생성 및 디버깅
            guard let startDate = calendar.date(from: startComponents),
                  let endDate = calendar.date(from: endComponents) else {
                print("Date 생성 실패")
                return
            }
            
            print("생성된 startComponents: \(startComponents)")
            print("생성된 endComponents: \(endComponents)")
            
            // Schedule 객체 생성 (alarmTime도 KST로 설정)
            let newSchedule = Schedule(
                id: 1,
                contents: newScheduleContent,
                startScheduleDate: startDate,
                endScheduleDate: endDate,
                isAlarm: false,
                alarmTime: startDate
            )
            
            print("----------<<새로운 스케쥴 정보>>----------")
            print("KST 기준:")
            print("startScheduleDate: \(kstFormatter.string(from: newSchedule.startScheduleDate))")
            print("endScheduleDate: \(kstFormatter.string(from: newSchedule.endScheduleDate))")
            print("alarmTime: \(kstFormatter.string(from: newSchedule.alarmTime))")
            dump(newSchedule)
            
            // Store에 새로운 일정 추가
            store.send(.addSchedule(newSchedule))
            resetFields()
        }
    }
    
    private func enterEditMode(for index: Int) {
        guard let schedule = schedules[date]?[index] else { return }
        let calendar = Calendar.current
        let startComponents = calendar.dateComponents([.hour, .minute], from: schedule.startScheduleDate)
        startHour = startComponents.hour! % 12 == 0 ? 12 : startComponents.hour! % 12
        startMinute = startComponents.minute!
        startPeriod = startComponents.hour! >= 12 ? "오후" : "오전"
        let endComponents = calendar.dateComponents([.hour, .minute], from: schedule.endScheduleDate)
        endHour = endComponents.hour! % 12 == 0 ? 12 : endComponents.hour! % 12
        endMinute = endComponents.minute!
        endPeriod = endComponents.hour! >= 12 ? "오후" : "오전"
        newScheduleContent = schedule.contents
        editingScheduleIndex = index
        isEditingSchedule = true
        isTextFieldFocused = true
    }

    private func editSchedule(at index: Int) {
        guard !newScheduleContent.isEmpty,
              let originalSchedule = schedules[date]?[index] else {
            resetFields()
            return
        }
        
        let calendar = Calendar.current
        var startComponents = calendar.dateComponents([.year, .month, .day], from: date)
        startComponents.hour = startPeriod == "오후" ? (startHour % 12) + 12 : (startHour % 12)
        startComponents.minute = startMinute
        
        var endComponents = calendar.dateComponents([.year, .month, .day], from: date)
        endComponents.hour = endPeriod == "오후" ? (endHour % 12) + 12 : (endHour % 12)
        endComponents.minute = endMinute
        
        let startDate = calendar.date(from: startComponents) ?? Date()
        let endDate = calendar.date(from: endComponents) ?? Date()
        
        // 수정된 Schedule 객체 생성
        let updatedSchedule = Schedule(
            id: originalSchedule.id,
            contents: newScheduleContent,
            startScheduleDate: startDate,
            endScheduleDate: endDate,
            isAlarm: originalSchedule.isAlarm,
            alarmTime: originalSchedule.alarmTime
        )
        
        store.send(.editSchedule(updatedSchedule))
        
        // UI 상태 초기화
        resetFields()
    }

    private func resetFields() {
        newScheduleContent = ""
        editingScheduleIndex = nil
        isEditingSchedule = false
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
                    ForEach(Array(stride(from: 0, to: 60, by: 1)), id: \.self) { minute in
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
