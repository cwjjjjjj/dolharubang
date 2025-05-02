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
        var selectMail : MailInfo?
        var mails : [MailInfo]?
        var clickMail : Bool = false
        var unreadCount : Int = 0
    }
    
    enum Action {
        case fetchMail
        case readMail(String)
        case fetchMailResponse(Result<[MailInfo], Error>)
        case readMailResponse(Result<MailInfo, Error>)
        
        case fetchUnRead
        case unReadResponse(Result<unReadMailCount, Error>)
        
        case selectMail(MailInfo)
        case closeMail
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
                
            case let .readMail(id):
                return .run { send in
                    do {
                        let mail = try await mailClient.readMail(id)
                        await send(.readMailResponse(.success(mail)))
                    } catch {
                        await send(.readMailResponse(.failure(error)))
                    }
                }
                
            case let .fetchMailResponse(.success(mails)):
                state.mails = mails
                return .none
                
            case let .fetchMailResponse(.failure(error)):
                print("mail ",error)
                return .none
                
            case let .readMailResponse(.success(mail)):
//                state.mails = mails // 업적 목록 갱신
                return .none
                
            case let .readMailResponse(.failure(error)):
                print("mail ",error)
                return .none
                
            case .fetchUnRead:
                return . run { send in
                    do {
                        let unreadCount = try await mailClient.unread()
                        await send(.unReadResponse(.success(unreadCount)))
                    } catch {
                        await send(.unReadResponse(.failure(error)))
                    }
                }
            
            case let .unReadResponse(.success(count)):
                state.unreadCount = count.unreadCount
                return .none
                
            case let .unReadResponse(.failure(error)):
                print("unread error ",error)
                return .none
                
            case let .selectMail(mail):
                state.selectMail = mail
                state.clickMail = true
                return .none
            
            case .closeMail:
                state.clickMail = false
                state.selectMail = nil
                return .none
       
            }
        }
    }
}
