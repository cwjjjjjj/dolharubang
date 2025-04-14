import SwiftUI
import CoreData
import ComposableArchitecture

struct EntryPointView: View {

    @State private var showMainView = false // 메인 뷰를 표시할지를 결정하는 상태 변수


    var body: some View {
        ZStack{
            if showMainView {
                    Demo(store: Store(initialState: NavigationFeature.State()) { NavigationFeature() }) { nav in
                        DBTIGuideView( nav: nav, store: Store(initialState: DBTIFeature.State()) { DBTIFeature() })
                    }

//                    DBTIGuideView()
//                    LoginView( )
                    // LoginView()
//                    HomeView(store:EntryPointView.store)
//                }
//
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
