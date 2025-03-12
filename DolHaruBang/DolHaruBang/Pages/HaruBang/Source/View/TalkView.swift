import SwiftUI
import ComposableArchitecture

struct TalkView: View {
    
    @State var store: StoreOf<TalkFeature>

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
                                            onEdit: nil,
                                            onDelete: nil,
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
                                    
                                    if let image = talk.imageUrl, !image.isEmpty {
                                        SpeechBubbleView(
                                            content: image,
                                            createdAt: talk.createdAt,
                                            isResponse: false,
                                            onEdit: nil,
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
                    .background(Color.clear)
                    .onAppear {
                        store.send(.fetchTalks(1))
                    }
                }
                Spacer(minLength: 80)
            }

            // 메시지 입력 및 전송 UI
            VStack {
                
                // 현재 가장 아래 말풍선의 작성일
                HStack {
                    Spacer()
                    Text(formattedDate(store.floatingDate, true))
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
                .padding(.top, 8)
                
                Spacer()
                
                // 이모티콘 목록 뷰
                if store.showEmojiGrid {
                     EmojiGridView(store: store)
                        .transition(.move(edge: .leading))
                        .animation(.easeInOut(duration: 0.3))
                 }
                
                // 이모티콘 및 사진 추가 그리드 띄우기 버튼과 내용 입력 및 보내기 버튼
                HStack(alignment: .bottom, spacing: 0) {
                    // 파일 추가 버튼
                    Button(action: {
                        store.send(.toggleEmojiGrid)
                    }) {
                        VStack (spacing: 10) {
                            // 선택된 이모티콘가 있을 때만 해당 이모지 없애기 위한 x 버튼
                            if let selectedEmoji = store.selectedEmoji, !store.showEmojiGrid {
                                Button(action: {
                                    store.send(.selectEmoji(nil))
                                }) {
                                    ZStack {
                                        Circle()
                                            .fill(Color(hex: "EFECE1"))
                                            .frame(width: UIScreen.main.bounds.width * 40 / 393, height: UIScreen.main.bounds.width * 40 / 393)
                                            .shadow(color: Color(hex: "CEC6CE"), radius: 5, x: 0, y: 1)
                                        
                                        
                                        Image(systemName: "xmark")
                                            .font(.system(size: 22, weight: .bold))
                                            .foregroundColor(.coreLightGray)
                                    }
                                }
                            }
                            
                            // + / x / 선택한 이모티콘 버튼
                            ZStack {
                                Circle()
                                    .fill(Color.coreWhite)
                                    .frame(width: UIScreen.main.bounds.width * 40 / 393, height: UIScreen.main.bounds.width * 40 / 393)
                                    .shadow(color: Color(hex: "CEC6CE"), radius: 5, x: 0, y: 1)
                                
                                if let emoji = store.selectedEmoji {
                                    Image("\(emoji)") // 선택된 이모지 표시
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 28, height: 28)
                                } else {
                                    Image(systemName: store.showEmojiGrid ? "xmark" : "plus")
                                        .font(.system(size: 22, weight: .bold))
                                        .foregroundColor(.coreLightGray)
                                }
                            }
                            
                        }
                    }

                    // 입력 텍스트 필드
                    VStack{
                        HStack {
                            Spacer()
                            Text("\(store.messageInput.count) / 500")
                                .font(.customFont(Font.body4Regular))
                                .foregroundColor(.coreWhite)
                                .shadow(color: Color(hex:"CECECE"), radius: 4, x: 0, y: 0)
                        }

                        VStack{
                            if let selectImage = store.selectedImage {
                                HStack{
                                    ZStack {
                                        Image(uiImage: selectImage)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 64, height: 64)
                                            .cornerRadius(15) // 코너 반경 15 적용
                                            .padding(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 0))
                                        Button(
                                            action: {
                                                store.send(.imagePicked(nil))
                                            }
                                        ) {
                                            ZStack {
                                                Circle()
                                                    .fill(Color.coreLightGray)
                                                    .frame(width: 16, height: 16)
                                                    .shadow(color: Color(hex:"B4B8BF"), radius: 5, x: 0, y: 1)
                                                    .blendMode(.multiply)
                                                
                                                
                                                Image(systemName: "xmark")
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.coreWhite)
                                            }
                                        }
                                        .offset(x: 28, y: -14)
                                    }
                                    Spacer()
                                }
                            }
                            // 여기
                            ResizableTextView(text: $store.messageInput, maxTextWidth: UIScreen.main.bounds.width * 248/393)
                                .font(Font.customFont(Font.body3Regular))
                                .transparentScrolling()
                                .background(.coreWhite)
                                .foregroundColor(.coreBlack)

                        }
                        .background(Color.coreWhite)
                        .cornerRadius(25)
                        .onTapGesture {
                            if (store.showEmojiGrid) {
                                store.send(.toggleEmojiGrid) // 배경 클릭 시 닫히게 하기 위함
                            }
                        }
                        .shadow(color: Color(hex:"B4B8BF"), radius: 5, x: 0, y: 1)
                    }
                    .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))

                    // 메시지 전송 버튼
                    Button(action: {
                        let imageBase64 = store.selectedImage?.jpegData(compressionQuality: 0.8)?.base64EncodedString() // Base64로 변환
                        var newTalk = Talk(
                            diaryId: 1, // 서버에서 생성
                            contents: store.messageInput,
                            emoji: store.selectedEmoji,
                            imageUrl: imageBase64, // Base64 문자열로 설정
                            reply: "",
                            createdAt: Date(),
                            modifiedAt: nil
                        )
                        store.send(.registTalk(newTalk))
                    }) {
                        Image("sendIcon")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width * 40 / 393, height: UIScreen.main.bounds.width * 40 / 393)
                    }
                }
                .padding(.horizontal, 20)
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
        // 고른 이미지 미리보기 sheet 뷰
        .sheet(isPresented: $store.showImagePreview) {
            ImagePreviewSheet(store: store)
        }
        // 사진첩에서 이미지 고르는 sheet 뷰
        .sheet(isPresented: $store.showImagePicker) {
            ImagePicker(sourceType: .photoLibrary) { image in
                store.send(.imagePicked(image))
            }
        }
    }
}

