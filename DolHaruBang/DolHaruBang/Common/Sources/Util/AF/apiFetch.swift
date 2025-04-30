import Alamofire
import Foundation

// 토큰 응답 모델
struct TokenResponse: Decodable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
}

// 에러 타입
enum APIError: Error {
    case tokenRefreshFailed
    case unauthorized(ErrorResponse)
    case networkError
    case tokenEmpty
    case modelTypeError
    case decodingError // 새로 추가
}

struct EmptyResponse: Decodable {}

struct ErrorResponse: Decodable {
    let message: String
    let code: String
}

// MARK: fetch 함수
// baseURL 자동 합체
// 토큰 관리
// 제네릭 사용으로 다양한 모델 타입 대응
// async throws로 비동기 함수 + 에러 처리
func fetch<T: Decodable>(
    url: String, // 요청 endpoint 주소
    model: T.Type,
    method: HTTPMethod,
    queryParameters: [String: String]? = nil, // 파라미터 있는 경우 넣기 (Optional)
    headers: HTTPHeaders? = nil,
    body: Data? = nil,
    skipAuth: Bool = false // 인증 토큰 추가 여부
) async throws -> T {
    // baseURL과 경로 합체
    let fullURL: String
    if url.hasPrefix("http") {
        fullURL = url
    } else {
        fullURL = APIConstants.baseURL + url
    }
    
    // 헤더 준비
    var finalHeaders = headers ?? HTTPHeaders()
    
    // 인증 토큰 자동 추가 (skipAuth가 false일 때만)
    if !skipAuth, let accessToken = TokenManager.shared.getAccessToken() {
        finalHeaders.add(.authorization(bearerToken: accessToken))
    }
    
    finalHeaders.add(name: "Content-Type", value: "application/json")
    
    // 요청 준비
    var request = URLRequest(url: URL(string: fullURL)!)
    request.httpMethod = method.rawValue
    
    // 쿼리 파라미터 추가
    if let queryParameters = queryParameters {
        var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
        components.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        request.url = components.url
    }
    
    // 헤더 추가
    request.headers = finalHeaders
    
    // 바디 데이터 추가 (POST 및 PUT 요청 시 사용)
    if (method == .post || method == .put), let body = body {
        request.httpBody = body
    }
    
    do {
        return try await executeRequest(request: request, model: model)
    } catch let error as APIError {
        // 토큰 갱신 실패 시에만 토큰 삭제
        if case APIError.tokenRefreshFailed = error {
            TokenManager.shared.clearTokens()
            throw error
        }
        
        // decodingError는 토큰 삭제 없이 상위 레이어로 전파
        if case APIError.decodingError = error {
            throw error
        }
        
        // 나머지 에러 처리 로직 (기존과 동일)
        if case let APIError.unauthorized(errorResponse) = error,
           errorResponse.code == "UNAUTHORIZED", !skipAuth {
            // 토큰 갱신 시도 로직 (기존과 동일)
        }
        throw error
    }

}

// 요청 실행 함수 (중복 코드 제거)
private func executeRequest<T: Decodable>(request: URLRequest, model: T.Type) async throws -> T {
    return try await withCheckedThrowingContinuation { continuation in
        AF.request(request)
            .responseData { response in
                switch response.result {
                case .success(let data):
                    do {                    
                        let jsonDecoder = JSONDecoder()
                        let dateFormatter = DateFormatter()
//                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                        dateFormatter.timeZone = TimeZone(identifier: "Asia/Seoul")
                        jsonDecoder.dateDecodingStrategy = .formatted(dateFormatter)
                        let decodedModel = try jsonDecoder.decode(T.self, from: data)
                        continuation.resume(returning: decodedModel)
                    } catch let decodingError {
                        print("디코딩 오류: \(decodingError)")
                        
                        do {
                            let errorResponse = try JSONDecoder().decode(ErrorResponse.self, from: data)
                            if errorResponse.code == "UNAUTHORIZED" {
                                continuation.resume(throwing: APIError.unauthorized(errorResponse))
                            } else {
                                continuation.resume(throwing: APIError.modelTypeError)
                            }
                        } catch {
                            // ErrorResponse 디코딩도 실패하면 decodingError 발생
                            continuation.resume(throwing: APIError.decodingError)
                        }
                    }

                    
                case .failure(let error):
                    print("네트워크 오류: \(error)")
                    continuation.resume(throwing: APIError.networkError)
                }
            }
    }
}


// 토큰 갱신 함수
private func refreshAccessToken() async throws -> TokenResponse {
    guard let refreshToken = TokenManager.shared.getRefreshToken() else {
        throw APIError.tokenEmpty
    }
    
    let headers: HTTPHeaders = [
        "Content-Type": "application/json",
        "Authorization": "Bearer \(refreshToken)"
    ]
    
    
    // 토큰 갱신 요청 (skipAuth=true로 설정하여 무한 루프 방지)
    return try await fetch(
        url: APIConstants.Endpoints.refresh,
        model: TokenResponse.self,
        method: .post,
        headers: headers,
        skipAuth: true
    )
}

// HTTP 메서드 정의
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
}
