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
    case decodingError // 새로 추가
}

struct EmptyResponse: Decodable {}

struct ErrorResponse: Decodable {
    let message: String
    let code: String
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
// baseURL 처리
// 토큰 관리
// 제네릭 사용으로 다양한 모델 타입 대응
// 에러핸들링
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
        //        print("엑세스토큰 ", accessToken)
    }
    
    if finalHeaders["Content-Type"] == nil {
        finalHeaders.add(name: "Content-Type", value: "application/json")
    }
    
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
    
    // 바디 데이터 추가 (POST 및 PUT 및 PATCH 요청 시 사용)
    if (method == .post || method == .put || method == .patch), let body = body {
        request.httpBody = body
    }
    
    do {
        return try await executeRequest(request: request, model: model)
    } catch let error as APIError {
        switch error {
        case APIError.unauthorized:
            print("엑세스 토큰 만료")
        case APIError.tokenRefreshFailed:
            print("엑세스 토큰 갱신 에러")
            TokenManager.shared.clearTokens()
        case APIError.networkError:
            print("네트워크에러")
            TokenManager.shared.clearTokens()
            
        case APIError.decodingError:
            print("디코딩에러")
        default:
            print("아무튼 에러")
            TokenManager.shared.clearTokens()
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
                
                dump(response)
                
                // 401
                if statusCode == 401 {
                    print("401진입")
                    Task {
                        do {
                            let newToken = try await refreshAccessToken()
                            TokenManager.shared.saveTokens(accessToken: newToken.accessToken, refreshToken: newToken.refreshToken)
                            print("1")
                            var newRequest = request
                            newRequest.setValue("Bearer \(newToken.accessToken)", forHTTPHeaderField: "Authorization")
                            print("2")
                            let result = try await executeRequest(request: newRequest, model: model)
                            print("3")
                            continuation.resume(returning: result)
                        } catch {
                            print("재발급 과정에서 에러")
                            continuation.resume(throwing: APIError.tokenRefreshFailed)
                        }
                    }
                    return // 반드시 return!
                }
                
                
                if statusCode == 403 {
                    print("403")
                    continuation.resume(throwing: APIError.tokenRefreshFailed)
                    return
                }
                
                // 204 No Content 처리
                if statusCode == 204, model is EmptyResponse.Type {
                    continuation.resume(returning: EmptyResponse() as! T)
                    return
                }
                
                switch response.result {
                case .success(let data):
                    do {
                        
                        // 상태 코드 확인 (204 No Content 처리)
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
                        // 기타 디코딩 에러 처리
                        continuation.resume(throwing: APIError.decodingError)
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
            skipAuth: true // 엑세스 토큰이 아닌 리프레시 토큰이 헤더가 되도록
        )
    } catch {
        print("리프레시 요청에서 잡은 에러")
        throw APIError.tokenRefreshFailed
    }
}
