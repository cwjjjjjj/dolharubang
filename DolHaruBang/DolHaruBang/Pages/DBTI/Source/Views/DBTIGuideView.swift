//
//  DBTIGuideView.swift
//  DolHaruBang
//
//  Created by 안상준 on 7/31/24.
//

import SwiftUI
import ComposableArchitecture
import AuthenticationServices
import KakaoSDKUser

// MARK: NavigationStack Start (임시 위치 추후에는 로그인 화면)
struct DBTIGuideView: View {
    
    @State var store: StoreOf<DBTIFeature>
    
    var body: some View {
            ZStack {
                // 배경
                Color.mainWhite
                    .edgesIgnoringSafeArea(.all)
                
                GeometryReader { geometry in
                    VStack (alignment: .center, spacing: 0){
                        Spacer().frame(height: geometry.size.height * 0.2892)
                        HStack {
                            Spacer()
                            CustomText(text: "이제 하루를 함께 할\n반려돌을 주워볼까요?",
                                       font: Font.uiFont(for: Font.subtitle2)!,
                                       textColor: .coreBlack,
                                       letterSpacingPercentage: -2.5,
                                       lineSpacingPercentage: 160,
                                       textAlign: .center
                            )
                            .fixedSize(horizontal: false, vertical: true)
                            
                            Spacer()
                        }.padding(.bottom, 33)
                        
                        HStack {
                            Spacer()
                            
                            Image(systemName: "chevron.down")
                                .foregroundColor(.coreLightGray)
                                .font(.system(size: 24))
                            
                            Spacer()
                        }
                        
                        Spacer().frame(height: geometry.size.height * 0.2)
                        
                        HStack {
                            Spacer()
                            
                            CustomText(text: "간단한 심리테스트를 통해\n나와 잘 맞는 반려돌을 주울 수 있어요!.",
                                       font: Font.uiFont(for: Font.body2Regular)!,
                                       textColor: .coreDisabled,
                                       letterSpacingPercentage: -2.5,
                                       lineSpacingPercentage: 180,
                                       textAlign: .center
                            )
                            
                            Spacer()
                        }.padding(.bottom, 16)
                        
                        Spacer().frame(height: 30)
                        
                       
                        HStack {
                            NavigationLink(state: NavigationFeature.Path.State.home(HomeFeature.State())) {
                                HStack {
                                    Spacer()
                                    Text("함께 시작하기!")
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
