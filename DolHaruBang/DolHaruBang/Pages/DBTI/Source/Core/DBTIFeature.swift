import SwiftUI
import ComposableArchitecture

@Reducer
struct DBTIFeature {
    @Dependency(\.dbtiClient) var dbtiClient
    
    @ObservableState
    struct State: Equatable {
        // InputUserInfoView 관련
        var username: String = "" // 유저이름
        var showAlert: Bool = false // 알림 창 띄우기 여부
        var inputAlertTitle: String = "" // 알림 창 제목
        var inputAlertMessage: String = "" // 알림 창 내용
        var showConfirmation: Bool = false // 확인 창
        var isNameConfirmed: Bool = false // 닉네임 확인 창
        
        // InputUserInfoView의 생년월일 관련
        var selectedYear: Int? = 2025
        var showYearPicker: Bool = false
        var selectedMonth: Int? = 1
        var showMonthPicker: Bool = false
        var selectedDay: Int? = 1
        var showDayPicker: Bool = false
        
        // QuestionView 관련
        var score: DBTIScore = DBTIScore()
        var questionIndex: Int = 0
        var showQuestion: Bool = false
        var showOptions: Bool = false
        var selectedOption: Int? = nil
        
        // ResultView 관련
        var nickname: String? = nil
        var isEditingName: Bool = false
        var isEditingRoomName: Bool = false
        var stoneName: String = "돌 이름"
        var originalStoneName: String = ""
        var spaceName: String = ""
        var originalRoomName: String = ""
        var tag: Int? = nil
        var emptyNameAlert: Bool = false
        var resultAlertTitle: String = ""
        var resultAlertMessage: String = ""
        var showResultAlert: Bool = false
        var selectedFaceShape: FaceShape = .sosim
        var finalButtonAvailable: Bool = true
        var isFinalButtonDisabled: Bool {
            stoneName.isEmpty
            || spaceName.isEmpty
            || isEditingName
            || isEditingRoomName
            || !finalButtonAvailable
        }
    }
    
    enum Action {
        // InputUserInfoView 관련
        case setUsername(String)
        case setShowAlert(Bool)
        case setAlertTitle(String)
        case setAlertMessage(String)
        case setShowConfirmation(Bool)
        case setIsNameConfirmed(Bool)
        case setSelectedYear(Int?)
        case setShowYearPicker(Bool)
        case setSelectedMonth(Int?)
        case setShowMonthPicker(Bool)
        case setSelectedDay(Int?)
        case setShowDayPicker(Bool)
        case checkUsername(String)
        case checkUsernameResult(Result<Bool, Error>)
        case submitMemberInfo(String, String)
        case submitMemberInfoResult(Result<Void, Error>)
        
        // QuestionView 관련
        case selectOption(Int)
        case addScore(QuestionType, Int)
        case nextQuestion
        case toggleQuestion
        case toggleOptions
        case goBack
        case goToResult
        
        // ResultView 관련
        case setStoneName(String)
        case setOriginalStoneName(String)
        case setIsEditingName(Bool)
        case setIsEditingRoomName(Bool)
        case setSpaceName(String)
        case setOriginalRoomName(String)
        case setTag(Int?)
        case setEmptyNameAlert(Bool)
        case adoptStone
        case adoptStoneResult(Result<Void, Error>)
        case goToHome
        case setResultAlertTitle(String)
        case setResultAlertMessage(String)
        case setShowResultAlert(Bool)
        case setFaceShape(FaceShape)
        case setFinalButton(Bool)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                    
                //////////////////////////////////////
                // QuestionView 관련 //
                /////////////////////////////////////
                case .selectOption(let index):
                    state.selectedOption = index
                    let option = questions[state.questionIndex].options[index]
                    let scoreValue = option.score ?? 0
                    let questionType = questions[state.questionIndex].about
                    return .send(.addScore(questionType, scoreValue))
                case .addScore(let questionType, let score):
                    switch questionType {
                        case .reality:
                            state.score.realityScore += score
                        case .thinking:
                            state.score.thinkingScore += score
                    }
                    return .none
                case .nextQuestion:
                    if state.questionIndex < 8 {
                        state.showOptions = false
                        state.showQuestion = false
                        state.questionIndex += 1
                        state.selectedOption = nil
                    }
                    else {
                        return .send(.goToResult)
                    }
                    return .none
                case .toggleQuestion:
                    state.showQuestion.toggle()
                    return .none
                case .toggleOptions:
                    state.showOptions.toggle()
                    return .none
                case .goBack:
                    if state.questionIndex > 0 {
                        state.questionIndex -= 1
                        state.selectedOption = nil
                    }
                    return .none
                case .goToResult:
                    state.stoneName = state.score.character.koreanName
                    state.originalStoneName = state.score.character.koreanName
                    state.selectedFaceShape = state.score.character.toFaceShape ?? .sosim
                    return .none

                ///////////////////////////////////
                // ResultView 관련 //
                ///////////////////////////////////
                case .setStoneName(let name):
                    state.stoneName = name
                    return .none
                case .setOriginalStoneName(let name):
                    state.originalStoneName = name
                    return .none
                case .setIsEditingName(let isEditing):
                    state.isEditingName = isEditing
                    return .none
                case .setIsEditingRoomName(let isEditing):
                    state.isEditingRoomName = isEditing
                    return .none
                case .setSpaceName(let name):
                    state.spaceName = name
                    return .none
                case .setOriginalRoomName(let name):
                    state.originalRoomName = name
                    return .none
                case .setTag(let tag):
                    state.tag = tag
                    return .none
                case .setEmptyNameAlert(let show):
                    state.emptyNameAlert = show
                    return .none
                case .adoptStone:
                    let speciesName = state.score.character.rawValue
                    let stoneName = state.stoneName
                    let spaceName = state.spaceName
                    
