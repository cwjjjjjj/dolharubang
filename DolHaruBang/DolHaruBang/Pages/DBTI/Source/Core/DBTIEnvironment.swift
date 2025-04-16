// 캐릭터 종류
enum DBTIModel: String {
    case 새침이 = "새침이"
    case 시크 = "시크"
    case 소심이 = "소심이"
    case 발랄이 = "발랄이"
    case 큐피드 = "큐피드"
    case 뿜뿜이 = "뿜뿜이"
    case 나른이 = "나른이"
    case 멍이 = "멍이"
    case 반짝이 = "반짝이"
}

// 돌BTI 점수에 따른 캐릭터 배정
extension DBTIScore {
    var character: DBTIModel {
        switch (realityScore, thinkingScore) {
            // [소심이] 현실 + 적은 생각
            case (0...1, 0...1): return .소심이
            
            // [시크] 현실 + 적당한 생각
            case (0...1, 2): return .시크
            
            // [나른이] 현실 + 많은 생각
            case (0...1, 3...4): return .나른이
            
            // [발랄이] 중도 + 적은 생각
            case (2, 0...1): return .발랄이
            
            // [큐피드] 중도 + 적당한 생각
            case (2, 2): return .큐피드
            
            // [뿜뿜이] 중도 + 많은 생각
            case (2, 3...4): return .뿜뿜이
            
            // [새침이] 이상 + 적은 생각
            case (3...4, 0...1): return .새침이
            
            // [멍이] 이상 + 적당한 생각
            case (3...4, 2): return .멍이
            
            // [반짝이] 이상 + 많은 생각
            case (3...4, 3...4): return .반짝이
            
            // [소심이] 기본값
            default: return .소심이
        }
    }
}


// 질문 주제
enum QuestionType {
    case reality
    case thinking
}

// 질문과 선택지
struct Question {
    let text: String
    let about: QuestionType
    let options: [(text: String, score: Int?)]
}

// 점수
struct DBTIScore : Equatable {
    var realityScore: Int = 0
    var thinkingScore: Int = 0
}

// 질문과 선택지 모음
let questions: [Question] = [
    Question(
        text: "함께 자고 일어난 친구가\n기니피그로 변해버렸다.\n당신의 반응은?",
        about: .reality,
        options: [
            (text: "밥과 간식을 갖다주고\n심심하지 않게 TV도 켜준다.", score: 1),
            (text: "안타깝지만 신고하고 연구소에 알린다.", score: nil)
        ]
    ),
    Question(
        text: "어느 날 길에서 주운 낡은 시계를 자세히 살펴보니,\n날짜와 시간을 마음대로 조종할 수 있는 것처럼 보인다.\n어떻게 할까?",
        about: .reality,
        options: [
            (text: "소설에서만 보던 게 실제로 있다니!\n2시간 전으로 돌아가볼까?", score: 1),
            (text: "장난감이겠지. 주인이나 찾아줘야지.", score: nil)
        ]
    ),
    Question(
        text: "당신의 최애 영화 속으로 들어갈 수 있는 기회가 주어졌다!\n그런데 그 세계는 위험한 모험으로 가득하다는 걸 안다.\n당신의 선택은?",
        about: .reality,
        options: [
            (text: "모험이라니, 너무 흥미진진해!\n당장 들어가서 주인공처럼 살아봐야지!", score: 1),
            (text: "아무리 좋아도 위험한 건 싫어…\n그냥 안전하게 영화로 볼래~!", score: nil)
        ]
    ),
    Question(
        text: "벌어둔 돈이 갑자기 다 떨어졌고,\n수중에는 만원이 남았다.\n무엇을 할까?",
        about: .reality,
        options: [
            (text: "복권방에 가서 복권을 구매한다.", score: 1),
            (text: "자격증 책을 사서 취업을 준비한다.", score: nil)
        ]
    ),
    Question(
        text: "간만에 좋아하는 고향 친구한테 전화를 했다.\n얼른 목소리 듣고 싶은데 왜 전화를 안 받지?\n당신의 생각은?",
        about: .thinking,
        options: [
            (text: "바쁠 시간이긴 하지. 나중에 다시 걸자.", score: nil),
            (text: "내가 저번에 말실수를 했나?\n아님 전화기가 고장난 걸까?", score: 1)
        ]
    ),
    Question(
        text: "기분 좋은 일요일 아침이다.\n오늘 먹을 점심 메뉴를 생각해볼까?",
        about: .thinking,
        options: [
            (text: "이따가 배가 고플 때 생각하고, 잠부터 자자!", score: nil),
            (text: "전부터 정해둔 맛집을 가기 위해\n벌떡 일어나 준비한다.", score: 1)
        ]
    ),
    Question(
        text: "사야 할 물품 리스트를 머릿속에 정리하고 마트에 갔다.\n들어가자마자 파격적인 할인과\n한정 판매로 가득한 전경이 눈에 가득 찬다.\n당신의 반응은?",
        about: .thinking,
        options: [
            (text: "에이, 사려고 했던 거 먼저 사자.", score: nil),
            (text: "이것도 필요하고, 저것도 필요한데...\n이참에 살까?", score: 1)
        ]
    ),
    Question(
        text: "친구가 깜짝 생일 파티를 열어주겠다고 했는데,\n그 전날까지 몇 시에 볼 지 말해 주지 않았다.\n당신의 생각은?",
        about: .thinking,
        options: [
            (text: "파티는 어차피 저녁에 할 테니\n오후까진 그냥 쉬자", score: nil),
            (text: "드레스코드라도 물어볼까?\n친구가 무슨 이벤트를 계획했을까?", score: 1)
        ]
    )
]

