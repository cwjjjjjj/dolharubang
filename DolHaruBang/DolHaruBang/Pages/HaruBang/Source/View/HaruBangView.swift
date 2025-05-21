import SwiftUI
import ComposableArchitecture

struct HaruBangView: View {
    @State var store: StoreOf<HaruBangFeature>
    
    var body: some View {
        GeometryReader { geometry in
            let totalHeight = geometry.size.height
            let scale = calculateScale(width: geometry.size.width, height: geometry.size.height)
            
            ZStack {
                Image(Background(rawValue: store.state.selectedBackground.rawValue)!.fileName)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    Spacer().frame(height: totalHeight * 77 / 852)
                    
                    HStack {
                        Spacer()
                        Text("하루방")
                            .padding(.bottom , 15)
                            .font(Font.customFont(Font.h6))
                            .shadow(radius: 4, x: 0, y: 1)
                            .frame(width: geometry.size.width * 0.4, alignment: .center)
                        Spacer()
                    }
                    
                    Spacer()
                    
                    TalkView(store: store.scope(state: \.talkFeatureState, action: \.talkFeatureAction))
                        .background(.clear)
                        .frame(height: totalHeight * 680 / 852)
                        .scaleEffect(scale)
                    

                    Spacer().frame(minHeight: totalHeight * 64 / 804)
                }
                
            }
            .edgesIgnoringSafeArea(.all)
        }
        .navigationBarBackButtonHidden(true)
    }
}
