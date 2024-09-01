//
//  NavigationFeature.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/31/24.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct NavigationFeature {
  @Reducer(state: .equatable)
  enum Path {
//    case calendar(CalenndarFeature)
    case harubang(HaruBangFeature)
    case park(ParkFeature)
    case mypage(MyPageFeature)
    case home(HomeFeature)
    case DBTIQuestion1View
    case DBTIResultView(FloatButtonFeature)
  }
    
  @ObservableState
  struct State: Equatable {
    var path = StackState<Path.State>()
  }

  enum Action {
    case goBackToScreen(id: StackElementID)
    case path(StackActionOf<Path>)
    case popToRoot
    case goToScreen(Path)
  }
    

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
          
      case let .goBackToScreen(id):
        state.path.pop(to: id)
        return .none
          
          
      case .popToRoot:
        state.path.removeAll()
        return .none
          
          

          
      case let .goToScreen(action):
          
              switch action {
              case .harubang(_):
                  
                  while let last = state.path.last {
                      if case .home = last {
                          // Last element is `.home`, break the loop
                          break
                      } else {
                          // Remove the last element from `state.path`
                          state.path.removeLast()
                      }
                  }
                  state.path.append(.harubang(HaruBangFeature.State()))
              case .park(_):
                  while let last = state.path.last {
                      if case .home = last {
                          // Last element is `.home`, break the loop
                          break
                      } else {
                          // Remove the last element from `state.path`
                          state.path.removeLast()
                      }
                  }
                  state.path.append(.park(ParkFeature.State()))
              case .mypage(_):
                  while let last = state.path.last {
                      if case .home = last {
                          // Last element is `.home`, break the loop
                          break
                      } else {
                          // Remove the last element from `state.path`
                          state.path.removeLast()
                      }
                  }
                  state.path.append(.mypage(MyPageFeature.State()))
              case .home(_):
                  while let last = state.path.last {
                      if case .home = last {
                          break
                      } else {
                          state.path.removeLast()
                      }
                  }
                  
//                  state.path.append(.home(HomeFeature.State()))
              case .DBTIQuestion1View:
                  state.path.append(.DBTIQuestion1View)
              case .DBTIResultView(_):
                  state.path.append(.DBTIResultView(FloatButtonFeature.State()))
              }
          return .none
          
      case let .path(action):
          switch action {
//          case .element(id: _, action: FloatButtonFeature.Action.calendarButtonTapped):
//              state.path.append(.harubang(HaruBangFeature.State()))
//              return .none
              
          case .element(id: _, action: .DBTIResultView(.homeButtonTapped)):
//            print("결과 -> 홈 이동")
//            state.path = StackState<Path.State>()
            state.path.append(.home(HomeFeature.State()))
            return .none
              
          default:
            return .none
          }
      }
    }
    .forEach(\.path, action: \.path)
  }
    
}



@Reducer
struct FloatButtonFeature {
  @ObservableState
  struct State: Equatable {}

  enum Action {
//    case calendarButtonTapped
    case harubangButtonTapped
    case homeButtonTapped
    case parkButtonTapped
    case mypageButtonTapped
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
//      case .calendarButtonTapped:
//        return .none
      case .harubangButtonTapped:
        return .none
      case .homeButtonTapped:
          print("플롯 홈")
        return .none
      case .parkButtonTapped:
        return .none
      case .mypageButtonTapped:
        return .none
      }
    }
  }
}

