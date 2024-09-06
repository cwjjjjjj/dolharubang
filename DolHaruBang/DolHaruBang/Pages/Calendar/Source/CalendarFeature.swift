import ComposableArchitecture
import SwiftUI

@Reducer
struct CalendarFeature {
    
    @ObservableState
    struct State: Equatable {
        var currentDate: Date = Date()  // 현재 날짜
        var selectedDate: Date? = nil  // 선택된 날짜
        var records: [Date: [String]] = [:]  // 날짜별로 일정 저장
        var showPopup: Bool = false  // 일정 작성용 팝업 표시 여부
        var selectedBackground: Background = .December
    }
 
    enum Action: BindableAction {
        case changeMonth(by: Int)  // 월을 변경
        case selectDate(Date?)  // 특정 날짜를 선택
        case togglePopup(Bool)  // 팝업 표시/숨기기
        case addRecord(Date, String)  // 특정 날짜에 기록 추가
        case editRecord(Date, Int, String)  // 특정 날짜의 특정 인덱스 기록 수정
        case deleteRecord(Date, Int)  // 특정 날짜의 특정 인덱스 기록 삭제
        case setBackground(Background)  // 배경 설정
        case binding( BindingAction < State > )  // 바인딩 액션 처리
    }
    
    var body : some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                case let .changeMonth(value):
                    if let newDate = Calendar.current.date(byAdding: .month, value: value, to: state.currentDate) {
                        state.currentDate = newDate
                    }
                    return .none
                case .binding(\.selectedDate):
                    return .none
                case .selectDate(let date):
                    state.selectedDate = date
                    return .none
                case .binding(\.showPopup):
                    return .none
                    
                case .togglePopup(let show):
                    state.showPopup = show
                    return .none
                case .binding(\.records):
                    return .none

                    
                case .addRecord(let date, let record):
                    if state.records[date] != nil {
                        state.records[date]?.append(record)
                    } else {
                        state.records[date] = [record]
                    }
                    return .none
                    
                case .editRecord(let date, let index, let newRecord):
                    if state.records[date] != nil && index < state.records[date]!.count {
                        state.records[date]?[index] = newRecord
                    }
                    return .none
                    
                case .deleteRecord(let date, let index):
                    if state.records[date] != nil && index < state.records[date]!.count {
                        state.records[date]?.remove(at: index)
                    }
                    return .none
                    
                case .setBackground(let background):
                    state.selectedBackground = background
                    return .none

                case .binding:
                    return .none
            }
        }
    }
}
