import SwiftUI
import CoreData
import ComposableArchitecture

struct EntryPointView: View {
    
    //    @State private var showMainView = false // 메인 뷰를 표시할지를 결정하는 상태 변수
    @State private var logoutObserver: NSObjectProtocol?
    @Bindable var nav: StoreOf<NavigationFeature>
    @State var store: StoreOf<LoginFeature>
    
    
    var body: some View {
        NavigationStack(path: $nav.scope(state: \.path, action: \.path)){
            ZStack{
                //                if showMainView {
                //                Demo(store: Store(initialState: NavigationFeature.State()) { NavigationFeature() }) { nav in
                //                    LoginView( /*nav: nav, */store: store).onAppear{
                //                        store.send(.isFirstRequest)
                //                    }
                //             }
                
                //                } else {
                SplashView().onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        nav.send(.goToLogin)
                    }
                }
                //                }
            }
        }
        
        
        destination : { nav in
            switch nav.case {
            case let .login(store):
                LoginView(store: store)
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
        .onAppear{
            logoutObserver = NotificationCenter.default.addObserver(
                forName: NSNotification.Name("LogoutRequired"),
                object: nil,
                queue: .main
            ) { _ in
                nav.send(.goToScreen(.login(LoginFeature())))
            }
        }
        
        // MARK: FloatingMenuView Start
        .safeAreaInset(edge: .bottom) {
            FloatingMenuView(nav: nav)
        }
        .edgesIgnoringSafeArea(.all)
    }
    
}
