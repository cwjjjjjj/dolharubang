import SwiftUI

struct JarangView: View {
    let isLoading: Bool  // 상위 뷰에서 로딩 상태를 받습니다.
    let nickname: String  // 실제 데이터
    let roomName: String  // 실제 데이터
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                    
                if isLoading {Rectangle()
                        .fill(.coreGray)
                        .frame(width: geo.size.width, height: geo.size.height * 17/22)
                        .cornerRadius(15)
                        .shimmering(active: isLoading)
                }
                else {
                    Image("Logo")  // 실제 이미지
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geo.size.width, height: geo.size.height * 17/22)
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Spacer().frame(height: 2)
                        Text(isLoading ? "닉네임" : nickname)
                            .font(.customFont(Font.body4Bold))
                            .foregroundStyle(.coreDarkGreen)
                        Text(isLoading ? "방 이름" : roomName)
                            .font(.customFont(Font.body3Bold))
                            .foregroundStyle(.coreBlack)
                        Spacer().frame(height: 3)
                    }
                    .padding(.horizontal, 12)
                    Spacer()
                    Button(action: {
                        print("클로버 보내기 버튼이 눌렸습니다.")
                    }) {
                        ZStack {
                            Circle()
                                .fill(.coreWhite)
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Image("Clover")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                )
                        }
                    }
                    .padding(.horizontal, 12)
                    .opacity(isLoading ? 0 : 1)
                }
            }
            .background(.ffffff)
            .cornerRadius(15)
        }
    }
}

// Preview를 위한 예시
struct JarangView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            JarangView(isLoading: true, nickname: "", roomName: "")
            JarangView(isLoading: false, nickname: "사용자", roomName: "우리 방")
        }
    }
}
