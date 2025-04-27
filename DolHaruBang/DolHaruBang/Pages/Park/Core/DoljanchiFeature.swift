import ComposableArchitecture
import Foundation

@Reducer
struct DoljanchiFeature {
    @Dependency(\.parkClient) var parkClient
    
    @ObservableState
    struct State: Equatable {
        var currentPage: Int = 0
        var maxPage: Int = 0;
        var rowNum: Int = 2;
        var colNum: Int = 2;
        var jarangs: [Jarang] = [];
        var isLoading: Bool = false
        var errorMessage: String? = nil
    }

    // 액션 정의
    enum Action: BindableAction {
        case binding(BindingAction<State>)
        case nextPage
        case previousPage
        case fetchFeed(Int, Int?, String?, Int?)
        case fetchFeedResponse(Result<[Jarang], Error>)
//        case registJarang(Jarang)
//        case registJarangResponse(Result<(NetworkMessage, Jarang), Error>)
    }

    // 리듀서 정의
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
                case .nextPage:
                    if state.currentPage != state.maxPage - 1 {
                        state.currentPage += 1
                    }
                    return .none
                case .previousPage:
                    if state.currentPage != 0 {
                        state.currentPage -= 1
                    }
                    return .none
                case .fetchFeed(let memberId, let lastId, let sortType, let size):
                    state.isLoading = true
                    print("자랑 피드 불러오기 시작")
                    return .run { send in
                        do {
                            let jarangs = try await parkClient.fetchFeed(memberId, lastId, sortType, size)
                            await send(.fetchFeedResponse(.success(jarangs)))
                        }
                        catch {
                            await send(.fetchFeedResponse(.failure(error)))
                        }
                    }
                case let .fetchFeedResponse(.success(jarangs)):
                    state.isLoading = false
                    state.jarangs = jarangs // 업적 목록 갱신
                    let contentPerPageNum = (state.rowNum * state.colNum)
                    if (contentPerPageNum <= 0) {state.maxPage = 1;}
                    else {state.maxPage = jarangs.count / contentPerPageNum + (jarangs.count % contentPerPageNum > 0 ? 1 : 0)}
                    print("받기 성공")
                    return .none
                    
                case let .fetchFeedResponse(.failure(error)):
                    print(error)
                    state.isLoading = false
                    state.errorMessage = error.localizedDescription
                    return .none
                    
//                case let .registJarang(jarang):
//                    print("----------------등록할 jarang의 정보----------------")
//                    dump(jarang)
//                    print("----------------등록할 jarang의 정보----------------")
//                    state.isLoading = true
//                    state.errorMessage = nil
//                    return .run { send in
//                        do {
//                            let response = try await parkClient.registJarang(jarang)
//                            await send(.registJarangResponse(.success((response, jarang))))
//                        } catch {
//                            await send(.registJarangResponse(.failure(error)))
//                        }
//                    }
                    
                    
                case .binding:
                    return .none
            }
        }
    }
}
