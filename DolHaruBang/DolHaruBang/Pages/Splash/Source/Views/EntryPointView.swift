import SwiftUI
import CoreData
import ComposableArchitecture

struct EntryPointView: View {

    @State private var showMainView = false // 메인 뷰를 표시할지를 결정하는 상태 변수
    @State var store: StoreOf<LoginFeature>

    var body: some View {
        ZStack{
            if showMainView {
                Demo(store: Store(initialState: NavigationFeature.State()) { NavigationFeature() }) { nav in
                    LoginView( nav: nav, store: store).onAppear{
                        store.send(.isFirstRequest)
                    }
             }
                
            } else {
                SplashView().onAppear{
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1){
                        withAnimation{
                            showMainView = true
                        }
                    }
                }
            }
        }
    }

}
