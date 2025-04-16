import ComposableArchitecture
import SwiftUI

@Reducer
struct NavigationFeature {
    @Reducer(state: .equatable)
    enum Path {
        case calendar(CalendarFeature)
        case harubang(HaruBangFeature)
        case park(ParkFeature)
        case mypage(MyPageFeature)
        case home(HomeFeature)
        case DBTIQuestionView(DBTIFeature)
        case DBTIResultView(DBTIFeature)
        case TrophyView(TrophyFeature)
        case SettingView(SettingFeature)
    }
    
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var enableClick: Bool = true
    }
    
    enum Action {
        case path(StackActionOf<Path>) // Navigation 관련 StackState를 조작하는 액션(예: .push, .pop, .element(id:action:)).
        case popToRoot
        case goToScreen(Path)
        case clickButtonEnable
    }
    /*
     StackAction<State, Action>에 들어갈 수 있는 것들
     .push(id: StackElementID, state: State): 스택에 새 요소 추가.
     .pop: 스택에서 마지막 요소 제거.
     .element(id: StackElementID, action: Action): 스택 내 특정 요소(화면)에 액션을 전달.
     */
    
    var body: some Reducer<State, Action> {
        Reduce { state, action in
            switch action {
                // 클릭 중복 방지용
                case .clickButtonEnable:
                    state.enableClick = true
                    return .none
                
                case .popToRoot:
                    state.path.removeAll()
                    return .none
                
                // 해당 화면으로 이동
                case let .goToScreen(action):
                    // 홈화면 전까지 
                    func clearPathToHomeIfNeeded() {
                        while let last = state.path.last {
                            if case .home = last {
                                break
                            } else {
                                state.path.removeLast()
                            }
                        }
                    }
                    
                    // 클릭 중복 방지용
                    func createAsyncEnableClickEffect() -> Effect<Action> {
                        return .run { send in
                            try await Task.sleep(nanoseconds: 500_000_000)
                            await send(.clickButtonEnable)
                        }
                    }
                    
                    switch action {
                        case .calendar:
                            clearPathToHomeIfNeeded()
                            state.enableClick = false
                            state.path.append(.calendar(CalendarFeature.State()))
                            return createAsyncEnableClickEffect()
                            
                        case .harubang:
                            clearPathToHomeIfNeeded()
                            state.enableClick = false
                            state.path.append(.harubang(HaruBangFeature.State()))
                            return createAsyncEnableClickEffect()
                            
                        case .park:
                            clearPathToHomeIfNeeded()
                            state.enableClick = false
                            state.path.append(.park(ParkFeature.State()))
                            return createAsyncEnableClickEffect()
                            
                        case .mypage:
                            clearPathToHomeIfNeeded()
                            state.enableClick = false
                            state.path.append(.mypage(MyPageFeature.State()))
                            return createAsyncEnableClickEffect()
                            
                        case .home:
                            clearPathToHomeIfNeeded()
                            state.enableClick = false
                            return createAsyncEnableClickEffect()
                            
                        case .DBTIQuestionView:
                            state.path.append(.DBTIQuestionView(DBTIFeature.State()))
                            return .none
                            
                        case .DBTIResultView:
                            state.path.append(.DBTIResultView(DBTIFeature.State()))
                            return .none
                            
                        case .TrophyView:
                            state.path.append(.TrophyView(TrophyFeature.State()))
                            return .none
                            
                        case .SettingView:
                            state.path.append(.SettingView(SettingFeature.State()))
                            return .none
                    }
                    
                case let .path(action):
                    switch action {
                        // .last를 통해 DBTIQuestionView의 index번째 질문의 고른 옵션을 가지고와서
                        case .element(id: _, action: .DBTIQuestionView(.selectOption(let index))):
                            // 현재 DBTI 상태 가져와서 (by path.last에 where 걸기)
                            // 질문 번호가 몇 번인지 확인해서 다음 갈 곳 결정
                            if let lastPath = state.path.last(where: { if case .DBTIQuestionView = $0 { return true }; return false }),
                               case .DBTIQuestionView(let dbtiState) = lastPath {
                                let currentIndex = dbtiState.questionIndex
                                if currentIndex < 7 {
                                    state.path.append(.DBTIQuestionView(DBTIFeature.State(questionIndex: currentIndex + 1)))
                                } else {
                                    state.path.append(.DBTIResultView(DBTIFeature.State(score: dbtiState.score)))
                                }
                            }
                            return .none
                            
                        case .element(id: _, action: .DBTIResultView(.homeButtonTapped)):
                            state.path.append(.home(HomeFeature.State()))
                            return .none
                            
                        case .element(id: _, action: .DBTIResultView(.goBack)),
                                .element(id: _, action: .DBTIQuestionView(.goBack)):
                            state.path.removeLast()
                            return .none
                            
                        case .element(id: _, action: .mypage(.trophyButtonTapped)):
                            state.path.append(.TrophyView(TrophyFeature.State()))
                            return .none
                            
                        case .element(id: _, action: .mypage(.settingButtonTapped)):
                            state.path.append(.SettingView(SettingFeature.State()))
                            return .none
                            
                        case .element(id: _, action: .TrophyView(.goBack)):
                            state.path.removeLast()
                            return .none
                            
                        case .element(id: _, action: .SettingView(.goBack)):
                            state.path.removeLast()
                            return .none
                            
                        default:
                            return .none
                    }
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension NavigationFeature.Path.State {
    var dbtiQuestionView: DBTIFeature.State? {
        if case .DBTIQuestionView(let state) = self { return state }
        return nil
    }
}
