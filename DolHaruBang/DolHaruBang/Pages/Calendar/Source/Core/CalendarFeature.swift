import ComposableArchitecture
import SwiftUI

@Reducer
struct CalendarFeature {
    @Dependency(\.scheduleClient) var scheduleClient
    
    @ObservableState
    struct State: Equatable {
        var currentDate: Date = Date()
        var selectedDate: Date? = nil
        var schedules: [Date: [Schedule]] = [:]
        var showPopup: Bool = false
        var isLoading: Bool = true
        @Shared(.inMemory("background")) var selectedBackground: Background = .December
    }
 
    enum Action: BindableAction {
        case changeMonth(by: Int)
        case selectDate(Date?)
        case togglePopup(Bool)
        case fetchSchedulesForMonth(year: Int, month: Int, memberId: Int)
        case schedulesReceived(Result<[Schedule], Error>, isFullUpdate: Bool)  // 수정된 부분
        case addSchedule(Schedule)
        case editSchedule(Schedule)
        case deleteSchedule(Date, Int)
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .changeMonth(value):
                if let newDate = Calendar.current.date(byAdding: .month, value: value, to: state.currentDate) {
                    state.currentDate = newDate
                }
                return .none
                
            case .selectDate(let date):
                state.selectedDate = date
                return .none
                
            case .togglePopup(let show):
                state.showPopup = show
                return .none
                
            case let .fetchSchedulesForMonth(year, month, memberId):
                state.isLoading = true
                return .run { send in
                    do {
                        let schedules = try await scheduleClient.fetchSchedulesById(year, month, memberId)
                        print("성공 - \(schedules.count)개의 일정 가져옴:")
                        schedules.forEach { schedule in
                            print("ID: \(schedule.id), 내용: \(schedule.contents), 시작: \(schedule.startScheduleDate)")
                        }
                        await send(.schedulesReceived(.success(schedules), isFullUpdate: true))  // 전체 업데이트
                    } catch {
                        await send(.schedulesReceived(.failure(error), isFullUpdate: true))
                    }
                }
                
            case .addSchedule(let schedule):
                state.isLoading = true
                return .run { send in
                    do {
                        let addedSchedule = try await scheduleClient.addSchedule(schedule)
                        await send(.schedulesReceived(.success([addedSchedule]), isFullUpdate: false))  // 부분 업데이트
                    } catch {
                        await send(.schedulesReceived(.failure(error), isFullUpdate: false))
                    }
                }
                
            case .editSchedule(let schedule):
                state.isLoading = true
                return .run { send in
                    do {
                        let updatedSchedule = try await scheduleClient.editSchedule(schedule)
                        await send(.schedulesReceived(.success([updatedSchedule]), isFullUpdate: false))
                    } catch {
                        await send(.schedulesReceived(.failure(error), isFullUpdate: false))
                    }
                }
                
            case .schedulesReceived(.success(let schedules), let isFullUpdate):
                state.isLoading = false
                if isFullUpdate {
                    state.schedules = [:]  // 전체 업데이트 시 초기화
                }
                for schedule in schedules {
                    let date = Calendar.current.startOfDay(for: schedule.startScheduleDate)
                    if var existingSchedules = state.schedules[date] {
                        if let index = existingSchedules.firstIndex(where: { $0.id == schedule.id }) {
                            existingSchedules[index] = schedule
                        } else {
                            existingSchedules.append(schedule)
                        }
                        state.schedules[date] = existingSchedules
                    } else {
                        state.schedules[date] = [schedule]
                    }
                }
                return .none
                
            case .schedulesReceived(.failure(let error), _):
                state.isLoading = false
                print("Failed to process schedules: \(error)")
                return .none
                
            case .deleteSchedule(let date, let index):
                if state.schedules[date] != nil && index < state.schedules[date]!.count {
                    state.schedules[date]?.remove(at: index)
                }
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}
