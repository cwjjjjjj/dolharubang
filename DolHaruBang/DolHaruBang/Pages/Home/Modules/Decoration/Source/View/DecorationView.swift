//
//  DecorationView.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/20/24.
//

import SwiftUI
import ComposableArchitecture

struct DecorationView: View {
    enum Tab {
        case background, shape, face, accessory/*, mail, sign*/, nest
    }
    
    @State private var selected: Tab = .background
    let store: StoreOf<DecoFeature>
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing : 0) {
                // 스크롤 가능한 탭 버튼들
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        TabButton(
                            title: "배경",
                            isSelected: selected == .background,
                            action: { selected = .background }
                        )
                        
//                        TabButton(
//                            title: "얼굴형",
//                            isSelected: selected == .shape,
//                            action: { selected = .shape }
//                        )
                        
                        TabButton(
                            title: "얼굴",
                            isSelected: selected == .face,
                            action: { selected = .face }
                        )
                        
                        TabButton(
                            title: "악세서리",
                            isSelected: selected == .accessory,
                            action: { selected = .accessory }
                        )
                        
                        // 테스트용
//                        TabButton(
//                            title: "펫말",
//                            isSelected: selected == .sign,
//                            action: { selected = .sign }
//                        )
//                        
//                        TabButton(
//                            title: "우체통",
//                            isSelected: selected == .mail,
//                            action: { selected = .mail }
//                        )
                        
                        TabButton(
                            title: "돌그릇",
                            isSelected: selected == .nest,
                            action: { selected = .nest }
                        )
                    }
                    .padding(.horizontal, 20)
                }
                .padding(.top, 60)
                .padding(.top, 26)
                .padding(.bottom, 12)
                .background(Color.white) // 버튼 영역의 배경색
                
                TabView(selection: $selected) {
                    Group {
                        NavigationStack {
                            CustomizeView<Background>(store: store)
                        }
                        .tag(Tab.background)
                        
                        NavigationStack {
                            CustomizeView<FaceShape>(store: store)
                        }
                        .tag(Tab.shape)
                        
                        NavigationStack {
                            CustomizeView<Face>(store: store)
                        }
                        .tag(Tab.face)
                        
                        NavigationStack {
                            CustomizeView<Accessory>(store: store)
                        }
                        .tag(Tab.accessory)
                        
//                        NavigationStack {
//                            CustomizeView<Sign>(store: store)
//                        }
//                        .tag(Tab.sign)
//                        
//                        NavigationStack {
//                            CustomizeView<Mail>(store: store)
//                        }
//                        .tag(Tab.mail)
//                        
                        NavigationStack {
                            CustomizeView<Nest>(store: store)
                        }
                        .tag(Tab.nest)
                    }
                }
                .background(Color.white) // TabView의 배경색
                .frame(width: geometry.size.width, height: geometry.size.height) // TabView의 크기를 GeometryReader를 사용하여 조정
            }
            .frame(width: geometry.size.width, height: geometry.size.height)// 전체 레이아웃 크기 설정
            .background(Color.white)
        }
    }
}

struct TabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(Font.customFont(Font.body2Regular))
                .foregroundColor(isSelected ? Color.white : Color.decoSheetTabbar)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isSelected ? Color.decoSheetGreen : Color.clear)
                )
        }
    }
}
