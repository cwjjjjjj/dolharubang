import SwiftUI

struct SpeechBubbleView: View {
    var content: String
    var createdAt: Date
    var isResponse: Bool
    var onEdit: (() -> Void)?
    var onDelete: (() -> Void)?
    var isEmoji: Bool
    @State private var showImagePreview = false
    @State private var previewImageURL: URL? = nil
    @State private var previewID = UUID()

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            if !isResponse {
                Spacer()
                    .frame(minWidth: UIScreen.main.bounds.width * (137 / 393))
            } else {
                HStack(alignment: .top, spacing: 1) {
                    Circle()
                        .frame(width: 48, height: 48)
                        .overlay(
                            Image("Logo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 40.25 * 6 / 7, height: 38.27 * 6 / 7)
                        )
                        .padding(EdgeInsets(top: 16, leading: 4, bottom: 0, trailing: 3))
                    Circle()
                        .fill(Color.coreWhite)
                        .frame(width: 6, height: 6)
                        .padding(EdgeInsets(top: 35, leading: 0, bottom: 0, trailing: 0))
                    Circle()
                        .fill(Color.coreWhite)
                        .frame(width: 12, height: 12)
                        .padding(EdgeInsets(top: 24, leading: 0, bottom: 0, trailing: 4))
                }
            }

            VStack(alignment: .leading, spacing: 0) {
                contentDisplay

                if !isResponse {
                    Divider()
                        .foregroundStyle(Color(hex: "E5DFD7"))
                        .padding(.horizontal, 16)
                    dateAndActionButtons
                }
            }
            .background(Color.coreWhite)
            .cornerRadius(15)
            .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 1)
            .frame(
                width: isEmoji ? 64 : nil,
                alignment: isResponse ? .leading : .trailing
            )

            if isResponse {
                Spacer()
            } else {
                Triangle()
                    .fill(Color.coreWhite)
                    .frame(width: 10, height: 16)
                    .rotationEffect(Angle(degrees: 0))
                    .padding(.top, 24)
            }
        }
        .padding(.horizontal, 16)
        .fullScreenCover(isPresented: $showImagePreview) {
            ZStack {
                Color.black.ignoresSafeArea()
                if let url = previewImageURL {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(2)
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .background(Color.black)
                        case .failure:
                            Text("사진을 띄울 수 없습니다")
                                .foregroundColor(.white)
                        @unknown default:
                            EmptyView()
                        }
                    }
                }

                // 우상단 닫기 버튼
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            showImagePreview = false
                            previewImageURL = nil
                            previewID = UUID() // 닫을 때 id 갱신
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .resizable()
                                .frame(width: 32, height: 32)
                                .foregroundColor(.white)
                                .shadow(radius: 4)
                                .padding()
                        }
                    }
                    Spacer()
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                showImagePreview = false
                previewImageURL = nil
                previewID = UUID() // 닫을 때 id 갱신
            }
        }
        .id(previewID)
    }

    // 내용 표시 부분 (이모지, 텍스트, 이미지)
    private var contentDisplay: some View {
        Group {
            if isEmoji, let emojiImage = UIImage(named: content) {
                Image(uiImage: emojiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIDevice.isPad ? 70 : 48, height: UIDevice.isPad ? 70 : 48)
                    .padding(8)
            } else if content.hasPrefix("http"), let url = URL(string: content) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 48, height: 48)
                            .padding(8)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(maxWidth: UIScreen.main.bounds.width * (256 / 393) - 32, maxHeight: 200)
                            .cornerRadius(10)
                            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 14))
                            .onTapGesture {
                                previewImageURL = url
                                previewID = UUID() // 프리뷰 열 때 id 갱신
                                showImagePreview = true
                            }
                    case .failure:
                        Text("\(content) 사진을 띄울 수 없습니다")
                            .font(.customFont(Font.body3Regular))
                            .foregroundColor(.coreBlack)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 14))
                    @unknown default:
                        Text("\(content) 사진을 띄울 수 없습니다")
                            .font(.customFont(Font.body3Regular))
                            .foregroundColor(.coreBlack)
                            .lineLimit(nil)
                            .multilineTextAlignment(.leading)
                            .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 14))
                    }
                }
            } else {
                Text(content)
                    .font(.customFont(Font.body3Regular))
                    .foregroundColor(.coreBlack)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .padding(EdgeInsets(top: 16, leading: 16, bottom: 16, trailing: 14))
            }
        }
    }

    private var dateAndActionButtons: some View {
        HStack {
            if !isEmoji {
                Text(formattedFloatingDate(createdAt))
                    .font(.customFont(Font.body4Regular))
                    .foregroundColor(.coreGreen)
            }

            if !isResponse {
                if !isEmoji { Spacer() }
                // Button(action: { onEdit?() }) {
                //     Text("수정")
                //         .font(.customFont(Font.body4Regular))
                //         .foregroundColor(.coreLightGray)
                // }

                Button(action: { onDelete?() }) {
                    Text("삭제")
                        .font(UIDevice.isPad ? .customFont(Font.body6Regular): .customFont(Font.body4Regular))
                        .foregroundColor(.coreLightGray)
                }
            }
        }
        .padding(EdgeInsets(top: 14, leading: 16, bottom: 16, trailing: 16))
    }

    private func formattedFloatingDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "a hh시 mm분"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: 0, y: 0))
        path.addLine(to: CGPoint(x: rect.width - 5, y: rect.height / 2 - 5))
        path.addQuadCurve(
            to: CGPoint(x: rect.width - 5, y: rect.height / 2 + 5),
            control: CGPoint(x: rect.width + 4, y: rect.height / 2)
        )
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        path.closeSubpath()
        return path
    }
}
