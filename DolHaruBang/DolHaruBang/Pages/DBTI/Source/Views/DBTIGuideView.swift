//
//  DBTIGuideView.swift
//  DolHaruBang
//
//  Created by 안상준 on 7/31/24.
//

import SwiftUI
import ComposableArchitecture

// MARK: NavigationStack Start (임시 위치 추후에는 로그인 화면)
struct DBTIGuideView: View {
    @Environment(\.presentationMode) var presentationMode // 뒤로가기 동작을 위한 환경 변수
    
    @Bindable var nav: StoreOf<NavigationFeature>
   
    var body: some View {
        
        // path : 이동하는 경로들을 전부 선언해줌
        // $nav.scope : NavigationFeature의 forEach에 접근
        NavigationStack(path: $nav.scope(state: \.path, action: \.path)) {
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
                            NavigationLink(state : NavigationFeature.Path.State.DBTIQuestion1View(DBTIFeature.State())){
                                HStack {
                                    Spacer()
                                    Text("테스트 시작")
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
        }
        // MARK: NavigationStack에서 관리하는 경로&리듀서 선언
        // 해당 값을 가지고 NavigationStack이 패턴매칭을 함
        destination : { nav in
            switch nav.case {
            case let .harubang(store):
                HaruBangView(store: store)
            case let .mypage(store):
                MyPageView(store : store)
            case let .park(store):
                ParkView(store : store)
            case let .home(store):
                HomeView(store : store)
            case let .DBTIQuestion1View(store):
                DBTIQuestion1View(store : store)
            case let .DBTIResultView(store):
                DBTIResultView(store : store)
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
