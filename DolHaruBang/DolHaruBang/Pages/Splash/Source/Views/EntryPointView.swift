import SwiftUI
import CoreData
import ComposableArchitecture

// 메인 ContentView 구조체 정의
struct EntryPointView: View {
//    // @Environment를 사용하여 현재 뷰 계층 구조의 관리 객체 컨텍스트를 가져옴 feat CoreData
//    @Environment(\.managedObjectContext) private var viewContext
//
//    // @FetchRequest를 사용하여 Core Data에서 데이터를 가져오는 요청을 정의
//    @FetchRequest(
//        // 데이터를 timestamp 키 경로를 기준으로 오름차순으로 정렬
//        sortDescriptors: [NSSortDescriptor(keyPath: \Item.timestamp, ascending: true)],
//        // 애니메이션 적용
//        animation: .default)
//    // 가져온 데이터를 FetchedResults<Item> 타입의 items로 저장
//    private var items: FetchedResults<Item>

    
    @State private var showMainView = false // 메인 뷰를 표시할지를 결정하는 상태 변수
    
//    static let store =  Store(initialState: HomeFeature.State()) {
//        HomeFeature()
//            ._printChanges()
//      }
    
    var body: some View {
        ZStack{
            if showMainView {
                    Demo(store: Store(initialState: NavigationFeature.State()) { NavigationFeature() }) { nav in
                        DBTIGuideView( nav: nav)
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
