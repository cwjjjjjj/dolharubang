import SwiftUI
import ComposableArchitecture

struct DBTIQuestion1View: View {
    
    @State var store : StoreOf<DBTIFeature>
    
    @State private var selectedButton: Int? = nil
    @State private var tag: Int? = nil
    
    var body: some View {
        ZStack {
            // 배경
            Color.mainWhite
                .edgesIgnoringSafeArea(.all)
            
            GeometryReader { geometry in
                VStack(alignment: .center, spacing: 0) {
                    HStack {
                        Spacer()
                        
                        CustomText(text: "반려돌 줍기",
                                   font: Font.uiFont(for: Font.subtitle2)!,
                                   textColor: .coreGreen,
                                   letterSpacingPercentage: -2.5,
                                   lineSpacingPercentage: 160,
                                   textAlign: .center
                        )
                        
                        Spacer()
                    }
                    .position(x: UIScreen.main.bounds.width / 2, y: 77)

                    Spacer().frame(height: geometry.size.height * 0.3)
                    
                    HStack {
                        Spacer()
                        
                        CustomText(text: "Q1.",
                                   font: Font.uiFont(for: Font.subtitle2)!,
                                   textColor: .coreGreen,
                                   letterSpacingPercentage: -2.5,
                                   lineSpacingPercentage: 160,
                                   textAlign: .center
                        )
                        
                        Spacer()
                    }
                    
                    HStack {
                        Spacer()
                        
                        CustomText(text: "소풍을 같이 가기로 한 애인이\n당신을 위해 도시락을 싸려고 과일을 샀습니다.\n그런데 왠지 상한 거 같아서 본인이 먼저 먹어봤다가\n탈이 나서 소풍을 못 가게 되었습니다.\n이 때, 당신의 반응은?",
                                   font: Font.uiFont(for: Font.body1Regular)!,
                                   textColor: .coreBlack,
                                   letterSpacingPercentage: -2.5,
                                   lineSpacingPercentage: 160,
                                   textAlign: .center
                        )
                        .fixedSize(horizontal: false, vertical: true)
                        
                        Spacer()
                    }
                    
                    Spacer().frame(height: geometry.size.height * 0.15)
                    
                    VStack(alignment: .center, spacing: 16) {
//                        NavigationLink(destination: DBTIResultView(), tag: 1, selection: $tag) {
//                            EmptyView()
//                        }
                        
                        NavigationLink(state : NavigationFeature.Path.State.DBTIResultView(DBTIFeature.State())){
                            HStack {
                                Spacer()
                                Text("속 괜찮아?")
                                    .font(.customFont(Font.button1))
                                    .foregroundColor(.mainWhite)
                                Spacer()
                            }
                        }
                        .frame(width: 320, height: 48)
                        .background(Color.mainGreen)
                        .cornerRadius(24)
                        
                        NavigationLink(state : NavigationFeature.Path.State.DBTIResultView(DBTIFeature.State())){
                            HStack {
                                Spacer()
                                Text("상한 거 같은데 왜 먹어봤어?")
                                    .font(.customFont(Font.button1))
                                    .foregroundColor(.mainWhite)
                                Spacer()
                            }
                        }
                        .frame(width: 320, height: 48)
                        .background(Color.mainGreen)
                        .cornerRadius(24)
                        
                    }
                    
                    Spacer().frame(height: geometry.size.height * 0.2892)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true) // 기본 뒤로가기 버튼 숨기기
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: {
                        store.send(.goBack)
                    }) {
                        Image("backIcon")
                            .resizable()
                            .frame(width: 32, height: 32)
                    }
                }
                .offset(x: 8, y: 8)
            }
        }
    }
}
