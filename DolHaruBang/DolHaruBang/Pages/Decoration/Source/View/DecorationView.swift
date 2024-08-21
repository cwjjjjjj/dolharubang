//
//  DecorationView.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/20/24.
//

import SwiftUI
import ComposableArchitecture

struct DecorationView : View {
    enum Tab { // Tag에서 사용할 Tab 열겨형
            case background, shape, face
        }
    @State private var selected: Tab = .background
    
    let store: StoreOf<HomeFeature>
    
    var body: some View {
        VStack(spacing: 0) {
            
            HStack(spacing: 8) {
                
                TabButton(
                    title: "배경",
                    isSelected: selected == .background,
                    action: { selected = .background }
                            )
                
                
                
                TabButton(
                    title: "얼굴형",
                    isSelected: selected == .shape,
                    action: { selected = .shape }
                            )
                
                TabButton(
                    title: "얼굴",
                    isSelected: selected == .face,
                    action: { selected = .face }
                          )
           
                Spacer()
            }
            .padding(10)
            .padding(.horizontal, 10)
            .frame(height: 58)
            
            
            TabView(selection: $selected) {
                                Group {
                                    // 배경
                                    NavigationStack {
                                        CustomizeView<Background>(store: store)
                                  
                                    }
                                    .tag(Tab.background)
                                    
                                    // 얼굴형
                                    NavigationStack {
                                        CustomizeView<FaceShape>(store: store)
                                    }
                                    .tag(Tab.shape)
    //
                                    // 표정
                                    NavigationStack {
                                        CustomizeView<Face>(store: store)
                                    }
                                    .tag(Tab.face)
                                }
                                .toolbar(.hidden, for: .tabBar)
                }
                .frame(maxHeight: .infinity) // TabView의 높이를 화면 전체로 설정
        }
        .background(Color.red) // 반투명한 배경
        .edgesIgnoringSafeArea(.all) // 안전 영역을 무시하여 전체 화면을 차지하도록 설정
    }
}



struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center) {
                Text(title)
                    .font(Font.customFont(Font.body2Regular))
                    .foregroundColor(isSelected ? Color.white : Color.decoSheetTabbar)
            }
            .padding(10) // 텍스트와 테두리 사이의 간격을 설정합니다.
            .background(
                RoundedRectangle(cornerRadius: 15) // 모서리 둥글기 설정
                    .fill(isSelected ? Color.decoSheetTabbarBack : Color.clear) // 배경색 설정
            )
        }
    }
}
