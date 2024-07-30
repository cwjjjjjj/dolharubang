import SwiftUI

struct LoginView: View {
    var body: some View {
        NavigationView {
            ZStack {
                Color.mainGreen
                    .edgesIgnoringSafeArea(.all)

                VStack {
                    Text("돌하루방")
                        .font(.customFont(Font.h7))
                        .foregroundColor(.mainWhite)
                        .padding(.vertical, 15)
                    
                    Spacer()

                    VStack(alignment: .leading) {
                        Text("반가워요!")
                            .font(.customFont(Font.h2))
                            .foregroundColor(.mainWhite)
                            .padding(.bottom, 8)
                        
                        Text("나만의 돌과 함께 하루를 보낼\n방문을 열어볼까요?")
                            .font(.customFont(Font.subtitle2))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 32)

                    Spacer()
                    
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                            
                            NavigationLink(destination: InputUserInfoView()) {
                                ZStack {
                                    HStack {
                                        Spacer().frame(width: 20)
                                        Image(systemName: "message.fill")
                                            .font(.system(size: 20))
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                    HStack {
                                        Spacer()
                                        Text("카카오톡으로 로그인")
                                            .font(.system(size: 15))
                                            .fontWeight(.bold)
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                }
                                .frame(width: min(geometry.size.width * 0.8, 350), height: 50)
                                .background(Color.yellow)
                                .cornerRadius(16)
                            }
                            Spacer()
                        }
                    }
                    .frame(height: 50)
                    .padding(.bottom, 50) // Adjust the padding as necessary
                }
            }
        }
    }
}

struct ContentView: View {
    var body: some View {
        LoginView()
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