struct EmojiGridView: View {
    @State var store: StoreOf<TalkFeature>
    
    var body: some View {
        HStack() {
            Rectangle()
                .fill(Color.coreWhite)
                .frame(width: 256, height: 48)
                .cornerRadius(30)
                .padding(.horizontal, 20)
                .overlay(
                    HStack(spacing: 4) {
                        emojiButton("heartEyedEmoji")
                        emojiButton("smileEmoji")
                        emojiButton("sosoEmoji")
                        emojiButton("sadEmoji")
                        emojiButton("angryEmoji")
                        Button(action: {
                            store.send(.toggleImagePicker)
                        }) {
                            Image("postImageEmoji")
                                .resizable()
                                .frame(width: 32, height: 32)
                        }
                    }
                    .padding(8)
                )
            Spacer()
        }
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }
    
    private func emojiButton(_ emojiName: String) -> some View {
        Button(action: {
            store.send(.selectEmoji(emojiName))
        }) {
            ZStack {
                Image(emojiName)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 32, height: 32)
            }
        }
    }
}

struct ImagePreviewSheet: View {
    @State var store: StoreOf<TalkFeature>
    
    var body: some View {
        ZStack {
            Color.black.edgesIgnoringSafeArea(.all)
            
            VStack {
                Spacer()
                // 고른 사진
                if let selectedImage = store.selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
                }
                
                Spacer()
                
                HStack(spacing: 20) {
                    // 닫기 버튼
                    Button(action: {
                        store.send(.toggleImagePreview)
                    }) {
                        Text("닫기")
                            .font(.headline)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(8)
                    }

                    // 삭제 버튼
                    Button(action: {
                        store.send(.imagePicked(nil))
                        store.send(.toggleImagePreview)
                    }) {
                        Text("삭제")
                            .font(.headline)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }

                    // 바꾸기 버튼
                    Button(action: {
                        store.send(.toggleImagePreview)
                        store.send(.toggleImagePicker)
                    }) {
                        Text("바꾸기")
                            .font(.headline)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                }
                .padding(.bottom, 20)
            }
        }
    }
}
