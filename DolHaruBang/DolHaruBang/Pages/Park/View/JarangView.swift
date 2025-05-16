import SwiftUI

struct JarangView: View {
    
    let isLoading: Bool
    let jarang: Jarang
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                    
                if isLoading {
                    Rectangle()
                        .fill(.coreGray)
                        .frame(width: geo.size.width, height: geo.size.height * 17/22)
                        .cornerRadius(15)
                        .shimmering(active: isLoading)
                }
                else {
                    if let urlString = jarang.profileImgUrl, let url = URL(string: urlString), !urlString.isEmpty {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .empty:
                                ProgressView()
                                    .frame(width: geo.size.width, height: geo.size.height * 17/22)
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geo.size.width, height: geo.size.height * 17/22)
                                    .cornerRadius(15)
                            case .failure(_):
                                Image("Logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geo.size.width, height: geo.size.height * 17/22)
                            @unknown default:
                                Image("Logo")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: geo.size.width, height: geo.size.height * 17/22)
                            }
                        }
                    } else {
                        Image("Logo")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: geo.size.width, height: geo.size.height * 17/22)
                    }
                }
                
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Spacer().frame(height: 2)
                        Text(isLoading ? "닉네임" : jarang.nickname)
                            .font(.customFont(Font.body4Bold))
                            .foregroundStyle(.coreDarkGreen)
                        Text(isLoading ? "돌 이름" : jarang.stoneName)
                            .font(.customFont(Font.body3Bold))
                            .foregroundStyle(.coreBlack)
                        Spacer().frame(height: 3)
                    }
                    .padding(.horizontal, 12)
                    Spacer()
//                    Button(action: {
//                        print("클로버 보내기 버튼이 눌렸습니다.")
//                    }) {
//                        ZStack {
//                            Circle()
//                                .fill(.coreWhite)
//                                .frame(width: 32, height: 32)
//                                .overlay(
//                                    Image("Clover")
//                                        .resizable()
//                                        .aspectRatio(contentMode: .fit)
//                                )
//                        }
//                    }
//                    .padding(.horizontal, 12)
//                    .opacity(isLoading ? 0 : 1)
                }
            }
            .background(.ffffff)
            .cornerRadius(15)
        }
    }
}
