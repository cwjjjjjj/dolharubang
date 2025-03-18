//
//  NetworkManager.swift
//  DolHaruBang
//
//  Created by 양희태 on 3/19/25.
//

import Foundation
import Alamofire
import Combine
import ComposableArchitecture

// 에러 타입 정의
enum NetworkError: Error {
    case unauthorized
    case forbidden
    case refreshTokenFailed
    case networkError(AFError)
    case decodingError(Error)
    case unknown
}

// 액세스 토큰 갱신을 위한 응답 모델
struct TokenRefreshResponse: Decodable {
    let accessToken: String
    let refreshToken: String
    let expiresIn: Int
}

class NetworkManager {
    static let shared = NetworkManager()
    
    private let baseURL = "https://sole-organic-singularly.ngrok-free.app"
    private let authTokenManager = AuthTokenManager.shared
    
    // 리프레시 토큰 사용여부
    private var isRefreshing = false
    private var requestsToRetry: [(RetryResult) -> Void] = []
    
    // 인증이 필요한 세션 생성
    private lazy var session: Session = {
        let configuration = URLSessionConfiguration.default
        return Session(configuration: configuration, interceptor: AuthInterceptor())
    }()
    
    private init() {}
    
    // 인증 인터셉터
    private class AuthInterceptor: RequestInterceptor {
        func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
            var urlRequest = urlRequest
            
            // 액세스 토큰이 있으면 헤더에 추가
            if let token = AuthTokenManager.shared.getAccessToken() {
                urlRequest.headers.add(.authorization(bearerToken: token))
            }
            
            completion(.success(urlRequest))
        }
        
        func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
            // 401 Unauthorized 에러인 경우 토큰 리프레시 시도
            if let response = request.response, response.statusCode == 401 {
                NetworkManager.shared.handleUnauthorized(completion: completion)
            } else {
                completion(.doNotRetry)
            }
        }
    }
    
    // 401 에러 처리
    private func handleUnauthorized(completion: @escaping (RetryResult) -> Void) {
        // 이미 리프레시 중이면 나중에 재시도할 요청 큐에 추가
        if isRefreshing {
            requestsToRetry.append(completion)
            return
        }
        
        isRefreshing = true
        
        // 리프레시 토큰으로 액세스 토큰 갱신
        refreshToken { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success:
                // 토큰 갱신 성공 - 요청 재시도
                completion(.retry)
                
                // 대기 중인 다른 요청들도 재시도
                self.requestsToRetry.forEach { $0(.retry) }
                self.requestsToRetry.removeAll()
                
            case .failure:
                // 토큰 갱신 실패 - 로그인 화면으로 리다이렉트
                completion(.doNotRetry)
                
                // 대기 중인 다른 요청들도 취소
                self.requestsToRetry.forEach { $0(.doNotRetry) }
                self.requestsToRetry.removeAll()
                
                // 로그인 화면으로 이동 알림 발송
                NotificationCenter.default.post(name: .authenticationFailed, object: nil)
            }
            
            self.isRefreshing = false
        }
    }
    
    // 토큰 리프레시 요청
    private func refreshToken(completion: @escaping (Result<Void, Error>) -> Void) {
        guard let refreshToken = authTokenManager.getRefreshToken() else {
            completion(.failure(NetworkError.refreshTokenFailed))
            return
        }
        
        let url = "\(baseURL)/api/v1/auth/refresh"
        let parameters: [String: Any] = ["refreshToken": refreshToken]
        
        // 리프레시 요청은 인터셉터를 사용하지 않는 일반 세션 사용
        AF.request(url, method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .validate()
            .responseDecodable(of: TokenRefreshResponse.self) { response in
                switch response.result {
                case .success(let tokenResponse):
                    // 새 토큰 저장
                    let tokens = AuthTokens(
                        accessToken: tokenResponse.accessToken,
                        refreshToken: tokenResponse.refreshToken,
                        expiresIn: tokenResponse.expiresIn
                    )
                    AuthTokenManager.shared.saveTokens(tokens)
                    completion(.success(()))
                    
                case .failure(let error):
                    // 리프레시 실패 - 특히 403 에러는 리프레시 토큰 만료
                    if let statusCode = response.response?.statusCode, statusCode == 403 {
                        AuthTokenManager.shared.clearTokens()
                    }
                    completion(.failure(NetworkError.refreshTokenFailed))
                }
            }
    }
    
    func request<T: Decodable>(_ endpoint: String, method: DolHaruBang.HTTPMethod = .get, parameters: Parameters? = nil, encoding: ParameterEncoding = URLEncoding.default) async throws -> T {
          return try await withCheckedThrowingContinuation { continuation in
             
              let alamofireMethod = method.alamofireMethod
              
              session.request("\(baseURL)\(endpoint)", method: alamofireMethod, parameters: parameters, encoding: encoding)
                  .validate()
                  .responseDecodable(of: T.self) { response in
                      switch response.result {
                      case .success(let value):
                          continuation.resume(returning: value)
                          
                      case .failure(let error):
                          if let statusCode = response.response?.statusCode {
                              switch statusCode {
                                  
                              //  엑세스 토큰 만료
                              case 401:
                                  continuation.resume(throwing: NetworkError.unauthorized)
                              //　리프레시 토큰만료
                              case 403:
                                  continuation.resume(throwing: NetworkError.forbidden)
                              default:
                                  continuation.resume(throwing: NetworkError.networkError(error))
                              }
                          } else {
                              continuation.resume(throwing: NetworkError.networkError(error))
                          }
                      }
                  }
          }
      }
      
    
    // 파일 업로드 메서드
    func uploadFile<T: Decodable>(to endpoint: String, fileURL: URL, fileName: String, mimeType: String) async throws -> T {
        return try await withCheckedThrowingContinuation { continuation in
            session.upload(multipartFormData: { multipartFormData in
                do {
                    let fileData = try Data(contentsOf: fileURL)
                    multipartFormData.append(fileData, withName: "file", fileName: fileName, mimeType: mimeType)
                } catch {
                    continuation.resume(throwing: error)
                }
            }, to: "\(baseURL)\(endpoint)")
            .validate()
            .responseDecodable(of: T.self) { response in
                switch response.result {
                case .success(let value):
                    continuation.resume(returning: value)
                case .failure(let error):
                    continuation.resume(throwing: NetworkError.networkError(error))
                }
            }
        }
    }
}

// 알림 이름 정의
extension Notification.Name {
    static let authenticationFailed = Notification.Name("authenticationFailed")
}


// 인증 실패 -> 화면으로 리디렉션하는 로직
/*
 .onReceive(NotificationCenter.default.publisher(for: .authenticationFailed)) { _ in
 viewStore.send(.logout)
 }
 */
