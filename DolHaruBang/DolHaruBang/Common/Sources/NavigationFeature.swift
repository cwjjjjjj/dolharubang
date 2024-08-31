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
    case floatButton(FloatButtonFeature)
      
  }

  @ObservableState
  struct State: Equatable {
    var path = StackState<Path.State>()
  }

  enum Action {
    case goBackToScreen(id: StackElementID)
    case path(StackActionOf<Path>)
    case popToRoot
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
          
      case let .path(action):
          switch action {
//          case .element(id: _, action: FloatButtonFeature.Action.calendarButtonTapped):
//              state.path.append(.harubang(HaruBangFeature.State()))
//              return .none
              
          case .element(id:_, action: .floatButton(.harubangButtonTapped)):
              state.path.append(.harubang(HaruBangFeature.State()))
              return .none
              
//          case .element(id: _, action: FloatButtonFeature.Action.homeButtonTapped):
//              state.path.append(.harubang(HaruBangFeature.State()))
//              return .none
              
          case .element(id:_, action: .floatButton(.parkButtonTapped)):
              state.path.append(.park(ParkFeature.State()))
              return .none
              
          case .element(id:_, action: .floatButton(.mypageButtonTapped)):
              state.path.append(.mypage(MyPageFeature.State()))
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
//    case homeButtonTapped
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
//      case .homeButtonTapped:
//        return .none
      case .parkButtonTapped:
        return .none
      case .mypageButtonTapped:
        return .none
      }
    }
  }
}
