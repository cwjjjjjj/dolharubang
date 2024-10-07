import SwiftUI
import ComposableArchitecture

struct DoljanchiView: View {
    let store: StoreOf<DoljanchiFeature>
    @State private var currentPage = 0
    
    var body: some View {
        VStack(spacing: 16) {
            TabView(selection: $currentPage) {
                ForEach(0..<4) { pageIndex in
                    GridView(rowNums: 2, colNums: 2)
                        .tag(pageIndex)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            
            CustomPageIndicator(numberOfPages: 4, currentPage: $currentPage)
            
            Button(action: {
                print("돌 자랑하기 버튼이 눌렸습니다.")
            }) {
                HStack {
                    Text("돌 자랑하기")
                        .font(.customFont(Font.button4))
                        .foregroundColor(.coreWhite)
                }
                .frame(width: 82, height: 32)
                .background(.coreGreen)
                .cornerRadius(16)
            }
            
            Spacer().frame(height: 10)
        }
        .background(.coreWhite)
        .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
    }
}

struct CustomPageIndicator: View {
    let numberOfPages: Int
    @Binding var currentPage: Int
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<numberOfPages, id: \.self) { page in
                Circle()
                    .fill(page == currentPage ? Color.coreGreen : Color.gray)
                    .frame(width: 8, height: 8)
                    .animation(.bouncy(), value: currentPage)
            }
        }
    }
}

struct GridView: View {
    let rowNums: Int
    let colNums: Int
    @State private var isLoading = true
    
    var body: some View {
        Grid(horizontalSpacing: 16, verticalSpacing: 16) {
            ForEach(0..<rowNums, id: \.self) { _ in
                GridRow {
                    ForEach(0..<colNums, id: \.self) { _ in
                        JarangView(isLoading: isLoading, nickname: "사용자", roomName: "우리 방")
                            .onAppear {
                                // 데이터 로딩 시뮬레이션
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    isLoading = false
                                }
                            }
                    }
                }
            }
        }
        .padding()
    }
}
