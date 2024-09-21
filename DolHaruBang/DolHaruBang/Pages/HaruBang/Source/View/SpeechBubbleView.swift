import SwiftUI

struct SpeechBubbleView: View {
    var content: String
    var createdAt: Date // createdAt을 Date 타입으로 변경
    var isResponse: Bool // 답장 여부
    var onEdit: (() -> Void)? // 수정 버튼 액션
    var onDelete: (() -> Void)? // 삭제 버튼 액션
    var isEmoji: Bool // 이모지인지 여부
    
    var body: some View {
        HStack {
            if !isResponse {
                Spacer()
            }

            VStack(alignment: .leading, spacing: 0) {
                // 내용 표시 부분
                contentDisplay
                
                // 날짜와 수정/삭제 버튼
                if !isEmoji {
//                    Divider().foregroundStyle(Color(hex: "E5DFD7"))
//                        .padding(.horizontal, 116)
                    dateAndActionButtons
                }
            }
            .background(Color.coreWhite)
            .cornerRadius(15)
            .shadow(color: Color.gray.opacity(0.3), radius: 5, x: 0, y: 1)
            .frame(minWidth: 40, maxWidth: UIScreen.main.bounds.width * (256 / 393), alignment: isResponse ? .leading : .trailing)
            
            if isResponse {
                Spacer()
            }
        }
    }
    
    // 내용 표시 부분 (이모지 또는 텍스트)
    private var contentDisplay: some View {
        Group {
            if isEmoji, let emojiImage = UIImage(named: content) {
                Image(uiImage: emojiImage)
                    .resizable()
                    .frame(width: 48, height: 48)
                    .padding(16)
            } else {
                Text(content)
                    .font(.customFont(Font.body3Regular))
                    .foregroundColor(.coreBlack)
                    .lineLimit(nil)
                    .multilineTextAlignment(.leading)
                    .padding(16)

            }
        }
    }
    
    // 날짜 및 액션 버튼 표시 부분
    private var dateAndActionButtons: some View {
        HStack {
            Text(formattedFloatingDate(createdAt)) // 시간만 표시
                .font(.customFont(Font.body4Regular))
                .foregroundColor(.coreGreen)
            
            Spacer()
            
            // 답장이 아닌 경우 수정 및 삭제 버튼 표시
            if !isResponse {
                Button(action: { onEdit?() }) {
                    Text("수정")
                        .font(.customFont(Font.body4Regular))
                        .foregroundColor(.coreLightGray)
                }
                
                Button(action: { onDelete?() }) {
                    Text("삭제")
                        .font(.customFont(Font.body4Regular))
                        .foregroundColor(.coreLightGray)
                }
            }
        }
        .padding(16)
    }
    
    // 오전/오후 형식의 시간 표시 함수
    private func formattedFloatingDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a hh시 mm분"
        return formatter.string(from: date)
    }
}
