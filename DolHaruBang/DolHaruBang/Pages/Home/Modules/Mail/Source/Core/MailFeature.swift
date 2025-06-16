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
        
        // pagination 관련 상태값들
        var currentPage: Int = 0
        var pageSize: Int = 8
        var isLoading: Bool = false
        var isRefreshing: Bool = false
        var hasMorePages: Bool = true
    }
    
    enum Action {
        case fetchMail
        case fetchMoreMail // 추가 페이지 로드
        case refreshMail // 새로고침
        case readMail(String)
        case fetchMailResponse(Result<[MailInfo], Error>)
        case fetchMoreMailResponse(Result<[MailInfo], Error>) // 추가 페이지 응답
        case refreshMailResponse(Result<[MailInfo], Error>) // 새로고침 응답
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
                    state.currentPage = 0
                    state.isLoading = true
                    state.hasMorePages = true
                    return .run { [page = state.currentPage, size = state.pageSize] send in
                        do {
                            let mails = try await mailClient.fetchMail(page: page, size: size)
                            await send(.fetchMailResponse(.success(mails)))
                        } catch {
                            await send(.fetchMailResponse(.failure(error)))
                        }
                    }
                    
                case .fetchMoreMail:
                    guard !state.isLoading && state.hasMorePages else { return .none }
                    state.isLoading = true
                    let nextPage = state.currentPage + 1
                    return .run { [page = nextPage, size = state.pageSize] send in
                        do {
                            let mails = try await mailClient.fetchMail(page: page, size: size)
                            await send(.fetchMoreMailResponse(.success(mails)))
                        } catch {
                            await send(.fetchMoreMailResponse(.failure(error)))
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
                    
                case .refreshMail:
                    // 이미 새로고침 중이면 무시
                    guard !state.isRefreshing else { return .none }
                    
                    state.isRefreshing = true
                    state.currentPage = 0
                    return .run { [size = state.pageSize] send in
                        do {
                            let mails = try await mailClient.fetchMail(page: 0, size: size)
                            await send(.refreshMailResponse(.success(mails)))
                        } catch {
                            await send(.refreshMailResponse(.failure(error)))
                        }
                    }
                    .cancellable(id: "refresh", cancelInFlight: true)

                case let .refreshMailResponse(.success(mails)):
                    state.mails = mails
                    state.isRefreshing = false
                    state.hasMorePages = mails.count == state.pageSize
                    state.currentPage = 0
                    return .none

                case let .refreshMailResponse(.failure(error)):
                    state.isRefreshing = false
                    return .none

                    
                case let .fetchMailResponse(.success(mails)):
                    state.mails = mails
                    state.isLoading = false
                    state.hasMorePages = mails.count == state.pageSize
                    return .none
                    
                case let .fetchMoreMailResponse(.success(newMails)):
                    state.mails?.append(contentsOf: newMails)
                    state.currentPage += 1
                    state.isLoading = false
                    state.hasMorePages = newMails.count == state.pageSize
                    return .none
                    
                case let .fetchMailResponse(.failure(error)):
                    print("mail error ", error)
                    state.isLoading = false
                    return .none
                    
                case let .fetchMoreMailResponse(.failure(error)):
                    print("more mail error ", error)
                    state.isLoading = false
                    return .none
                    
                case let .readMailResponse(.success(mail)):
//                    state.mails = mails // 업적 목록 갱신
                    return .none
                    
                case let .readMailResponse(.failure(error)):
                    print("mail error ",error)
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
                    return .send(.readMail(String(mail.id)))
                    
                case .closeMail:
                    state.clickMail = false
                    state.selectMail = nil
                    return .none
                    
            }
        }
    }
}
