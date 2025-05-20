import ComposableArchitecture
import SwiftUI

enum DeleteTarget: Equatable {
    case CONTENT
    case EMOJI
    case IMAGE
    case REPLY
    
    var caseName: String { String(describing: self) }
    
    var displayName: String {
        switch self {
        case .CONTENT: return "일기 내용"
        case .EMOJI: return "이모티콘"
        case .IMAGE: return "사진"
        case .REPLY: return "답장"
        }
    }
}

@Reducer
struct TalkFeature {
    @Dependency(\.talkClient) var talkClient
    
    @ObservableState
    struct State: Equatable {
        var talks: [Talk]? = []
        var isLoading: Bool = false
        var showDeleteAlert: Bool = false
        var showErrorAlert: Bool = false
        var deleteTarget: DeleteTarget? = nil
        var errorMessage: String? = nil
        var messageInput: String = "" // 사용자 입력값
        var floatingDate: Date = Date() // 보이는 대화 날짜
        var showEmojiGrid: Bool = false // 이모티콘 및 이미지 첨부용 그리드 보이는 상태
        var selectedEmoji: String? = nil // 고른 이모티콘
        var showImagePicker: Bool = false // ImagePicker 표시 상태
        var selectedImage: UIImage? = nil // 고른 사진
        var showImagePreview: Bool = false // 고른 사진 보내기 전 확인용 뷰 표시 상태
        var messageCount : Int = 0
    }
    
    enum Action: BindableAction {
        case toggleDeleteAlert(DeleteTarget?)
        case updateMessageInput(String)
        case updateFloatingDate(Date)
        case selectEmoji(String?)
        case toggleEmojiGrid
        case toggleImagePicker
        case imagePicked(UIImage?)
        case toggleImagePreview
        case fetchTalk(Int) // diaryId로 단일 대화 가져오기
        case fetchTalkResponse(Result<Talk, Error>)
        case fetchTalks
        case fetchTalksResponse(Result<[Talk], Error>)
        case registTalk(TalkToCreate)
        case registTalkResponse(Result<Talk, Error>)
//        case editTalk(Talk)
//        case editTalkResponse(Result<(NetworkMessage, Talk), Error>)
        case deletePart(Int, DeleteTarget) // talk 일부 삭제
        case deletePartResponse(Result<Talk, Error>)
        case deleteTalk(Int) // talk 전체 삭제
        case deleteTalkResponse(Result<(NetworkMessage, Int), Error>)
        case binding( BindingAction < State >)
    }
    
