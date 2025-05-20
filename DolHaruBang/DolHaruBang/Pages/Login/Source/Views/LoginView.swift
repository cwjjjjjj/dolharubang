import SwiftUI
import ComposableArchitecture
import AuthenticationServices
import CryptoKit
import KakaoSDKUser

struct LoginView: View {
    
    @Environment(\.presentationMode) var presentationMode // 뒤로가기 동작을 위한 환경 변수
    @State var store: StoreOf<LoginFeature>
    @StateObject private var signInViewModel = SignInWithAppleViewModel()
    
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
                
                Spacer().frame(height: UIScreen.main.bounds.height * 0.24)
                
                LazyVStack(alignment: .leading, spacing: 0) {
                    CustomText(text: "반가워요!", font: Font.uiFont(for: Font.h4)!, textColor: .coreWhite, textAlign: .left)
                    
                    //                    Spacer().frame(height: 30).fixedSize()
                    
                    CustomText(text: "나만의 돌과 함께 하루를 보낼\n방문을 열어볼까요?!", font: Font.uiFont(for: Font.subtitle2)!, textColor: .coreWhite, textAlign: .left                )
                        .fixedSize(horizontal: false, vertical: true)
                }
                .padding(.horizontal, 36)
                
                Spacer().frame(height: UIScreen.main.bounds.height * 0.24)
                
                LazyVStack {
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                            Button(action: {
                                if (UserApi.isKakaoTalkLoginAvailable() && !store.kakaoButtonDisable) {
                                    UserApi.shared.loginWithKakaoTalk {(oauthToken, error) in
                                        if let error = error {
                                            print(error)
                                        }
                                        else {
                                            guard let token = oauthToken else {
                                                // Handle the nil case
                                                return
                                            }
                                            
                                            let accessToken = token.accessToken
                                            store.send(.kakaoLoginRequested(accessToken))
                                        }
                                    }
                                }else{
                                    UserApi.shared.loginWithKakaoAccount{(oauthToken, error) in
                                        if let error = error {
                                            print(error)
                                        }
                                        else {
                                            guard let token = oauthToken else {
                                                // Handle the nil case
                                                return
                                            }
                                            
                                            let accessToken = token.accessToken
                                            store.send(.kakaoLoginRequested(accessToken))
                                        }
                                    }
                                }
                            }){
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
                            }.disabled(store.kakaoButtonDisable)
                            Spacer()
                        }
                    }
                }
                .padding(.bottom, UIScreen.main.bounds.height * 0.04)
                
                LazyVStack {
                    GeometryReader { geometry in
                        HStack {
                            Spacer()
                            SignInWithAppleButton(
                                .signIn,
                                onRequest: { request in
                                    request.requestedScopes = [.fullName, .email]
                                },
                                onCompletion: { result in
                                    switch result {
                                    case .success(let authorization):
                                        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                                              let identityToken = credential.identityToken,
                                              let idTokenString = String(data: identityToken, encoding: .utf8)else {
                                            print("토큰 파싱 실패")
                                            return
                                        }
                                        
                                        guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                                              let name = credential.fullName else {
                                            print("토큰 파싱 실패")
                                            return
                                        }
                                        
                                        var userName = ""
                                        if let fullNameComponents = credential.fullName {
                                            let formatter = PersonNameComponentsFormatter()
                                            userName = formatter.string(from: fullNameComponents)
                                        }
                                        
                                        store.send(.appleLoginRequested(
                                            idTokenString,
                                            userName
                                        ))
                                        
                                    case .failure(let error):
                                        print("Apple 로그인 실패: \(error.localizedDescription)")
                                    }
                                }
                            )
                            .frame(width: geometry.size.width - 72, height: 48)
                            .cornerRadius(16)
                            .padding()
                            Spacer()
                        }
                    }
                }.padding(.bottom, UIScreen.main.bounds.height * 0.15)
            }
            
            if(store.kakaoButtonDisable){
                VStack(spacing: 16) {
                    Spacer().frame(height: 280)
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                        .scaleEffect(1.5)
                    Text("로그인 중이에요")
                        .font(Font.customFont(Font.body3Bold))
                        .foregroundColor(.white)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear{
            store.send(.isFirstRequest)
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TokenVaild"))) { notification in
            if let userInfo = notification.userInfo,
               let isFirst = userInfo["isFirst"] as? Bool {
                // isFirst 값에 따라 분기
                if isFirst {
                    store.send(.goToInput)
                    //                    nav.send(.goToScreen(.input(DBTIFeature())))
                } else {
                    store.send(.goToHome)
                    //                    nav.send(.goToHome)
                }
            }
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true) // 기본 뒤로가기 버튼 숨기기
      
    }
}


class SignInWithAppleViewModel: NSObject, ObservableObject {
    // 필요하다면 @Published var 상태 추가 가능
    
    // 로그인 결과 처리
    func handleSignInWithAppleResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            guard let credential = authorization.credential as? ASAuthorizationAppleIDCredential,
                  let authCodeData = credential.authorizationCode,
                  let idTokenData = credential.identityToken else { return }
            
            let authorizationCode = String(decoding: authCodeData, as: UTF8.self)
            let idToken = String(decoding: idTokenData, as: UTF8.self)
            
            // ✅ 여기서 백엔드로 코드와 토큰을 전달
            sendToBackend(authorizationCode: authorizationCode, idToken: idToken)
            
        case .failure(let error):
            print("Apple Sign-In failed: \(error.localizedDescription)")
        }
    }
    
    private func sendToBackend(authorizationCode: String, idToken: String) {
        // 실제 백엔드 API 주소로 변경
        
        print("ㅇㅇ",authorizationCode,idToken)
        guard let url = URL(string: "https://your-backend.com/api/auth/apple") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "code": authorizationCode,
            "id_token": idToken
        ]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            // 필요시 응답 처리
        }.resume()
    }
}

extension String {
    func decodeAppleUserIdentifier() -> String? {
        let segments = self.components(separatedBy: ".")
        guard segments.count > 1 else { return nil }
        
        let payload = segments[1]
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let padded = payload.padding(
            toLength: ((payload.count + 3) / 4) * 4,
            withPad: "=",
            startingAt: 0
        )
        
        guard let data = Data(base64Encoded: padded),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }
        
        return json["sub"] as? String
    }
}
