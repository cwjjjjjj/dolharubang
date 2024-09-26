//
//  MailFeature.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/26/24.
//


import UIKit
import ComposableArchitecture

@Reducer
struct MailFeature {
    
    @ObservableState
    struct State: Equatable {
        var mails : [MailInfo] = []
    }
    
    enum Action {
        case fetchMail
        case fetchMailResponse(Result<[MailInfo], Error>)
    }
    
    @Dependency(\.mailClient) var mailClient
    
    var body : some ReducerOf <Self> {
        
        Reduce { state, action in
        
            switch action {
                
            case .fetchMail:
                return .run { send in
                    do {
                        let mails = try await mailClient.fetchMail()
                        await send(.fetchMailResponse(.success(mails)))
                    } catch {
                        await send(.fetchMailResponse(.failure(error)))
                    }
                }
                
            case let .fetchMailResponse(.success(mails)):
                state.mails = mails // 업적 목록 갱신
                return .none
                
            case let .fetchMailResponse(.failure(error)):
                return .none
       
            }
        }
    }
}
