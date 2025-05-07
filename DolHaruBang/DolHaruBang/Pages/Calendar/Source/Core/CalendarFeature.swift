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
        case fetchSchedulesForMonth(year: Int, month: Int)
        case schedulesReceived(Result<[Schedule], Error>, isFullUpdate: Bool)  // 수정된 부분
        case addSchedule(Schedule)
        case editSchedule(Schedule)
        case deleteSchedule(Schedule)
        case binding(BindingAction<State>)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case let .changeMonth(value):
                if let newDate = Calendar.current.date(byAdding: .month, value: value, to: state.currentDate) {
                    state.currentDate = newDate
                    let components = Calendar.current.dateComponents([.year, .month], from: newDate)
                    return .run { send in
                        await send(.fetchSchedulesForMonth(year: components.year ?? 2025, month: components.month ?? 1))
                    }
                }
                return .none
                
            case .selectDate(let date):
                state.selectedDate = date
                return .none
                
            case .togglePopup(let show):
                state.showPopup = show
                return .none
                
                case let .fetchSchedulesForMonth(year, month):
                    state.isLoading = true
                    return .run { send in
                        do {
                            let schedules = try await scheduleClient.fetchSchedules(year, month)
                            print("<<성공 - \(schedules.count)개의 일정 가져옴>>")
                            schedules.forEach { schedule in
                                // KST로 포맷팅된 시작일 출력
                                let kstFormatter = DateFormatter()
                                kstFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                                kstFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
                                let kstStartDate = kstFormatter.string(from: schedule.startScheduleDate)
                                
                                print("ID: \(schedule.id), 내용: \(schedule.contents), 시작일: \(kstStartDate)")
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
                        await send(.schedulesReceived(.success([addedSchedule]), isFullUpdate: false))
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
                    
            case let .deleteSchedule(schedule):
                return .run { [state] send in
                    try await scheduleClient.deleteSchedule(schedule.id)
                    
                    // 삭제 후 현재 월의 일정을 다시 불러오기
                    let components = Calendar.current.dateComponents([.year, .month], from: state.currentDate)
                    await send(.fetchSchedulesForMonth(year: components.year ?? 2025, month: components.month ?? 1))
                    
                    print("ID \(schedule.id)번 일정 삭제 후 일정 다시 불러오기")
                } catch: { error, send in
                    print("Failed to delete schedule: \(error)")
                    await send(.schedulesReceived(.failure(error), isFullUpdate: false))
                }


            case .schedulesReceived(.success(let schedules), let isFullUpdate):
                state.isLoading = false
                if isFullUpdate {
                    print("Full update: Clearing schedules")
                    state.schedules = [:]
                }
                    
//                // KST 기준 캘린더 설정
                var kstCalendar = Calendar.current
                kstCalendar.timeZone = TimeZone(identifier: "Asia/Seoul")!
                    
                for schedule in schedules {
                    let date = kstCalendar.startOfDay(for: schedule.startScheduleDate)
                    
                    if var existingSchedules = state.schedules[date] {
                        if let index = existingSchedules.firstIndex(where: { $0.id == schedule.id }) {
                            print("\(date)의 \(index)번째 스케쥴인 \(schedule.id)번 스케쥴 수정")
                            existingSchedules[index] = schedule
                        } else {
                            print("\(date)에 \(schedule.id)번 스케쥴 추가")
                            existingSchedules.append(schedule)
                        }
                        state.schedules[date] = existingSchedules
                    } else {
                        print("\(date)에 첫 번째 스케쥴로 \(schedule.id)번 스케쥴 추가")
                        state.schedules[date] = [schedule]
                    }
                }
                return .none
                
            case .schedulesReceived(.failure(let error), _):
                state.isLoading = false
                print("Failed to process schedules: \(error)")
                return .none
                
            case .binding:
                return .none
            }
        }
    }
}
