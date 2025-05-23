import SwiftUI
import ComposableArchitecture

struct DBTIQuestionView: View {
    let store: StoreOf<DBTIFeature>
    
    var body: some View {
        ZStack {
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
                                   textAlign: .center)
                        Spacer()
                    }
                    .position(x: UIScreen.main.bounds.width / 2, y: 77)
                    
                    Spacer().frame(height: geometry.size.height * 0.3)
                    
                    HStack {
                        Spacer()
                        CustomText(text: "Q\(store.withState { $0.questionIndex } + 1).",
                                   font: Font.uiFont(for: Font.subtitle2)!,
                                   textColor: .coreGreen,
                                   letterSpacingPercentage: -2.5,
                                   lineSpacingPercentage: 160,
                                   textAlign: .center)
                        Spacer()
                    }
                    .opacity(store.showQuestion ? 1 : 0)

                
                    HStack {
                        Spacer()
                        CustomText(text: questions[store.withState { $0.questionIndex }].text,
                                   font: Font.uiFont(for: Font.body1Regular)!,
                                   textColor: .coreBlack,
                                   letterSpacingPercentage: -2.5,
                                   lineSpacingPercentage: 160,
                                   textAlign: .center)
                        .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                    }
                    .opacity(store.showQuestion ? 1 : 0)
                    
                    Spacer().frame(height: geometry.size.height * 0.15)
                    

                    VStack(alignment: .center, spacing: 16) {
                        ForEach(0..<questions[store.withState { $0.questionIndex }].options.count, id: \.self) { index in
                            Button(action: {
                                store.send(.selectOption(index))
                                store.send(.nextQuestion)
                            }) {
                                VStack{
                                    
                                        Text("\(questions[store.withState { $0.questionIndex }].options[index].text)".splitCharacter())
                                        .frame(width: UIDevice.isPad ? 380: 320, height:UIDevice.isPad ? 100 : 48)
                                            .font(.customFont(Font.button1))
                                            .foregroundColor(.mainWhite)
                                            .lineLimit(5)
                                            .lineSpacing(4)
                                            .multilineTextAlignment(.center)
                                            .padding(.vertical,1)
                                }
//                                .frame(minHeight : UIDevice.isPad ? 100 : 48)
                                .background(Color.mainGreen)
                                .cornerRadius(24)
                            }
                        }
                    }
                    
                    .opacity(store.showOptions ? 1 : 0)
                    
                    Spacer().frame(height: geometry.size.height * 0.2892)
                }
            }
        }
        .ignoresSafeArea()
        .navigationBarBackButtonHidden(true)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                store.send(.toggleQuestion)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                store.send(.toggleOptions)
            }
        }
        .onChange(of: store.questionIndex) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                store.send(.toggleQuestion)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
                store.send(.toggleOptions)
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: { store.send(.goBack) }) {
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
