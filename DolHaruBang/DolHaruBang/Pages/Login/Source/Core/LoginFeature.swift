////
////  LoginFeature.swift
////  DolHaruBang
////
////  Created by 양희태 on 4/17/25.
////
//
//
//import ComposableArchitecture
//
//@Reducer
//struct LoginFeature {
//  @ObservableState
//  struct State: Equatable {
//      var kakaoToken: String?
//  }
//
//  enum Action {
//    case homeButtonTapped
//    case goBack
//      
//    case kakaoLoginRequested(String)
//    case kakaoLoginResponse(Result<KakaoLoginResponse, Error>)
//
//  }
//    
//    @Dependency(\.loginClient) var loginClient
//
//  var body: some Reducer<State, Action> {
//    Reduce { state, action in
//      switch action {
////      case .calendarButtonTapped:
////        return .none
//      case .homeButtonTapped:
//          return .none
//      case .goBack:
//        return .none
//        
//      case let .kakaoLoginRequested(oauthToken):
//          return .run { send in
//              do {
//                  let tokens = try await loginClient.kakaoLogin(oauthToken)
//                  await send(.kakaoLoginResponse(.success(tokens)))
//              } catch {
//                  await send(.kakaoLoginResponse(.failure(error)))
//              }
//          }
//          
//      case let .kakaoLoginResponse(.success(tokens)):
//          print("백에보내는거성공 토큰 : \(tokens.accessToken) , \(tokens.refreshToken)")
//        
//          TokenManager.shared.saveTokens(accessToken:tokens.accessToken, refreshToken: tokens.refreshToken)
//          return .none
//          
//      case let .kakaoLoginResponse(.failure(error)):
//          return .none
//      }
//    }
//  }
//}
//
