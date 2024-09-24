//
//  TrophyListFeature.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/23/24.
//

import ComposableArchitecture

@Reducer
struct TrophyListFeature {
    
    @Dependency(\.trophyClient) var trophyClient
    
    @ObservableState
    struct State : Equatable {
        var trophys: [Trophy]? = []
        var isLoading : Bool = false
        var errorMessage: String? = nil
       
    }
    
    enum Action {
        case fetchTrophys
        case fetchTrophysResponse(Result<[Trophy], Error>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case .fetchTrophys:
                state.isLoading = true
                return .run { send in
                    do {
                        let trophies = try await trophyClient.fetchTrophy()
                        await send(.fetchTrophysResponse(.success(trophies)))
                    } catch {
                        await send(.fetchTrophysResponse(.failure(error)))
                    }
                }
                
            case let .fetchTrophysResponse(.success(trophies)):
                state.isLoading = false
                state.trophys = trophies // 업적 목록 갱신
                return .none
                
            case let .fetchTrophysResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                
            }
        }
        
    }
}
