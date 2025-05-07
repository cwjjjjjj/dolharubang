import Foundation
import UIKit
import ComposableArchitecture
import Alamofire

// 캐릭터 종류
enum DBTIModel: String, Codable, CaseIterable {
    var description: String {
        return self.rawValue
    }
    
    case sparkle = "반짝이"
    case sosim = "소심이"
    case saechim = "새침이"
    case nareun = "나른이"
    case meong = "멍이"
    case cupid = "큐피드"
    case bboombboom = "뿜뿜이"
    case balral = "발랄이"
    case chic = "시크"
}

// 초기능력 타입 (AbilityType)
public enum AbilityType: String, Codable {
    case WISESAYING       // 오늘의 명언
    case WEATHERCASTER    // 기상캐스터
    case ROCKSTAR         // Rock스타
    case FORTUNETELLING   // 탄생석 운세
    case ADVISOR          // 고민해결사
    case FOODEXPERT       // 쩝쩝박사
}

extension DBTIModel {
    
    /// 성격 (한글)
    var personality: String {
        switch self {
        case .saechim:     return "까다로움"
        case .chic:        return "시크함"
        case .sosim:       return "소심함"
        case .balral:      return "명랑함"
        case .cupid:       return "애정넘침"
        case .bboombboom:  return "에너지넘침"
        case .nareun:      return "나른함"
        case .meong:       return "멍함"
        case .sparkle:     return "낭만파"
        }
    }
    
    /// 성격 (영문)
    var personalityEng: String {
        switch self {
        case .saechim:     return "picky"
        case .chic:        return "chic"
        case .sosim:       return "timid"
        case .balral:      return "cheerful"
        case .cupid:       return "affectionate"
        case .bboombboom:  return "energetic"
        case .nareun:      return "sleepy"
        case .meong:       return "blank"
        case .sparkle:     return "romantic"
        }
    }
    
    /// 초기능력 (AbilityType)
    var baseAbilityType: AbilityType {
        switch self {
        case .saechim:     return .ROCKSTAR
        case .chic:        return .ADVISOR
        case .sosim:       return .WEATHERCASTER
        case .balral:      return .ROCKSTAR
        case .cupid:       return .ADVISOR
        case .bboombboom:  return .WISESAYING
        case .nareun:      return .FOODEXPERT
        case .meong:       return .FORTUNETELLING
        case .sparkle:     return .FOODEXPERT
        }
    }
    
    /// 초기능력 (한글)
    var baseAbilityTypeKorean: String {
        switch self {
        case .saechim:     return "Rock스타"
        case .chic:        return "고민해결사"
        case .sosim:       return "기상캐스터"
        case .balral:      return "Rock스타"
        case .cupid:       return "고민해결사"
        case .bboombboom:  return "오늘의명언"
        case .nareun:      return "쩝쩝박사"
        case .meong:       return "탄생석운세"
        case .sparkle:     return "쩝쩝박사"
        }
    }
    
    
    var toFaceShape: FaceShape? {
        switch self {
        case .sparkle:     return .sparkle
        case .sosim:       return .sosim
        case .saechim:     return .saechim
        case .nareun:      return .nareun
        case .meong:       return .meong
        case .cupid:       return .cupid
        case .bboombboom:  return .bboombboom
        case .balral:      return .balral
        case .chic:        return .chic
        }
    }
    
}




