//
//  HomeEnviroment.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/4/24.
//
import Foundation
import ComposableArchitecture
import Alamofire

struct Peperoni: Decodable, Equatable, Sendable {
  var message : String
}

@DependencyClient
struct TmpClient {
    var regist: @Sendable () async throws -> Peperoni
}

// 실제 통신 전 테스트
extension TmpClient: TestDependencyKey {
    // 여기서의 Self는 TmpClient
    static let previewValue = Self()

    static let testValue = Self()
}

extension DependencyValues {
    var tmpClient: TmpClient {
        get { self[TmpClient.self] }
        set { self[TmpClient.self] = newValue }
    }
}

extension TmpClient: DependencyKey {
    static let liveValue = TmpClient(
        regist: {
            
               let url = "http://211.49.26.51:8080/api/v1/pepperoni"
//            let queryParameters: [String: String] = ["param1": "value1"] // 필요에 따라 설정
//            let headers: HTTPHeaders = ["Authorization": "Bearer token"] // 필요에 따라 설정
//            return try await fetch(url, model: Peperoni.self, queryParameters: queryParameters, headers: headers)
               return try await fetch(url: url, model: Peperoni.self, method: .get)
                 
            
        }
    )
}


private let jsonDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  let formatter = DateFormatter()
  decoder.dateDecodingStrategy = .formatted(formatter)
  return decoder
}()
