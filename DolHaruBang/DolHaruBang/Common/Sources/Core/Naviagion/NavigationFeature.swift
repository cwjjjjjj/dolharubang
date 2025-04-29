//
//  NavigationFeature.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/31/24.
//

import ComposableArchitecture
import SwiftUI


// MARK: 네비게이션 Reducer
@Reducer
struct NavigationFeature {
    
  // 네비게이션으로 이동하려는 모든 경로 Path에 지정
  // 이동하는 네비게이션에서 Reducer를 사용한다면 Reducer도 같이 정의
  @Reducer(state: .equatable)
  enum Path {
    case calendar(CalendarFeature)
    case harubang(HaruBangFeature)
    case park(ParkFeature)
    case mypage(MyPageFeature)
    case home(HomeFeature)
    case DBTIGuideView(DBTIFeature)
    case DBTIQuestion1View(DBTIFeature)
    case DBTIResultView(DBTIFeature)
    case TrophyView(TrophyFeature)
    case SettingView(SettingFeature)
    case input(DBTIFeature)
  }
    
  // path - NavigationStack 에서 사용하는 Stack
  // enableClick - FloatingMenu 버튼들 비동기 처리를 위해
  @ObservableState
  struct State: Equatable {
    var path = StackState<Path.State>()
    var enableClick : Bool = true
  }

  enum Action {
//    case goBackToScreen(id: StackElementID)
    case path(StackActionOf<Path>) // 경로를 인식해서 패턴매칭 ex) 같은 리듀서를 참조하고 있지만 경로에 따라 다른 행동, 이렇게 사용하면 NavigationFeature을 불러오지 않아도 이동가능
    case popToRoot
    case goToHome
    case goToInput
    case goToScreen(Path) // 이동하는 경로를 매개변수로 받고 switch case 로 패턴매칭
    case clickButtonEnable
//    case goBack(StackActionOf<Path>)
  }
    

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .clickButtonEnable:
          state.enableClick = true
          return .none
          
      case .popToRoot:
        state.path.removeAll()
        return .none

      case .goToHome:
        state.path.append(.home(HomeFeature.State()))
        return .none
          
      case .goToInput:
        state.path.removeAll()
        return .none
          
      case let .goToScreen(action):
                // 홈까지 지워주는 함수
                func clearPathToHomeIfNeeded() {
                  while let last = state.path.last {
                      if case .home = last {
                          break
                        } else {
                          state.path.removeLast()
                        }
                    }
                 }
                
                // 버튼 비동기 함수
                func createAsyncEnableClickEffect() -> Effect<Action> {
                  return .run { send in
                      
                          // 비동기 작업 0.5초
                          try await Task.sleep(nanoseconds: 500_000_000)

                          // 버튼 클릭 할 수 있게
                          await send(.clickButtonEnable)
                      
                  }
              }
          
              switch action {
              case .calendar:
                  clearPathToHomeIfNeeded()
                  guard !(state.path.last?.isCalendar ?? false) else {
                          state.enableClick = true
                          return .none
                      }
                  state.enableClick = false
                  state.path.append(.calendar(CalendarFeature.State()))
                  return createAsyncEnableClickEffect()
                  
                  
              case .input:
                  state.path.append(.input(DBTIFeature.State()))
                  return .none
                      
              case .harubang(_):
                  clearPathToHomeIfNeeded()
                  guard !(state.path.last?.isHarubang ?? false) else {
                          state.enableClick = true
                          return .none
                      }
                  state.enableClick = false
                  state.path.append(.harubang(HaruBangFeature.State()))
                  return createAsyncEnableClickEffect()
                  
              case .park(_):
                  clearPathToHomeIfNeeded()
                  guard !(state.path.last?.isPark ?? false) else {
                          state.enableClick = true
                          return .none
                      }
                  state.enableClick = false
                  state.path.append(.park(ParkFeature.State()))
                  return createAsyncEnableClickEffect()
                  
              case .mypage(_):
                  clearPathToHomeIfNeeded()
                  guard !(state.path.last?.isCalendar ?? false) else {
                          state.enableClick = true
                          return .none
                      }
                  state.enableClick = false
                  state.path.append(.mypage(MyPageFeature.State()))
                  return createAsyncEnableClickEffect()
                  
              case .home(_):
                  clearPathToHomeIfNeeded()
                  guard !(state.path.last?.isHome ?? false) else {
                          state.enableClick = true
                          return .none
                      }
                  state.enableClick = false
                  return createAsyncEnableClickEffect()
                  
                  
              case .DBTIGuideView:
                  state.path.append(.DBTIQuestion1View(DBTIFeature.State()))
                  return .none
                  
              case .DBTIQuestion1View:
                  state.path.append(.DBTIQuestion1View(DBTIFeature.State()))
                  return .none
              case .DBTIResultView(_):
                  state.path.append(.DBTIResultView(DBTIFeature.State()))
                  return .none
                  
                  
              case .TrophyView(_):
                  state.path.append(.TrophyView(TrophyFeature.State()))
                  return .none
                  
              case .SettingView(_):
                  state.path.append(.SettingView(SettingFeature.State()))
                  return .none
              
              }
                 
           
      // 이렇게 사용하면 NavigationFeature를 불러오지 않고 기존에 사용하는 Reducer만 불러와도 사용 가능
      case let .path(action):
          switch action {
              
          case .element(id: _, action: .DBTIResultView(.homeButtonTapped)):
            state.path.append(.home(HomeFeature.State()))
            return .none
              
          case .element(id: _, action: .DBTIResultView(.goBack)), .element(id: _, action: .DBTIQuestion1View(.goBack)):
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
    // Navigation 선언부 destination 패턴매칭
    .forEach(\.path, action: \.path)
  }
    
}


extension NavigationFeature.Path.State {
    var isHome: Bool {
        guard case .home = self else { return false }
        return true
    }
    var isHarubang: Bool {
        guard case .harubang = self else { return false }
        return true
    }
    var isPark: Bool {
        guard case .park = self else { return false }
        return true
    }
    var isMypage: Bool {
        guard case .mypage = self else { return false }
        return true
    }
    var isCalendar: Bool {
        guard case .calendar = self else { return false }
        return true
    }
}

