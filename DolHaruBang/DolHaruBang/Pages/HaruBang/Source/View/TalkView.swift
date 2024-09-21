import SwiftUI
import ComposableArchitecture

struct TalkView: View {
    @State var store: StoreOf<TalkFeature> // Store로 상태 및 액션 전달

    var body: some View {
        ZStack {
            VStack {
                ScrollViewReader { scrollViewProxy in
                    ScrollView {
                        VStack(spacing: 10) {
                            if let talks = store.state.talks { // 대화 목록을 가져와서 반복
                                ForEach(Array(talks.enumerated()), id: \.offset) { index, talk in
                                    // emoji, contents, image 각각의 SpeechBubbleView로 표시
                                    if let emoji = talk.emoji, !emoji.isEmpty {
                                        SpeechBubbleView(
                                            content: emoji,
                                            createdAt: talk.createdAt,
                                            isResponse: false,
                                            onEdit: {
                                                // 수정 액션 처리
                                            },
                                            onDelete: {
                                                // 삭제 액션 처리
                                            },
                                            isEmoji: true
                                        )
                                    }
                                    
                                    if !talk.contents.isEmpty {
                                        SpeechBubbleView(
                                            content: talk.contents,
                                            createdAt: talk.createdAt,
                                            isResponse: false,
                                            onEdit: {
                                                // 수정 액션 처리
                                            },
                                            onDelete: {
                                                // 삭제 액션 처리
                                            },
                                            isEmoji: false
                                        )
                                    }
                                    
                                    if let image = talk.image, !image.isEmpty {
                                        SpeechBubbleView(
                                            content: image,
                                            createdAt: talk.createdAt,
                                            isResponse: false,
                                            onEdit: {
                                                // 수정 액션 처리
                                            },
                                            onDelete: {
                                                // 삭제 액션 처리
                                            },
                                            isEmoji: false
                                        )
                                    }
                                    
                                    // reply를 별도의 SpeechBubble로 좌측 정렬
                                    if !talk.reply.isEmpty {
                                        SpeechBubbleView(
                                            content: talk.reply,
                                            createdAt: talk.createdAt,
                                            isResponse: true,
                                            isEmoji: false
                                        )
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 16)
                    }
                    .padding(.horizontal, 16)
                    .background(Color.clear)
                    .onAppear {
                        store.send(.fetchTalks)
                    }
                }
                Spacer(minLength: 80)
            }

            // 메시지 입력 및 전송 UI
            VStack {
                // 현재 가장 아래 말풍선의 작성일
                HStack {
                    Spacer()
                    Text(formattedDate(store.floatingDate))
                        .font(.customFont(Font.body3Bold))
                        .foregroundColor(.coreDisabled)
                        .frame(width: 146, height: 29)
                        .background(RoundedRectangle(cornerRadius: 25).fill(Color.coreWhite))
                        .overlay(
                            RoundedRectangle(cornerRadius: 25)
                                .stroke(Color.white.opacity(0.7), lineWidth: 0.25)
                        )
                        .shadow(
                            color: Color(hex: "#B5B5B5"), radius: 5, y: 1
                        )
                    Spacer()
                }
                .padding(.top, 10)
                
                Spacer()
                
                if store.showEmojiGrid {
                    HStack () {
                        Rectangle()
                            .fill(Color.coreWhite)
                            .frame(width: 256, height: 48)
                            .cornerRadius(30)
                            .padding(.horizontal, 20)
                            .overlay(
                                HStack {
                                    Button (action: {
                                        if (store.selectedEmoji == "heartEyedEmoji") {
                                            print("heartEyedEmoji 다시 눌림!")
                                            store.send(.selectEmoji(nil))
                                        }
                                        else {
                                            print("heartEyedEmoji 눌림!")
                                            store.send(.selectEmoji("heartEyedEmoji"))
                                        }
                                    }) {
                                        ZStack {
                                            Image("heartEyedEmoji")
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                            if (store.selectedEmoji == "heartEyedEmoji") {
                                                Circle()
                                                .fill(Color.black.opacity(0.3))
                                                .frame(width: 32, height: 32) // 원의 크기
                                            }
                                        }
                                    }
                                    Button (action: {
                                        if (store.selectedEmoji == "smileEmoji") {
                                            print("smileEmoji 다시 눌림!")
                                            store.send(.selectEmoji(nil))
                                        }
                                        else {
                                            print("smileEmoji 눌림!")
                                            store.send(.selectEmoji("smileEmoji"))
                                        }
                                    }) {
                                        ZStack {
                                            Image("smileEmoji")
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                            if (store.selectedEmoji == "smileEmoji") {
                                                Circle()
                                                .fill(Color.black.opacity(0.3))
                                                .frame(width: 32, height: 32) // 원의 크기
                                            }
                                        }
                                    }
                                    Button (action: {
                                        if (store.selectedEmoji == "sosoEmoji") {
                                            print("sosoEmoji 다시 눌림!")
                                            store.send(.selectEmoji(nil))
                                        }
                                        else {
                                            print("sosoEmoji 눌림!")
                                            store.send(.selectEmoji("sosoEmoji"))
                                        }
                                    }) {
                                        ZStack {
                                            Image("sosoEmoji")
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                            if (store.selectedEmoji == "sosoEmoji") {
                                                Circle()
                                                .fill(Color.black.opacity(0.3))
                                                .frame(width: 32, height: 32) // 원의 크기
                                            }
                                        }
                                    }
                                    Button (action: {
                                        if (store.selectedEmoji == "sadEmoji") {
                                            print("sadEmoji 다시 눌림!")
                                            store.send(.selectEmoji(nil))
                                        }
                                        else {
                                            print("sadEmoji 눌림!")
                                            store.send(.selectEmoji("sadEmoji"))
                                        }
                                    }) {
                                        ZStack {
                                            Image("sadEmoji")
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                            if (store.selectedEmoji == "sadEmoji") {
                                                Circle()
                                                .fill(Color.black.opacity(0.3))
                                                .frame(width: 32, height: 32) // 원의 크기
                                            }
                                        }
                                    }
                                    Button (action: {
                                        if (store.selectedEmoji == "angryEmoji") {
                                            print("angryEmoji 다시 눌림!")
                                            store.send(.selectEmoji(nil))
                                        }
                                        else {
                                            print("angryEmoji 눌림!")
                                            store.send(.selectEmoji("angryEmoji"))
                                        }
                                    }) {
                                        ZStack {
                                            Image("angryEmoji")
                                                .resizable()
                                                .frame(width: 32, height: 32)
                                            if (store.selectedEmoji == "angryEmoji") {
                                                Circle()
                                                .fill(Color.black.opacity(0.3))
                                                .frame(width: 32, height: 32) // 원의 크기
                                            }
                                        }
                                    }
                                    Button (action: {
                                        print("postImageEmoji 눌림!")
                                        store.send(.selectEmoji(nil))
                                    }) {
                                        Image("postImageEmoji")
                                            .resizable()
                                            .frame(width: 32, height: 32)
                                    }
                                }
                                .padding(8)
                            )
                            .shadow(color: Color(hex: "B4B8BF"), radius: 5, x: 0, y: 1)
                        Spacer()
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    
                    Spacer().frame(height: 8)
                }
                
                // 이모지 및 사진 추가 그리드 띄우기 버튼과 내용 입력 및 보내기 버튼
                HStack {
                    // 파일 추가 버튼
                    Button(action: {
                        store.send(.toggleEmojiGrid)
                    }) {
                        ZStack {
                            Circle()
                                .fill(Color.coreWhite)
                                .frame(width: 48, height: 48)
                                .shadow(color: Color(hex: "CEC6CE"), radius: 5, x: 0, y: 1)
                            
                            if let emoji = store.selectedEmoji {
                                Image("\(emoji)") // 선택된 이모지 표시
                                    .resizable()
                                    .frame(width: 32, height: 32)
//                                    .overlay(
//                                        Button(action: {
//                                            print("XXXXXXXX")
//                                            store.send(.selectEmoji(nil))
//                                        }) {
//                                            ZStack {
//                                                Circle()
//                                                    .fill(Color.red)
//                                                    .frame(width: 24, height: 24)
//                                                    .shadow(color: Color(hex: "CEC6CE"), radius: 5, x: 0, y: 1)
//                                                Image(systemName: "xmark")
//                                                    .font(.system(size: 16, weight: .bold))
//                                                    .foregroundColor(.coreWhite)
//                                            }
//                                            .offset(x: 24, y: -24)
//                                        }
//                                        .buttonStyle(PlainButtonStyle())
//                                    )
                            } else {
                                Image(systemName: store.showEmojiGrid ? "xmark" : "plus")
                                    .font(.system(size: 25, weight: .bold))
                                    .foregroundColor(.coreLightGray)
                            }
                        }
                    }
                    .background(GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                // 버튼의 위치를 저장
                                let buttonPosition = geometry.frame(in: .global).minY
                                // 버튼의 위치를 사용하여 그리드의 위치 조정
                            }
                    })
            

                    // 입력 텍스트 필드
                    ZStack(alignment: .topTrailing) {
                        CustomTextField(
                            text: $store.messageInput,
                            placeholder: "돌에게 오늘의 이야기를 들려주세요",
                            placeholderColor: Color(hex:"C8BEB2").toUIColor(),
                            backgroundColor: .coreWhite,
                            maxLength: 500,
                            useDidEndEditing: false,
                            customFontStyle: Font.body3Bold,
                            alignment: Align.leading,
                            leftPadding : 5
                        )
                        .frame(width: UIScreen.main.bounds.width * 250/393, height: 40)
                        .cornerRadius(25)
                        .onTapGesture {
                            if (store.showEmojiGrid) {
                                store.send(.toggleEmojiGrid) // 배경 클릭 시 닫히게 하기 위함
                            }
                        }
                        .shadow(color: Color(hex:"B4B8BF"), radius: 5, x: 0, y: 1)

                        Text("\(store.messageInput.count) / 500")
                            .font(.customFont(Font.body4Regular))
                            .foregroundColor(.coreWhite)
                            .shadow(color: Color(hex:"CECECE"), radius: 4, x: 0, y: 0)
                            .padding(.top, -16)
                    }

                    // 메시지 전송 버튼
                    Button(action: {
                        let newTalk = Talk(
                            diaryId: 0,
                            contents: store.messageInput,
                            emoji: "😊",
                            image: "mockImage.png",
                            reply: "",
                            createdAt: Date(),
                            modifiedAt: nil
                        )
                        store.send(.registTalk(newTalk))
                    }) {
                        Image("sendIcon")
                            .resizable()
                            .frame(width: 40, height: 40)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
        }
        .background(Color.clear)
        .onTapGesture {
            if (store.showEmojiGrid) {
                store.send(.toggleEmojiGrid) // 배경 클릭 시 닫히게 하기 위함
            }
            else {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
    }

    // 날짜 형식 지정 함수
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일 EEEE"
        formatter.locale = Locale(identifier: "ko_KR") // 한국어 로케일 설정
        return formatter.string(from: date)
    }
    
    // 오전/오후 형식의 시간 표시 함수
    private func formattedFloatingDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a hh시 mm분" // "a"는 오전/오후를 나타냅니다.
        return formatter.string(from: date)
    }
}
