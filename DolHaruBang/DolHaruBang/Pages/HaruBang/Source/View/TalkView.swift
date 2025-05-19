import SwiftUI
import ComposableArchitecture

struct TalkView: View {
    @State var store: StoreOf<TalkFeature>

    var body: some View {
        ZStack {
            // 메시지 목록 부분
            MessagesListSection(store: store)
            
            // 입력 및 컨트롤 부분
            MessageControlSection(store: store)
        }
        .background(Color.clear)
        .onTapGesture {
            if (store.showEmojiGrid) {
                store.send(.toggleEmojiGrid)
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

struct MessagesListSection: View {
    @State var store: StoreOf<TalkFeature>
    @State private var showDate: Bool = false
    @State private var fadeOutTask: Task<Void, Never>? = nil
    @State private var lastOffset: CGFloat = 0

    var body: some View {
        ZStack(alignment: .top) {
            ScrollViewReader { scrollViewProxy in
                ScrollView {
                    VStack(spacing: 0) {
                        // 1. 실제 메시지 콘텐츠
                        TalkMessagesContent(store: store)
                            .padding(.vertical, 16)

                        // offset 판단용
                        GeometryReader { geo in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self,
                                            value: geo.frame(in: .named("scroll")).minY)
                        }
                        .frame(height: 1)
                    }
                }
                .coordinateSpace(name: "scroll")
                .onAppear {
                    store.send(.fetchTalks)
                    showDateDebounced()
                }
                .onPreferenceChange(ScrollOffsetPreferenceKey.self) { newOffset in
                    if abs(newOffset - lastOffset) > 2 {
                        lastOffset = newOffset
                        showDateDebounced()
                    }
                }
            }
            Spacer(minLength: 80)

            if showDate {
                DateDisplayView(store: store)
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.5), value: showDate)
            }
        }
    }

    private func showDateDebounced() {
        guard !showDate else { return }
        withAnimation { showDate = true }
        fadeOutTask?.cancel()
        fadeOutTask = Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await MainActor.run {
                withAnimation { showDate = false }
            }
        }
    }
}

private struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}




// 대화 메시지 내용
struct TalkMessagesContent: View {
    @State var store: StoreOf<TalkFeature>
    
    var body: some View {
        VStack(spacing: 10) {
            if let talks = store.state.talks {
                ForEach(Array(talks.enumerated()), id: \.offset) { index, talk in
                    TalkBubbleGroup(talk: talk, store: store)
                }
            }
        }
    }
}

// 개별 대화 그룹
struct TalkBubbleGroup: View {
    let talk: Talk
    @State var store: StoreOf<TalkFeature>
    
    var body: some View {
        VStack(spacing: 10) {
            // 이모지 메시지
            if let emoji = talk.emoji, !emoji.isEmpty {
                SpeechBubbleView(
                    content: emoji,
                    createdAt: talk.createdAt,
                    isResponse: false,
                    onEdit: nil,
                    onDelete: {
                        store.send(.toggleDeleteAlert(.EMOJI))
                    },
                    isEmoji: true
                )
            }
            
            // 텍스트 메시지
            if let contents = talk.contents, !contents.isEmpty {
                SpeechBubbleView(
                    content: contents,
                    createdAt: talk.createdAt,
                    isResponse: false,
                    onDelete: {
                        store.send(.toggleDeleteAlert(.CONTENT))
                    },
                    isEmoji: false
                )
            }
            
            // 사진
            if let image = talk.imageUrl, !image.isEmpty {
                SpeechBubbleView(
                    content: image,
                    createdAt: talk.createdAt,
                    isResponse: false,
                    onEdit: nil,
                    onDelete: {
                        store.send(.toggleDeleteAlert(.IMAGE))
                    },
                    isEmoji: false
                )
            }
            
            // 답장
            if !(talk.reply ?? "").isEmpty {
                SpeechBubbleView(
                    content: talk.reply ?? "",
                    createdAt: talk.createdAt,
                    isResponse: true,
                    onDelete: {
                        store.send(.toggleDeleteAlert(.REPLY))
                    },
                    isEmoji: false
                )
            }
        }
        .alert("삭제 확인", isPresented: $store.showDeleteAlert) {
            Button("취소", role: .cancel) {
                store.send(.toggleDeleteAlert(nil))
            }
            Button("삭제", role: .destructive) {
                if let target = store.deleteTarget {
                    let diaryId = talk.diaryId
                    store.send(.deletePart(diaryId, target))
                }
            }
        } message: {
            if let target = store.deleteTarget {
                Text("정말로 이 \(target.displayName)을(를) 삭제하시겠습니까?")
            }
        }

    }
}