    var body: some ReducerOf<Self> {
        BindingReducer()
        Reduce { state, action in
            switch action {
            case .binding(\.messageInput):
                state.messageCount = state.messageInput.count
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
            case let .toggleDeleteAlert(deleteTarget):
                state.deleteTarget = deleteTarget
                state.showDeleteAlert.toggle()
                return .none
            case .selectEmoji(let emoji):
                if let emoji = emoji {
                    state.selectedEmoji = emoji // 선택된 이모지 업데이트
                }
                else {
                    state.selectedEmoji = nil
                }
                if (state.showEmojiGrid == true) {
                    state.showEmojiGrid.toggle()
                }
                return .none
            case .toggleImagePicker:
                state.showImagePicker.toggle()
                return .none
            case .imagePicked(let image):
                if let image = image {
                    state.selectedImage = image // 선택된 사진 업데이트
                    if (state.showEmojiGrid == true) {
                        state.showEmojiGrid.toggle()
                    }
                }
                else {
                    state.selectedImage = nil
                }
                return .none
            case .toggleImagePreview:
                state.showImagePreview.toggle()
                return .none
                    
            // MARK: [GET] 대화 한 개 가져오기
            case let .fetchTalk(diaryId):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let talk = try await talkClient.fetchTalk(diaryId)
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
                state.errorMessage = "대화를 불러오지 못했습니다"
                state.showErrorAlert = true
                return .none


            // MARK: [GET] 대화 전체 가져오기
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
                state.errorMessage = "대화 목록을 불러오지 못했습니다"
                state.showErrorAlert = true
                return .none

            // MARK: [POST] 대화 등록하기
            case let .registTalk(talk):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let response = try await talkClient.registTalk(talk)
                        await send(.registTalkResponse(.success(response)))
                    } catch {
                        await send(.registTalkResponse(.failure(error)))
                    }
                }
            case let .registTalkResponse(.success(talk)):
                state.isLoading = false
                state.talks?.append(talk) // 등록 성공 시 추가
                state.messageInput = "" // 입력 필드 초기화
                state.selectedEmoji = nil // 선택된 이모지 초기화
                state.selectedImage = nil // 선택된 이미지 초기화
                return .none
//            case let .registTalkResponse(.failure(error)):
//                state.isLoading = false
//                state.errorMessage = "대화 등록에 실패했습니다"
//                state.showErrorAlert = true
//                return .none
            case let .registTalkResponse(.failure(error)):
                state.isLoading = false

                if let urlError = error as? URLError {
                    state.errorMessage = "네트워크 오류입니다"
                } else if let decodingError = error as? DecodingError {
                    state.errorMessage = "응답 형태 오류입니다"
                } else if let errorResponse = error as? LocalizedError, let msg = errorResponse.errorDescription {
                    state.errorMessage = msg
                } else {
                    state.errorMessage = "에러 발생"
                }

                state.showErrorAlert = true
                return .none

            // [UPDATE] 대화 수정하기
//            case let .editTalk(talk):
//                state.isLoading = true
//                return .run { send in
//                    do {
//                        let response = try await talkClient.editTalk(talk)
//                        await send(.editTalkResponse(.success((response, talk))))
//                    } catch {
//                        await send(.editTalkResponse(.failure(error)))
//                    }
//                }
//                case let .editTalkResponse(.success(_, updatedTalk)):
//                    state.isLoading = false
//                    if let index = state.talks?.firstIndex(where: { $0.diaryId == updatedTalk.diaryId }) {
//                        state.talks?[index] = updatedTalk // 옵셔널 배열이므로 안전하게 접근
//                    }
//                return .none
//            case let .editTalkResponse(.failure(error)):
//                state.isLoading = false
//                state.errorMessage = error.localizedDescription
//                return .none

            // MARK: 특정 컨텐츠(내용 / 이모지 / 사진 / 답장 중 1개) 삭제 하기
            case let .deletePart(diaryId, deleteTarget):
                state.isLoading = true
                return .run { send in
                    do {
                        let updatedTalk = try await talkClient.deletePart(diaryId, deleteTarget)
                        await send(.deletePartResponse(.success((updatedTalk))))
                    }
                    catch {
                        await send(.deletePartResponse(.failure(error)))
                    }
                }
            
            case let .deletePartResponse(.success(updatedTalk)):
                state.isLoading = false
                    
                if let idx = state.talks?.firstIndex(where: { $0.diaryId == updatedTalk.diaryId }) {
                    state.talks?[idx] = updatedTalk
                }
                    
                state.showDeleteAlert = false
                state.deleteTarget = nil
                return .none

            case let .deletePartResponse(.failure(error)):
                state.isLoading = false
//                state.errorMessage = "\(state.deleteTarget?.displayName ?? "타깃 없음") 삭제에 실패했습니다: \(error.localizedDescription)"
                state.errorMessage = "\(state.deleteTarget?.displayName ?? "타깃 없음") 삭제에 실패했습니다: \(error.localizedDescription)"
                state.showDeleteAlert = true
                state.deleteTarget = nil
                return .none
                    
            // MARK: [Delete] 대화 삭제하기
            case let .deleteTalk(diaryId):
                state.isLoading = true
                state.errorMessage = nil
                return .run { send in
                    do {
                        let response = try await talkClient.deleteTalk(diaryId)
                        await send(.deleteTalkResponse(.success((response, diaryId))))
                    } catch {
                        await send(.deleteTalkResponse(.failure(error)))
                    }
                }
            case let .deleteTalkResponse(.success((_, diaryId))):
                state.isLoading = false
                if let index = state.talks?.firstIndex(where: { $0.diaryId == diaryId }) {
                    state.talks?.remove(at: index)
                }
                return .none
            case let .deleteTalkResponse(.failure(error)):
                state.isLoading = false
                state.errorMessage = "대화 삭제에 실패했습니다: \(error.localizedDescription)"
                state.showErrorAlert = true
                return .none
            }
        }
    }
}
