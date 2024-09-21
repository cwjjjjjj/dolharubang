import ComposableArchitecture
import XCTest

@testable import DolHaruBang

@MainActor
final class DolHaruBangTest: XCTestCase {
    
    func testFetchTalks() async {
        let store = await TestStore(initialState: TalkFeature.State()) {
            TalkFeature()
        } withDependencies: {
            // 의존성 주입 - 테스트 시 TalkClient에서 가상 데이터를 사용
            $0.talkClient.fetchTalks = {
                return Talk.mockTalks // 가상 데이터를 반환
            }
        }
        
        // [GET] fetchTalks 호출
        await store.send(.fetchTalks) {
            $0.isLoading = true // 통신 중 상태 업데이트
        }
        
        // fetchTalksResponse에 대한 응답을 받음
        await store.receive(\.fetchTalksResponse) {
            $0.isLoading = false // 로딩 상태 해제
            $0.talks = Talk.mockTalks // 가상 데이터가 상태에 반영되는지 확인
            $0.floatingDate = "2024년 9월 23일 Monday" // 마지막 대화의 날짜를 확인
        }
    }

    func testRegistTalk() async {
        let newTalk = Talk(
            diaryId: 3,
            contents: "새로운 대화입니다.",
            emoji: "😊",
            image: nil,
            reply: "답변입니다.",
            createdAt: Date(),
            modifiedAt: nil
        )

        let store = await TestStore(initialState: TalkFeature.State()) {
            TalkFeature()
        } withDependencies: {
            // 의존성 주입 - registTalk에 대한 성공 응답
            $0.talkClient.registTalk = { _ in
                return NetworkMessage(message: "등록 성공!")
            }
        }

        // [POST] 대화 등록 호출
        await store.send(.registTalk(newTalk)) {
            $0.isLoading = true // 로딩 중
        }

        // 등록 후 데이터가 잘 반영되었는지 확인
        await store.receive(\.registTalkResponse) {
            $0.isLoading = false // 로딩 해제
            $0.talks?.append(newTalk) // 새로운 대화 추가
        }
    }

    func testDeleteTalk() async {
        let store = await TestStore(initialState: TalkFeature.State(talks: Talk.mockTalks)) {
            TalkFeature()
        } withDependencies: {
            // deleteTalk에 대한 성공 응답
            $0.talkClient.deleteTalk = { diaryId in
                return NetworkMessage(message: "삭제 성공!")
            }
        }

        let diaryIdToDelete = 1

        // [DELETE] 대화 삭제 호출
        await store.send(.deleteTalk(diaryIdToDelete)) {
            $0.isLoading = true // 삭제 중 로딩 상태
        }

        // 삭제 후 상태 업데이트 확인
        await store.receive(\.deleteTalkResponse) {
            $0.isLoading = false // 로딩 해제
            $0.talks?.removeAll { $0.diaryId == diaryIdToDelete } // 해당 diaryId의 대화 삭제
        }
    }
}
