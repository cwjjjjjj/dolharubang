import SwiftUI
import ComposableArchitecture

struct DoljanchiView: View {
    @State var store: StoreOf<DoljanchiFeature>
    
    var body: some View {
        VStack(spacing: 16) {
            if (store.errorMessage == nil) {
                TabView(selection: $store.state.currentPage) {
                    ForEach(0..<store.state.maxPage, id: \.self) { pageIndex in
                        GridView(
                            rowNums: $store.rowNum,
                            colNums: $store.colNum,
                            jarangs: $store.jarangs,
                            currentPage: $store.state.currentPage
                        )
                        .tag(pageIndex)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                
                CustomPageIndicator(numberOfPages: store.state.maxPage, currentPage: $store.state.currentPage)
            } else {
                VStack(spacing: 16) {
                    Spacer()
                    Text("돌잔치를 불러오는 데 실패하였습니다.")
                        .font(.customFont(Font.body2Bold))
                        .foregroundColor(.coreDisabled)
                        .multilineTextAlignment(.center)
                    Button(action: {
                        store.send(.fetchFeed(nil, "LATEST", 16))
                    }) {
                        HStack {
                            Text("재시도")
                                .font(.customFont(Font.button4))
                                .foregroundColor(.coreWhite)
                        }
                        .frame(width: 82, height: 32)
                        .background(.coreGreen)
                        .cornerRadius(16)
                    }
                    Spacer()
                }
                .frame(width: UIScreen.main.bounds.width)
            }
            
            Button(action: {
                print("돌 자랑하기 버튼이 눌렸습니다.")
                store.send(.toggleJarangPopup)
            }) {
                HStack {
                    Text("돌 자랑하기")
                        .font(.customFont(Font.button4))
                        .foregroundColor(.coreWhite)
                    
                    .padding()
                }
                .background(store.canRegist ? .coreGreen : .coreDisabled)
//                .background(.coreGreen) // test용
                .cornerRadius(16)
                
            }
            .disabled(!store.canRegist)
            
            Spacer().frame(height: 10)
        }
        .background(.coreWhite)
        .cornerRadius(15, corners: [.bottomLeft, .bottomRight])
        .onAppear {
            store.send(.fetchFeed(nil, "LATEST", 16))
        }
    }
}

// 몇 페이지인지 나타내는 표시
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
    @Binding var rowNums: Int
    @Binding var colNums: Int
    @Binding var jarangs: [Jarang]
    @Binding var currentPage: Int

    var body: some View {
        if !jarangs.isEmpty {
            let itemsPerPage = rowNums * colNums
            let startIndex = currentPage * itemsPerPage
            let endIndex = min(startIndex + itemsPerPage, jarangs.count)

            if startIndex < jarangs.count {
                let pageItems = Array(jarangs[startIndex..<endIndex])

                Grid(horizontalSpacing: 16, verticalSpacing: 16) {
                    ForEach(0..<rowNums, id: \.self) { row in
                        GridRow {
                            ForEach(0..<colNums, id: \.self) { col in
                                let index = row * colNums + col
                                if index < pageItems.count {
                                    JarangView(
                                        isLoading: false,
                                        jarang: pageItems[index]
                                    )
                                    .frame(maxWidth: .infinity)
                                } else {
                                    Color.clear
                                        .frame(maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
                                }
                            }
                        }
                    }
                }
                .padding()
            } else {
                EmptyView()
            }
        } else {
            EmptyView()
        }
    }
}