// 메시지 입력 및 컨트롤 부분
struct MessageControlSection: View {
    @State var store: StoreOf<TalkFeature>
    
    var body: some View {
        VStack {
            Spacer()
            
            // 이모티콘 목록 뷰
            if store.showEmojiGrid {
                EmojiGridView(store: store)
                    .transition(.move(edge: .leading))
                    .animation(.easeInOut(duration: 0.3), value: store.showEmojiGrid)
            }
            
            // 입력 컨트롤
            MessageInputControls(store: store)
        }
    }
}

// 날짜 표시 뷰
struct DateDisplayView: View {
    @State var store: StoreOf<TalkFeature>
    
    var body: some View {
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
    }
}

// 메시지 입력 컨트롤
struct MessageInputControls: View {
    @State var store: StoreOf<TalkFeature>
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 0) {
            // 이모지 버튼 영역
            EmojiButtonArea(store: store)
            
            // 텍스트 입력 영역
            TextInputArea(store: store)
            
            // 전송 버튼
            SendButton(store: store)
        }
        .padding(.horizontal, 20)
    }
}

// 이모지 버튼 영역
struct EmojiButtonArea: View {
    @State var store: StoreOf<TalkFeature>
    
    var body: some View {
        Button(action: {
            store.send(.toggleEmojiGrid)
        }) {
            VStack(spacing: 10) {
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
                        Image("\(emoji)")
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
    }
}

// 텍스트 입력 영역
struct TextInputArea: View {
    @State var store: StoreOf<TalkFeature>
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("\(store.messageInput.count) / 500")
                    .font(.customFont(Font.body4Regular))
                    .foregroundColor(.coreWhite)
                    .shadow(color: Color(hex:"CECECE"), radius: 4, x: 0, y: 0)
            }
            
            VStack {
                if let selectImage = store.selectedImage {
                    SelectedImageView(selectImage: selectImage, store: store)
                }
                
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
                    store.send(.toggleEmojiGrid)
                }
            }
            .shadow(color: Color(hex:"B4B8BF"), radius: 5, x: 0, y: 1)
        }
        .padding(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
    }
}

// 선택된 이미지 뷰
struct SelectedImageView: View {
    let selectImage: UIImage
    @State var store: StoreOf<TalkFeature>
    
    var body: some View {
        HStack {
            ZStack {
                Image(uiImage: selectImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 64, height: 64)
                    .cornerRadius(15)
                    .padding(EdgeInsets(top: 12, leading: 16, bottom: 0, trailing: 0))
                
                Button(action: {
                    store.send(.imagePicked(nil))
                }) {
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
}

// 전송 버튼
struct SendButton: View {
    @State var store: StoreOf<TalkFeature>
    
    var body: some View {
        Button(action: {
            let imageBase64 = store.selectedImage?.jpegData(compressionQuality: 0.8)?.base64EncodedString()
            let newTalk = TalkToCreate(
                contents: store.messageInput,
                emoji: store.selectedEmoji,
                imageBase64: imageBase64,
                reply: nil
            )
            store.send(.registTalk(newTalk))
        }) {
            Image("sendIcon")
                .resizable()
                .frame(width: UIScreen.main.bounds.width * 40 / 393, height: UIScreen.main.bounds.width * 40 / 393)
        }
    }
}

// 이모지 그리드
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

// 사진 프리뷰 시트
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


// 화면 스와이프 감지용 뷰
struct SwipeOrTapGestureView: UIViewRepresentable {
    var onGesture: () -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        // Tap
        let tap = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleGesture))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)

        // Swipe (네 방향)
        let directions: [UISwipeGestureRecognizer.Direction] = [.up, .down, /*.left, .right*/]
        for dir in directions {
            let swipe = UISwipeGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleGesture))
            swipe.direction = dir
            swipe.cancelsTouchesInView = false
            view.addGestureRecognizer(swipe)
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onGesture: onGesture)
    }

    class Coordinator: NSObject {
        let onGesture: () -> Void
        init(onGesture: @escaping () -> Void) { self.onGesture = onGesture }

        @objc func handleGesture() {
            onGesture()
        }
    }
}
