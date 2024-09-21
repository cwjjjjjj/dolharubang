import ComposableArchitecture
import SwiftUI

@Reducer
struct TalkFeature {
    @Dependency(\.talkClient) var talkClient
    
    @ObservableState
    struct State: Equatable {
        var talks: [Talk]? = []
        var isLoading: Bool = false
        var errorMessage: String? = nil
        var messageInput: String = "" // 사용자 입력값
        var floatingDate: Date = Date() // 보이는 대화 날짜
        var showEmojiGrid: Bool = false // 이모티콘 및 이미지 첨부용 그리드 보이는 상태
        var selectedEmoji: String? = nil // 고른 이모티콘
    }
    
    enum Action: BindableAction {
        case updateMessageInput(String)
        case updateFloatingDate(Date)
        case selectEmoji(String?)
        case toggleEmojiGrid
        case fetchTalk
        case fetchTalks
        case fetchTalkResponse(Result<Talk, Error>)
        case fetchTalksResponse(Result<[Talk], Error>)
        case registTalk(Talk)
        case registTalkResponse(Result<(NetworkMessage, Talk), Error>)
        case editTalk(Talk)
        case editTalkResponse(Result<(NetworkMessage, Talk), Error>)
        case deleteTalk(Int) // diaryId로 삭제
        case deleteTalkResponse(Result<(NetworkMessage, Int), Error>)
        case binding( BindingAction < State >)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.messageInput):
                return .none
            case .binding:
                return .none
            case let .updateMessageInput(input):
                state.messageInput = input
                return .none
            case .updateFloatingDate(let newDate):
                state.floatingDate = newDate
                return .none
            case .toggleEmojiGrid:
                state.showEmojiGrid.toggle()
                return .none
            case .selectEmoji(let emoji):
                if let emoji = emoji {
                    state.selectedEmoji = emoji // 선택된 이모지 업데이트
                }
                else {
                    state.selectedEmoji = nil
                }
                state.showEmojiGrid.toggle()
                return .none
                    
            // [GET] 대화 한 개 가져오기
            case .fetchTalk:
                state.isLoading = true
                return .run { send in
                    do {
                        let talk = try await talkClient.fetchTalk()
                        await send(.fetchTalkResponse(.success(talk)))
                    } catch {
                        await send(.fetchTalkResponse(.failure(error)))
                    }
                }
            case let .fetchTalkResponse(.success(talk)):
                state.isLoading = false
                state.talks?.append(talk) // 대화를 배열에 추가
                state.floatingDate = talk.createdAt
                return .none
            case let .fetchTalkResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
                    
            // [GET] 대화 전체 가져오기
            case .fetchTalks:
                state.isLoading = true
                return .run { send in
                    do {
                        let talks = try await talkClient.fetchTalks()
                        await send(.fetchTalksResponse(.success(talks)))
                    } catch {
                        await send(.fetchTalksResponse(.failure(error)))
                    }
                }
            case let .fetchTalksResponse(.success(talks)):
                state.isLoading = false
                state.talks = talks // 대화 목록 갱신
                if let lastTalk = talks.last {
                    state.floatingDate = lastTalk.createdAt // 첫 대화의 날짜 표시
                }
                return .none

            case let .fetchTalksResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            // [POST] 대화 등록하기
            case let .registTalk(talk):
                state.isLoading = true
                    return .run { send in
                        do {
                            let response = try await talkClient.registTalk(talk)
                            await send(.registTalkResponse(.success((response, talk))))
                        } catch {
                            await send(.registTalkResponse(.failure(error)))
                        }
                    }
            case let .registTalkResponse(.success(_, talk)):
                state.isLoading = false
                state.talks?.append(talk) // 등록 성공 시, 로컬에서 바로 추가
                return .none
            case let .registTalkResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            // [UPDATE] 대화 수정하기
            case let .editTalk(talk):
                state.isLoading = true
                return .run { send in
                    do {
                        let response = try await talkClient.editTalk(talk)
                        await send(.editTalkResponse(.success((response, talk))))
                    } catch {
                        await send(.editTalkResponse(.failure(error)))
                    }
                }
                case let .editTalkResponse(.success(_, updatedTalk)):
                    state.isLoading = false
                    if let index = state.talks?.firstIndex(where: { $0.diaryId == updatedTalk.diaryId }) {
                        state.talks?[index] = updatedTalk // 옵셔널 배열이므로 안전하게 접근
                    }
                return .none
            case let .editTalkResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none

            // [Delete] 대화 삭제하기
            case let .deleteTalk(diaryId):
                state.isLoading = true
                return .run { send in
                    do {
                        let response = try await talkClient.deleteTalk(diaryId)
                        await send(.deleteTalkResponse(.success((response, diaryId))))// 삭제 성공 시 응답과 diaryId 전달
                    } catch {
                        await send(.deleteTalkResponse(.failure(error)))
                    }
                }
            case let .deleteTalkResponse(.success((response, diaryId))):
                state.isLoading = false
                if let talks = state.talks, let index = talks.firstIndex(where: { $0.diaryId == diaryId }) {
                    state.talks?.remove(at: index)
                }
                return .none
            case let .deleteTalkResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = error.localizedDescription
                return .none
            }
        }
    }
}
