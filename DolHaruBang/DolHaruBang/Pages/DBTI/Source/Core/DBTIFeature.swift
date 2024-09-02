//
//  DBTIFeature.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/1/24.
//

// MARK: DBTI 전반적인 상태관리

import ComposableArchitecture

@Reducer
struct DBTIFeature {
  @ObservableState
  struct State: Equatable {
      
  }

  enum Action {
//    case calendarButtonTapped
    case homeButtonTapped
    case goBack
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
//      case .calendarButtonTapped:
//        return .none
      case .homeButtonTapped:
          return .none
      case .goBack:
        return .none
        
      }
    }
  }
}

