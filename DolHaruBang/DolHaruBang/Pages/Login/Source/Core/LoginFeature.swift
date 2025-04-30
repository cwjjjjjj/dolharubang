//
//  DBTIFeature.swift
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
  }

  enum Action {
//    case calendarButtonTapped
    case homeButtonTapped
    case goBack
      
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
        
//      case let .kakaoLoginRequested(oauthToken):
//          return .run { send in
//              do {
//                  let tokens = try await loginClient.kakaoLogin(oauthToken)
//                  await send(.kakaoLoginResponse(.success(tokens)))
//                  await send(.isFirstRequest)
//              } catch {
//                  await send(.kakaoLoginResponse(.failure(error)))
//              }
//          }
//          
//      case let .kakaoLoginResponse(.success(tokens)):
//          TokenManager.shared.saveTokens(accessToken:tokens.accessToken, refreshToken: tokens.refreshToken)
//          return .none
              
      case let .kakaoLoginRequested(oauthToken):
          return .run { send in
              // (A) 재발급 전 토큰 print
              if let oldToken = TokenManager.shared.getAccessToken() {
                  print("재발급 전 accessToken: \(oldToken)")
              } else {
                  print("재발급 전 accessToken: (없음)")
              }
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

      case let .kakaoLoginResponse(.success(tokens)):
          TokenManager.shared.saveTokens(accessToken:tokens.accessToken, refreshToken: tokens.refreshToken)
          // (B) 재발급 후 토큰 print
          print("재발급 후 accessToken: \(tokens.accessToken)")
          return .none

          
      case let .socialLoginResponse(.success(tokens)):
          TokenManager.shared.saveTokens(accessToken:tokens.accessToken, refreshToken: tokens.refreshToken)
          return .run { send in
              await send(.isFirstRequest)
          }
          
      case let .socialLoginResponse(.failure(error)):
          print(error)
          return .none
          
      case .isFirstRequest:
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
          return .none
      case let .isFirstResponse(.failure(error)):
          return .none
          
      }
    }
  }
}

