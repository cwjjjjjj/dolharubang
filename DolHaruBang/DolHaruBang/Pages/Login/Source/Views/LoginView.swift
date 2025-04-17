import SwiftUI
import ComposableArchitecture
import AuthenticationServices
import KakaoSDKUser

struct LoginView: View {
    var body: some View {
            ZStack {
            Color.mainGreen
                .edgesIgnoringSafeArea(.all)
            
            VStack(alignment: .leading) {
                HStack {
                    Spacer()
                    
                    Text("돌하루방")
                        .font(.customFont(Font.h7))
                        .foregroundColor(.mainWhite)
                    
                    Spacer()
                }.position(x: UIScreen.main.bounds.width / 2, y: 110)
                
                Spacer().frame(height: UIScreen.main.bounds.height * 0.333)
                
                LazyVStack(alignment: .leading, spacing: 0) {
                    CustomText(text: "반가워요!", font: Font.uiFont(for: Font.h4)!, textColor: .coreWhite, textAlign: .left)
                    
                    //                    Spacer().frame(height: 30).fixedSize()
                    
                    CustomText(text: "나만의 돌과 함께 하루를 보낼\n방문을 열어볼까요?!", font: Font.uiFont(for: Font.subtitle2)!, textColor: .coreWhite, textAlign: .left                )
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 36)
                
                Spacer().frame(height: UIScreen.main.bounds.height * 0.2877)
                
                LazyVStack {
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                            
//                            Button(action: {
//                                if (UserApi.isKakaoTalkLoginAvailable()) {
//                                    UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
//                                        if let error = error {
//                                            print("에러")
//                                            print(error)
//                                        }
//                                        else {
//                                            print("loginWithKakaoTalk() success.")
//                                            // 성공 시 동작 구현
//                                            guard let token = oauthToken else {
//                                                // Handle the nil case
//                                                return
//                                            }
//                                            
//                                            let accessToken = token.accessToken
//                                            store.send(.kakaoLoginRequested(accessToken))
//                                        }
//                                    }
//                                }
//                            }){
//                                Text("카카오")
//                            }
//                            
//                            // 애플로그인 테스트
//                            SignInWithAppleButton(
//                                .signIn,
//                                onRequest: { request in
//                                    request.requestedScopes = [.fullName, .email]
//                                },
//                                onCompletion: { result in
//                                    signInViewModel.handleSignInWithAppleResult(result)
//                                }
//                            )
//                            .frame(width: 280, height: 45)
//                            .padding()
                            
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
                                            .fontWeight(.medium)
                                            .foregroundColor(.black)
                                        Spacer()
                                    }
                                }
                                .frame(width: geometry.size.width - 72, height: 48)
                                .background(Color.kakao)
                                .cornerRadius(16)
                            }
                            
                            Spacer()
                        }
                    }
                }
                .padding(.bottom, UIScreen.main.bounds.height * 0.28)
            }
        }
        
        .edgesIgnoringSafeArea(.all)
    }
}
