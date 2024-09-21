//
//  apiFetch.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/3/24.
//

import Alamofire
import Foundation

func fetch<T: Decodable>(
    url: String,
    model: T.Type,
    method: HTTPMethod,
    queryParameters: [String: String]? = nil,
    headers: HTTPHeaders? = nil,
    body: Data? = nil
) async throws -> T {
    return try await withCheckedThrowingContinuation { continuation in
        // URLRequest 객체 생성 및 요청 방법 설정
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = method.rawValue
        
        // 쿼리 파라미터 추가
        if let queryParameters = queryParameters {
            var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
            components.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
            request.url = components.url
        }

        // 헤더 추가
        if let headers = headers {
            request.headers = headers
        }

        // 바디 데이터 추가 (POST 및 PUT 요청 시 사용)
        if (method == .post || method == .put), let body = body {
            request.httpBody = body
        }

        // Alamofire 요청
        AF.request(request)
            .validate() // 응답 상태 코드 검증
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {
                        let jsonDecoder = JSONDecoder()
                        let decodedModel = try jsonDecoder.decode(T.self, from: data)
                        continuation.resume(returning: decodedModel)
                    } catch {
                        continuation.resume(throwing: error)
                    }
                    
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }
    }
}
