import SwiftUI
import ComposableArchitecture
import AuthenticationServices
import KakaoSDKUser

struct LoginView: View {
    
    @Environment(\.presentationMode) var presentationMode // 뒤로가기 동작을 위한 환경 변수
    @State private var logoutObserver: NSObjectProtocol?
    @State private var loginObserver: NSObjectProtocol?
    @Bindable var nav: StoreOf<NavigationFeature>
    @StateObject private var signInViewModel = SignInViewModel()
    @State var store: StoreOf<LoginFeature>
    
    var body: some View {
        
        // path : 이동하는 경로들을 전부 선언해줌
        // $nav.scope : NavigationFeature의 forEach에 접근
        NavigationStack(path: $nav.scope(state: \.path, action: \.path)){
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
                                    if (UserApi.isKakaoTalkLoginAvailable()) {
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
                                }
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
                                        signInViewModel.handleSignInWithAppleResult(result)
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
            }
            .edgesIgnoringSafeArea(.all)
        }
        // MARK: NavigationStack에서 관리하는 경로&리듀서 선언
        // 해당 값을 가지고 NavigationStack이 패턴매칭을 함
        destination : { nav in
            switch nav.case {
            case let .calendar(store):
                CalendarView(store: store)
            case let .harubang(store):
                HaruBangView(store: store)
            case let .mypage(store):
                MyPageView(store : store)
            case let .park(store):
                ParkView(store : store)
            case let .home(store):
                HomeView(store : store)
            case let .DBTIGuideView(store):
                DBTIGuideView(store : store)
            case let .DBTIQuestionView(store):
                DBTIQuestionView(store : store)
            case let .DBTIResultView(store):
                DBTIResultView(store : store)
            case let .TrophyView(store):
                TrophyView(store : store)
            case let .SettingView(store):
                SettingView(store : store)
            case let .input(store):
                InputUserInfoView(store : store)
           
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("TokenVaild"))) { notification in
            if let userInfo = notification.userInfo,
               let isFirst = userInfo["isFirst"] as? Bool {
                // isFirst 값에 따라 분기
                if !isFirst {
                    nav.send(.goToScreen(.input(DBTIFeature())))
                } else {
                    nav.send(.goToHome)
                }
            }
        }
        .onAppear{
            logoutObserver = NotificationCenter.default.addObserver(
                           forName: NSNotification.Name("LogoutRequired"),
                           object: nil,
                           queue: .main
                       ) { _ in
                           nav.send(.popToRoot)
                       }
        }
        
        // MARK: FloatingMenuView Start
        .safeAreaInset(edge: .bottom) {
            FloatingMenuView(nav: nav)
        }
        .edgesIgnoringSafeArea(.all)
        .navigationBarBackButtonHidden(true) // 기본 뒤로가기 버튼 숨기기
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
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

class SignInViewModel: ObservableObject {
    @Published var userInfo: UserInfoo?
    
    func handleSignInWithAppleResult(_ result: Result<ASAuthorization, Error>) {
        switch result {
        case .success(let authorization):
            if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
                let userId = appleIDCredential.user
                let email = appleIDCredential.email
                let fullName = appleIDCredential.fullName
                
                DispatchQueue.main.async {
                    self.userInfo = UserInfoo(
                        id: userId,
                        email: email,
                        firstName: fullName?.givenName,
                        lastName: fullName?.familyName
                    )
                }
                
                print("User ID: \(userId)")
                print("Email: \(email ?? "N/A")")
                print("Full Name: \(fullName?.givenName ?? "") \(fullName?.familyName ?? "")")
            }
        case .failure(let error):
            print("Authorization failed: \(error.localizedDescription)")
        }
    }
}

struct UserInfoo {
    let id: String
    let email: String?
    let firstName: String?
    let lastName: String?
}
