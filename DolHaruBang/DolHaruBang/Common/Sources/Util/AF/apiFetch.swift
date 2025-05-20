import Alamofire
import Foundation

// HTTP 메서드 정의
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case patch = "PATCH"
    case put = "PUT"
    case delete = "DELETE"
}

// 토큰 응답 모델
struct TokenResponse: Decodable, Equatable, Sendable {
    let accessToken: String
    let refreshToken: String
}

// 에러 타입
enum APIError: Error {
    case tokenRefreshFailed
    case unauthorized
    case networkError
    case tokenEmpty
    case modelTypeError
    case decodingError
}

struct EmptyResponse: Decodable {}

private struct ErrorResponse: Decodable, Error, LocalizedError {
    let message: String
    let errorCode: String

    var errorDescription: String? { message }
}

func makeMultipartBody(
    dataDict: [String: Any],
    imageData: Data?,
    imageMimeType: String = "image/jpeg"
) -> (body: Data, boundary: String) {
    let boundary = "Boundary-\(UUID().uuidString)"
    var body = Data()
    let lineBreak = "\r\n"
    
    // 1. data 필드 (JSON 문자열)
    let jsonData = try! JSONSerialization.data(withJSONObject: dataDict, options: [])
    body.append("--\(boundary)\(lineBreak)".data(using: .utf8)!)
    body.append("Content-Disposition: form-data; name=\"data\"\(lineBreak)".data(using: .utf8)!)
    body.append("Content-Type: application/json\(lineBreak)\(lineBreak)".data(using: .utf8)!)
    body.append(jsonData)
    body.append(lineBreak.data(using: .utf8)!)
    
    // 2. image 필드 (파일)
    if let imageData = imageData {
        body.append("--\(boundary)\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\(lineBreak)".data(using: .utf8)!)
        body.append("Content-Type: \(imageMimeType)\(lineBreak)\(lineBreak)".data(using: .utf8)!)
        body.append(imageData)
        body.append(lineBreak.data(using: .utf8)!)
    }
    
    // 종료 바운더리
    body.append("--\(boundary)--\(lineBreak)".data(using: .utf8)!)
    return (body, boundary)
}

// MARK: fetch 함수
func fetch<T: Decodable>(
    url: String,
    model: T.Type,
    method: HTTPMethod,
    queryParameters: [String: String]? = nil,
    headers: HTTPHeaders? = nil,
    body: Data? = nil,
    skipAuth: Bool = false
) async throws -> T {
    let fullURL: String
    if url.hasPrefix("http") {
        fullURL = url
    } else {
        fullURL = APIConstants.baseURL + url
    }
    
    var finalHeaders = headers ?? HTTPHeaders()
    
    if !skipAuth, let accessToken = TokenManager.shared.getAccessToken() {
        finalHeaders.add(.authorization(bearerToken: accessToken))
    }
    
    if finalHeaders["Content-Type"] == nil {
        finalHeaders.add(name: "Content-Type", value: "application/json")
    }
    
    var request = URLRequest(url: URL(string: fullURL)!)
    request.httpMethod = method.rawValue
    
    if let queryParameters = queryParameters {
        var components = URLComponents(url: request.url!, resolvingAgainstBaseURL: false)!
        components.queryItems = queryParameters.map { URLQueryItem(name: $0.key, value: $0.value) }
        request.url = components.url
    }
    
    request.headers = finalHeaders
    
    if (method == .post || method == .put || method == .patch), let body = body {
        request.httpBody = body
    }
    
    do {
        return try await executeRequest(request: request, model: model)
    } catch let error as APIError {
        switch error {
        case .unauthorized, .tokenRefreshFailed:
            print("엑세스 토큰 만료 또는 갱신 에러 - 토큰 삭제 및 로그아웃")
            TokenManager.shared.clearTokens()
        // 네트워크 에러, 디코딩 에러 등은 토큰 삭제/로그아웃 하지 않음
        case .networkError:
            print("네트워크에러")
        case .decodingError:
            print("디코딩에러")
        default:
            print("기타 에러")
        }
        throw error
    }
}

