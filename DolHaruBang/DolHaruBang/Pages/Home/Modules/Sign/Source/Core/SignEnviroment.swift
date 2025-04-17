//
//  SignEnviroment.swift
//  DolHaruBang
//
//  Created by 양희태 on 11/20/24.
//

import Foundation
import ComposableArchitecture
import Alamofire


struct SignInfo: Hashable, Codable {
    // 백엔드와 동일한 키값으로 설정해주어야함
    let signText : String
}

struct SignRequestBody: Encodable {
        let text: String
    }

@DependencyClient
struct SignClient {
    var fetchSign : @Sendable () async throws -> SignInfo
    var applySign : @Sendable (String) async throws -> SignInfo
}

// 실제 통신 전 테스트
extension SignClient: TestDependencyKey {
    static let previewValue = Self()

    static let testValue = Self()
}

extension DependencyValues {
    var signClient: SignClient {
        get { self[SignClient.self] }
        set { self[SignClient.self] = newValue }
    }
}

extension SignClient: DependencyKey {
    static let liveValue = SignClient(
        fetchSign: {
            
            let url = APIConstants.Endpoints.sign
            
            return try await fetch(url: url, model: SignInfo.self, method: .get)
            
        },
        applySign:{ text in
            let url = APIConstants.Endpoints.sign
           
            let requestBody = SignRequestBody(text: text)

            let bodyData = try JSONEncoder().encode(requestBody)

            return try await fetch(url: url, model: SignInfo.self, method: .post,body: bodyData)
        }
   
    )
}

extension SignInfo {
    static let mockSignInfo = SignInfo(
        signText : "찬이"
    )
}

private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  let formatter = DateFormatter()
  decoder.dateDecodingStrategy = .formatted(formatter)
  return decoder
}()
