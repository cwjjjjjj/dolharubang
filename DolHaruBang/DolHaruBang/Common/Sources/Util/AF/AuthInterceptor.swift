//
//  AuthInterceptor.swift
//  DolHaruBang
//
//  Created by 양희태 on 4/14/25.
//

import Foundation
import Alamofire

class AuthInterceptor: RequestInterceptor {
    private let tokenManager = TokenManager.shared
    private let baseURL = "https://sole-organic-singularly.ngrok-free.app/api/v1"
    
    // 요청 전처리
    func adapt(_ urlRequest: URLRequest, for session: Session, completion: @escaping (Result<URLRequest, Error>) -> Void) {
        var urlRequest = urlRequest
        
        // 액세스 토큰이 필요한 요청인지 확인
        if urlRequest.headers["requiresToken"] == "true" {
            // 헤더에서 플래그 제거
            urlRequest.headers.remove(name: "requiresToken")
            
            // 토큰 가져오기
            if let token = tokenManager.getAccessToken() {
                // 인증 헤더 추가
                urlRequest.headers.add(.authorization(bearerToken: token))
            }
        }
        
        completion(.success(urlRequest))
    }
    
    // 요청 재시도 (401 에러 처리)
    func retry(_ request: Request, for session: Session, dueTo error: Error, completion: @escaping (RetryResult) -> Void) {
        // 401 에러인지 확인
        guard let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401 else {
            // 401이 아니면 재시도하지 않음
            return completion(.doNotRetry)
        }
        
        // 리프레시 토큰 가져오기
        guard let refreshToken = tokenManager.getRefreshToken() else {
            // 리프레시 토큰이 없으면 로그아웃 처리
            tokenManager.clearTokens()
            // 로그아웃 알림 발송
            NotificationCenter.default.post(name: NSNotification.Name("LogoutRequired"), object: nil)
            return completion(.doNotRetry)
        }
        
        // 토큰 갱신 요청
        refreshAccessToken(refreshToken: refreshToken) { [weak self] result in
            guard let self = self else { return completion(.doNotRetry) }
            
            switch result {
            case .success(let tokens):
                // 새 토큰 저장
                self.tokenManager.saveTokens(accessToken: tokens.accessToken, refreshToken: tokens.refreshToken)
                // 요청 재시도
                completion(.retry)
                
            case .failure(_):
                // 토큰 갱신 실패 시 로그아웃
                self.tokenManager.clearTokens()
                NotificationCenter.default.post(name: NSNotification.Name("LogoutRequired"), object: nil)
                completion(.doNotRetry)
            }
        }
    }
    
    // 토큰 갱신 요청
    private func refreshAccessToken(refreshToken: String, completion: @escaping (Result<(accessToken: String, refreshToken: String), Error>) -> Void) {
        let url = "\(baseURL)/auth/refresh"
        
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(refreshToken)"
        ]
        
        AF.request(url, method: .post, headers: headers).responseDecodable(of: RefreshTokenResponse.self) { response in
            switch response.result {
            case .success(let tokenResponse):
                completion(.success((accessToken: tokenResponse.accessToken, refreshToken: tokenResponse.refreshToken)))
                
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

// 토큰 응답 모델
struct RefreshTokenResponse: Decodable {
    let accessToken: String
    let refreshToken: String
}