                    print(speciesName + " 입양 시도 as 돌 이름: " + stoneName + " & 방 이름: " + spaceName)

                    // 유효성 검사 (이미 버튼 비활성화로 막혀있다면 생략 가능)
                    if stoneName.isEmpty || spaceName.isEmpty || state.isEditingName || state.isEditingRoomName {
                        state.resultAlertTitle = "입력 오류"
                        state.resultAlertMessage = "돌 이름과 방 이름을 모두 입력해주세요."
                        state.showResultAlert = true
                        return .none
                    }

                    return .run { [speciesName, stoneName, spaceName] send in
                        do {
                            try await dbtiClient.adoptStone(speciesName, stoneName, spaceName)
                            await send(.adoptStoneResult(.success(())))
                        } catch {
                            await send(.adoptStoneResult(.failure(error)))
                        }
                    }
                case .adoptStoneResult(.success):
                    // 성공 시 홈 화면 이동
                    return .send(.goToHome)
                    
                case .adoptStoneResult(.failure):
                    state.resultAlertTitle = "입양 실패"
                    state.resultAlertMessage = "돌 입양에 실패했습니다. 네트워크 상태를 확인하거나, 다시 시도해주세요."
                    state.showResultAlert = true
                    return .none
                case .setShowResultAlert(let show):
                    state.showResultAlert = show
                    return .none
                case .setResultAlertTitle(let title):
                    state.resultAlertTitle = title
                    return .none
                case .setResultAlertMessage(let msg):
                    state.resultAlertMessage = msg
                    return .none
                    
                case .goToHome:
                    return .none
                    
                case let .setFaceShape(faceShape):
                    state.selectedFaceShape = faceShape
                    return .none
                
                case let .setFinalButton(available):
                    state.finalButtonAvailable = available
                    return.none
                
                ///////////////////////////////////////////////
                // InputUserInfoView 관련 //
                ///////////////////////////////////////////////
                case .setUsername(let name):
                    state.username = name
                    return .none
                case .setShowAlert(let show):
                    state.showAlert = show
                    return .none
                case .setAlertTitle(let title):
                    state.inputAlertTitle = title
                    return .none
                case .setAlertMessage(let msg):
                    state.inputAlertMessage = msg
                    return .none
                case .setShowConfirmation(let show):
                    state.showConfirmation = show
                    return .none
                case .setIsNameConfirmed(let confirmed):
                    state.isNameConfirmed = confirmed
                    return .none
                case .setSelectedYear(let year):
                    state.selectedYear = year
                    return .none
                case .setShowYearPicker(let show):
                    state.showYearPicker = show
                    return .none
                case .setSelectedMonth(let month):
                    state.selectedMonth = month
                    return .none
                case .setShowMonthPicker(let show):
                    state.showMonthPicker = show
                    return .none
                case .setSelectedDay(let day):
                    state.selectedDay = day
                    return .none
                case .setShowDayPicker(let show):
                    state.showDayPicker = show
                    return .none
                case let .checkUsername(username):
                    if username.isEmpty || username.count > 12 {
                        state.inputAlertTitle = "글자 수 오류"
                        state.inputAlertMessage = "닉네임은 1~12자로 입력해주세요."
                        state.showConfirmation = false
                        state.isNameConfirmed = false
                        state.showAlert = true
                        return .none
                    }
                    return .run { [username = username, dbtiClient = dbtiClient] send in
                        do {
                            let isAvailable = try await dbtiClient.checkUsername(username)
                            await send(.checkUsernameResult(.success(isAvailable)))
                        } catch {
                            await send(.checkUsernameResult(.failure(error)))
                        }
                    }
                case .checkUsernameResult(.success(let isAvailable)):
                    if isAvailable {
                        state.inputAlertTitle = "닉네임 사용 가능"
                        state.inputAlertMessage = "\(state.username)으로 하시겠습니까?"
                        state.showConfirmation = true
                        state.isNameConfirmed = false
                    } else {
                        state.inputAlertTitle = "닉네임 중복"
                        state.inputAlertMessage = "이 닉네임은 이미 사용 중입니다.\n다른 닉네임을 선택해주세요."
                        state.showConfirmation = false
                        state.isNameConfirmed = false
                    }
                    state.showAlert = true
                    return .none

                case .checkUsernameResult(.failure):
                    state.inputAlertTitle = "오류"
                    state.inputAlertMessage = "닉네임 중복 확인 중 오류가 발생했습니다."
                    state.showConfirmation = false
                    state.isNameConfirmed = false
                    state.showAlert = true
                    return .none
                    
                case let .submitMemberInfo(nickname, birthday):
                    return .run { send in
                        do {
                            try await dbtiClient.postMemberInfo(nickname: nickname, birthday: birthday)
                            await send(.submitMemberInfoResult(.success(())))
                        }
                        catch {
                            await send(.submitMemberInfoResult(.failure(error)))
                        }
                    }
                    .debounce(id: "submitMemberInfo", for: 1.5, scheduler: DispatchQueue.main)
                    
                case . submitMemberInfoResult(.success()):
                    print("성공")
                    return .none
                case .submitMemberInfoResult(.failure):
                    state.showConfirmation = false
                    state.isNameConfirmed = false
                    state.showAlert = true
                    return .none
                    
            }
        }
    }
}
