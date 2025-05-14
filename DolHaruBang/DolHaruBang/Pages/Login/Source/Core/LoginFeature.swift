//
//  LoginFeature.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/1/24.
//

// MARK: DBTI 전반적인 상태관리

import ComposableArchitecture
import Foundation

@Reducer
struct LoginFeature {
  @ObservableState
  struct State: Equatable {
      var kakaoToken: String?
      var kakaoButtonDisable : Bool = false
  }

  enum Action {
//    case calendarButtonTapped
    case homeButtonTapped
    case goBack
    case goToHome
    case goToInput
      
    case kakaoLoginRequested(String)
    case appleLoginRequested(String,String)
    case socialLoginResponse(Result<SocialLoginResponse, Error>)
      
      
    case isFirstRequest
    case isFirstResponse(Result<Bool, Error>)
      

  }
    
  @Dependency(\.loginClient) var loginClient

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .homeButtonTapped:
          return .none
      case .goBack:
        return .none
      
      case .goToHome:
          return .none
      
      case .goToInput:
          return .none
        
      case let .kakaoLoginRequested(oauthToken):
          state.kakaoButtonDisable = true
          return .run { send in
              do {
                  let tokens = try await loginClient.kakaoLogin(oauthToken)
                  await send(.socialLoginResponse(.success(tokens)))
              } catch {
                  await send(.socialLoginResponse(.failure(error)))
              }
          }
      case let .appleLoginRequested(idTokenString, userIdentifier):
          return .run { send in
              do {
                  let tokens = try await loginClient.appleLogin(idTokenString,userIdentifier)
                  await send(.socialLoginResponse(.success(tokens)))
              } catch {
                  await send(.socialLoginResponse(.failure(error)))
              }
          }
          
      case let .socialLoginResponse(.success(tokens)):
          TokenManager.shared.saveTokens(accessToken:tokens.accessToken, refreshToken: tokens.refreshToken)
          return .run { send in
              await send(.isFirstRequest)
          }
          
      case let .socialLoginResponse(.failure(error)):
          print("백에서 받은 토큰 에러 ",error)
          return .none
          
      case .isFirstRequest:
          state.kakaoButtonDisable = true
          return .run { send in
              do {
                  let isFirst = try await loginClient.isFirst()
                  await send(.isFirstResponse(.success(isFirst)))
              } catch {
                  await send(.isFirstResponse(.failure(error)))
              }
          }
          
      case let .isFirstResponse(.success(isFirst)):
          NotificationCenter.default.post(name: NSNotification.Name("TokenVaild"), object: nil,userInfo: ["isFirst" : isFirst])
          state.kakaoButtonDisable = false
          return .none
      case let .isFirstResponse(.failure(error)):
          print("첫인증자 에러", error)
          state.kakaoButtonDisable = false
          return .none
          
      }
    }
  }
}
