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
      var kakaoToken: String?
  }

  enum Action {
//    case calendarButtonTapped
    case homeButtonTapped
    case goBack
      
    case kakaoLoginRequested(String)
    case kakaoLoginResponse(Result<KakaoLoginResponse, Error>)

  }
    
  @Dependency(\.dBTIClient) var dBTIClient

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
//      case .calendarButtonTapped:
//        return .none
      case .homeButtonTapped:
          return .none
      case .goBack:
        return .none
        
      case let .kakaoLoginRequested(oauthToken):
          return .run { send in
              do {
                  let tokens = try await dBTIClient.kakaoLogin(oauthToken)
                  await send(.kakaoLoginResponse(.success(tokens)))
              } catch {
                  await send(.kakaoLoginResponse(.failure(error)))
              }
          }
          
      case let .kakaoLoginResponse(.success(tokens)):
          print("백에보내는거성공 토큰 : \(tokens.accessToken) , \(tokens.refreshToken)")
        
          TokenManager.shared.saveTokens(accessToken:tokens.accessToken, refreshToken: tokens.refreshToken)
          return .none
          
      case let .kakaoLoginResponse(.failure(error)):
          return .none
      }
    }
  }
}

