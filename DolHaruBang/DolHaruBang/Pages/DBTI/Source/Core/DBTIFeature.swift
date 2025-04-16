import SwiftUI
import ComposableArchitecture

@Reducer
struct DBTIFeature {
    @ObservableState
    struct State: Equatable {
        var score: DBTIScore
        var questionIndex: Int
        var selectedOption: Int?
        
        init(score: DBTIScore = DBTIScore(), questionIndex: Int = 0, selectedOption: Int? = nil) {
            self.score = score
            self.questionIndex = questionIndex
            self.selectedOption = selectedOption
        }
    }
    
    enum Action {
        case selectOption(Int)
        case addScore(QuestionType, Int)
        case nextQuestion
        case homeButtonTapped
        case goBack
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
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
                if state.questionIndex < 7 {
                    state.questionIndex += 1
                    state.selectedOption = nil
                }
                return .none
                
            case .homeButtonTapped:
                return .none
                
            case .goBack:
                if state.questionIndex > 0 {
                    state.questionIndex -= 1
                    state.selectedOption = nil
                }
                return .none
            }
        }
    }
}

