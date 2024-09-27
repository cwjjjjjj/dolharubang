import SwiftUI

struct SpeechBubbleView: View {
    var content: String
    var createdAt: Date // createdAt을 Date 타입으로 변경
    var isResponse: Bool // 답장 여부
    var onEdit: (() -> Void)? // 수정 버튼 액션
    var onDelete: (() -> Void)? // 삭제 버튼 액션
    var isEmoji: Bool // 이모지인지 여부
    
    var body: some View {
        HStack (alignment: .top, spacing: 0) {
            if !isResponse {
                Spacer()
            }
            else {
                HStack (alignment: .top, spacing: 1){
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
                // 내용 표시 부분
                contentDisplay
                
                // 날짜와 수정/삭제 버튼
                if (!isEmoji && !isResponse) {
                    Divider().foregroundStyle(Color(hex: "E5DFD7"))
                        .padding(.horizontal, 16)
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
            else {
                Triangle()
                    .fill(Color.coreWhite)
                    .frame(width: 10, height: 16)
                    .rotationEffect(Angle(degrees: 0))
                    .padding(.top, 24)
            }
        }
        .padding(.horizontal, 16)
    }
    
    // 내용 표시 부분 (이모지 또는 텍스트)
    private var contentDisplay: some View {
        Group {
            if isEmoji, let emojiImage = UIImage(named: content) {
                Image(uiImage: emojiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .padding(8)
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
    
    // 날짜 및 액션 버튼 표시 부분
    private var dateAndActionButtons: some View {
        HStack {
            Text(formattedFloatingDate(createdAt)) // 시간만 표시
                .font(.customFont(Font.body4Regular))
                .foregroundColor(.coreGreen)
            
            // 답장이 아닌 경우 수정 및 삭제 버튼 표시
            if !isResponse {
                Spacer()
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
        .padding(EdgeInsets(top: 14, leading: 16, bottom: 16, trailing: 16))
    }
    
    // 오전/오후 형식의 시간 표시 함수
    private func formattedFloatingDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.dateFormat = "a hh시 mm분"
        return formatter.string(from: date)
    }
}

struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        // 삼각형의 왼쪽 꼭짓점
        path.move(to: CGPoint(x: 0, y: 0))
        
        // 삼각형의 오른쪽 곡선 꼭짓점
        path.addLine(to: CGPoint(x: rect.width - 5, y: rect.height / 2 - 5))
        
        // 오른쪽 꼭짓점에 곡선 추가
        path.addQuadCurve(
            to: CGPoint(x: rect.width - 5, y: rect.height / 2 + 5),
            control: CGPoint(x: rect.width + 4, y: rect.height / 2) // 곡선 컨트롤 여기서!
        )
        
        // 삼각형의 아래쪽 꼭짓점
        path.addLine(to: CGPoint(x: 0, y: rect.height))
        
        // 시작점으로 돌아가서 닫기
        path.closeSubpath()
        
        return path
    }
}
