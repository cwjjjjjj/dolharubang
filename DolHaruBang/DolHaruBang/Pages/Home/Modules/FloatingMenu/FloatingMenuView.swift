//
//  FloatingMenuButtonView.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/1/24.
//



import SwiftUI
import ComposableArchitecture


// MARK: - Floating menu
// 선언은 NavigationStack 초기 선언 부분 edgeInsets
// 표시되는 부분은 홈부터
// currentStack 의 갯수를 확인해 표시될지를 결정


struct FloatingMenuView : View {
    var nav: StoreOf<NavigationFeature>
    
    // NavigationStack이 만들어졌을때 ( 시작 화면 생성될때 - 시작화면에 NavigationStack ) 생성되기에 앱 전반적인 상태에서 관리할 수 있음
    struct ViewState: Equatable {
        struct Screen: Equatable, Identifiable {
            let id: StackElementID
            let name: String
        }
        
        var currentStack: [Screen]
        
        // 현재 페이지와 패턴 매칭이되면 아래의 동작 실행
        // 홈 이전의 화면들에 갔을 경우 currentStack을 비워 Floationg이 되지 않게
        init(state: NavigationFeature.State) {
            self.currentStack = []
            for (id, element) in zip(state.path.ids, state.path) {
                switch element {
                case .calendar:
                    self.currentStack.insert(Screen(id: id, name: "Screen A"), at: 0)
                case .harubang(_):
                    self.currentStack.insert(Screen(id: id, name: "Screen B"), at: 0)
                case .park(_):
                    self.currentStack.insert(Screen(id: id, name: "park"), at: 0)
                case .mypage(_):
                    self.currentStack.insert(Screen(id: id, name: "mypage"), at: 0)
                case .home(_):
                    self.currentStack.insert(Screen(id: id, name: "home"), at: 0)
                case .TrophyView(_):
                    self.currentStack.insert(Screen(id: id, name: "Trophy"), at: 0)
                case .SettingView(_):
                    self.currentStack.insert(Screen(id: id, name: "Setting"), at: 0)
                default :
                    self.currentStack.removeAll()
                }
            }
        }
    }
    
    var body : some View {
        let viewState = ViewState(state: nav.state)
        
        // 홈 이후부터 표시되게
        if viewState.currentStack.count > 0 {
            HStack(spacing:2){
                BottomButtonView(store : nav ,imageName: "Calander", buttonText: "달력"){
                    nav.send(.goToScreen(.calendar(CalendarFeature())))
                }
                BottomButtonView(store : nav ,imageName: "Harubang", buttonText: "하루방"){
                    nav.send(.goToScreen(.harubang(HaruBangFeature())))
                }
                BottomButtonView(store : nav , imageName: "Home"){
                    nav.send(.goToScreen(.home(HomeFeature())))
                }
                BottomButtonView(store : nav ,imageName: "Park", buttonText: "공원"){
                    nav.send(.goToScreen(.park(ParkFeature())))
                }
                BottomButtonView(store : nav , imageName: "Mypage", buttonText: "마이페이지") {
                    nav.send(.goToScreen(.mypage(MyPageFeature())))
                }
                
            }
            .padding(.horizontal, UIScreen.main.bounds.width * 12/393)
        }
    }
}


struct BottomButtonView: View {
    @State var store : StoreOf<NavigationFeature>
    var imageName: String
    var buttonText: String?
    var closure : () -> Void
    
    var body: some View {
        
        // NavigationFeature.State.clickEnable이 true일때만 실행
        // 비동기 처리를 위함
        Button(action: {
            if store.enableClick {
                closure()
            }
        }) {
            ZStack {
                Image("bottomButton")
                    .resizable()
                    .scaledToFill()
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Image(imageName)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: UIScreen.main.bounds.width * 48/393, height: UIScreen.main.bounds.width * 48/393)
                        Spacer()
                    }
                    if let buttonText = buttonText {
                        HStack(alignment: .center) {
                            Text(buttonText)
                                .font(Font.customFont(Font.caption1))
                                .foregroundColor(.white)
                                .padding(.bottom, UIScreen.main.bounds.width * 2/393)
                        }
                    }
                }
            }
            .frame(width: UIScreen.main.bounds.width * 74/393, height: UIScreen.main.bounds.width * 74/393)
            .cornerRadius(15)
            .padding(.bottom, UIScreen.main.bounds.width * 24/393)
        }
    }
}