// 돌BTI 점수에 따른 캐릭터 배정
extension DBTIScore {
    var character: DBTIModel {
        switch (realityScore, thinkingScore) {
            // [sosim] 현실 + 적은 생각
            case (0...1, 0...1): return .sosim
            
            // [chic] 현실 + 적당한 생각
            case (0...1, 2): return .chic
            
            // [nareun] 현실 + 많은 생각
            case (0...1, 3...4): return .nareun
            
            // [ballal] 중도 + 적은 생각
            case (2, 0...1): return .balral
            
            // [cupid] 중도 + 적당한 생각
            case (2, 2): return .cupid
            
            // [bboombboom] 중도 + 많은 생각
            case (2, 3...4): return .bboombboom
            
            // [saechim] 이상 + 적은 생각
            case (3...4, 0...1): return .saechim
            
            // [meong] 이상 + 적당한 생각
            case (3...4, 2): return .meong
            
            // [banzzag] 이상 + 많은 생각
            case (3...4, 3...4): return .sparkle
            
            // [sosim] 기본값
            default: return .sosim
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
        text: "사계절의상실\n\n어떻게 읽히시나요?",
        about: .reality,
        options: [
            (text: "사계절의 상실 🌱☀️🍂❄️", score: nil),
            (text: "사계절 의상실 👗👔👚", score: nil)
        ]
    ),
    Question(
        text: "함께 자고 일어난 친구가\n기니피그로 변해버렸다.\n당신의 반응은?",
        about: .reality,
        options: [
            (text: "밥과 간식을 갖다주고\n심심하지 않게 TV도 켜준다.", score: 1),
            (text: "안타깝지만 신고하고 연구소에 알린다.", score: nil)
        ]
    ),
    Question(
//        text: "어느 날 길에서 주운 낡은 시계를 자세히 살펴보니,\n날짜와 시간을 마음대로 조종할 수 있는 것처럼 보인다.\n어떻게 할까?",
        text: "어느 날 길에서 낡은 시계를 주웠다.\n그런데 자세히 살펴보니,\n날짜와 시간을 마음대로 조종할 수 있을 것 같다.\n어떻게 할까?",
        about: .reality,
        options: [
            (text: "소설에서만 보던 게 실제로 있다니!\n일단 2시간 전으로 돌아가볼까?", score: 1),
            (text: "장난감이겠지. 주인이나 찾아주자.", score: nil)
        ]
    ),
    Question(
        text: "당신의 최애 영화 속 세계로 \n들어갈 수 있는 기회가 주어졌다!\n그런데 그 세계는 위험한 모험으로 가득하다.\n당신의 선택은?",
        about: .reality,
        options: [
            (text: "모험이라니, 너무 흥미진진해!\n당장 들어가서 주인공처럼 살아봐야지!", score: 1),
            (text: "아무리 좋아도 위험한 건 싫어…\n영화는 안전하게 영화로 볼래~!", score: nil)
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

struct tmpRequestBody: Codable, Equatable, Sendable {
    let speciesName: String
    let stoneName: String
    let spaceName: String
}

struct MemberInfoRequest: Codable, Equatable, Sendable {
    let nickname: String
    let birthday: String
}

@DependencyClient
struct DBTIClient {
    var checkUsername: @Sendable (_ username: String) async throws -> Bool
    var postMemberInfo: @Sendable (_ nickname: String, _ birthday: String) async throws -> Void
    var adoptStone: @Sendable (_ speciesName: String, _ stoneName: String, _ spaceName: String) async throws -> Void
}

extension DBTIClient: DependencyKey {
    static let liveValue = DBTIClient (
        checkUsername: { username in
            let url = APIConstants.Endpoints.check + "/\(username)"
            return try await fetch(url: url, model: Bool.self, method: .get)
        }
        ,
        postMemberInfo: { nickname, birthday in
            let url = APIConstants.Endpoints.memberInfo
            let requestBody = MemberInfoRequest(nickname: nickname, birthday: birthday)
            let bodyData = try JSONEncoder().encode(requestBody)
            
            try await fetch(
                url: url,
                model: EmptyResponse.self,
                method: .post,
                body: bodyData
            )
        },
        
        adoptStone: { speciesName, stoneName, spaceName in
            let url = APIConstants.Endpoints.adopt
            let requestBody = tmpRequestBody(speciesName: speciesName, stoneName: stoneName, spaceName: spaceName)
            let bodyData = try JSONEncoder().encode(requestBody)
               
            try await fetch(
                url: url,
                model: Bool.self,
                method: .post,
                body: bodyData
           )
        }
    )
}

// DependencyValues
extension DependencyValues {
    var dbtiClient: DBTIClient {
        get { self[DBTIClient.self] }
        set { self[DBTIClient.self] = newValue }
    }
}