// 실제 통신 부분
private func executeRequest<T: Decodable>(request: URLRequest, model: T.Type) async throws -> T {
    return try await withCheckedThrowingContinuation { continuation in
        AF.request(request)
            .responseData { response in
                let statusCode = response.response?.statusCode
                let requestPath = request.url?.path ?? ""

                // 401 또는 403 처리
                if statusCode == 401 || statusCode == 403 {
                    if !requestPath.contains("/reissue") {
                        Task {
                            do {
                                print("리프레시 재발급")
                                let newToken = try await refreshAccessToken()
                                TokenManager.shared.saveTokens(accessToken: newToken.accessToken, refreshToken: newToken.refreshToken)
                                var newRequest = request
                                newRequest.setValue("Bearer (newToken.accessToken)", forHTTPHeaderField: "Authorization")
                                let result = try await executeRequest(request: newRequest, model: model)
                                continuation.resume(returning: result)
                            } catch {
                                print("재발급 과정에서 에러")
                                continuation.resume(throwing: APIError.tokenRefreshFailed)
                            }
                        }
                        return 
                    } else {
                        // /reissue 요청에서 401/403이면 바로 실패
                        continuation.resume(throwing: APIError.tokenRefreshFailed)
                        return 
                    }
                }
                
                // 204 No Content 처리
                if statusCode == 204, model is EmptyResponse.Type {
                    continuation.resume(returning: EmptyResponse() as! T)
                    return
                }
                
                switch response.result {
                case .success(let data):
                    do {
                        let statusCode = response.response?.statusCode ?? 0
                        let contentType = response.response?.allHeaderFields["Content-Type"] as? String ?? ""
                        
                        // 200~299가 아닌 경우
                        if !(200...299).contains(statusCode) {
                            if contentType.contains("application/json"),
                               let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                                continuation.resume(throwing: errorResponse)
                            } else {
                                continuation.resume(throwing: APIError.networkError)
                            }
                            return
                        }
                        if let httpResponse = response.response, httpResponse.statusCode == 204, model is EmptyResponse.Type {
                            continuation.resume(returning: EmptyResponse() as! T)
                            return
                        }

                        let jsonDecoder = JSONDecoder()
                        let dateFormatterWithMillis = DateFormatter()
                        dateFormatterWithMillis.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
                        dateFormatterWithMillis.timeZone = TimeZone(identifier: "Asia/Seoul")
                        
                        let dateFormatterWithoutMillis = DateFormatter()
                        dateFormatterWithoutMillis.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                        dateFormatterWithoutMillis.timeZone = TimeZone(identifier: "Asia/Seoul")
                        
                        jsonDecoder.dateDecodingStrategy = .custom { decoder in
                            let container = try decoder.singleValueContainer()
                            let dateString = try container.decode(String.self)
                            if let date = dateFormatterWithMillis.date(from: dateString) {
                                return date
                            }
                            if let date = dateFormatterWithoutMillis.date(from: dateString) {
                                return date
                            }
                            throw DecodingError.dataCorruptedError(in: container,
                                                                   debugDescription: "Date string does not match expected format.")
                        }
                        
                        let decodedModel = try jsonDecoder.decode(T.self, from: data)
                        continuation.resume(returning: decodedModel)
                    } catch {
                        continuation.resume(throwing: APIError.decodingError)
                        return
                    }
                case .failure(let error):
                    print("네트워크 오류: \(error)")
                    continuation.resume(throwing: APIError.networkError)
                    return
                }
            }
    }
}


// 토큰 갱신 함수
private func refreshAccessToken() async throws -> TokenResponse {
    print("함수 진입")
    guard let refreshToken = TokenManager.shared.getRefreshToken() else {
        throw APIError.tokenEmpty
    }
    
    print("리프레시 토큰 가져오기 성공")
    
    let headers: HTTPHeaders = [
        "Content-Type": "application/json",
        "Authorization": "Bearer \(refreshToken)"
    ]
    
    do {
        return try await fetch(
            url: APIConstants.Endpoints.refresh,
            model: TokenResponse.self,
            method: .post,
            headers: headers,
            skipAuth: true
        )
    } catch {
        print("리프레시 요청에서 잡은 에러")
        throw APIError.tokenRefreshFailed
    }
}
