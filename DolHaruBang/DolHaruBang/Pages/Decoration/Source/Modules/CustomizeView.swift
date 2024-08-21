//
//  CustomizeView.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/22/24.
//
import SwiftUI
import ComposableArchitecture

struct CustomizeView<T: Customizable>: View where T.AllCases == [T] {
    
    let store: StoreOf<HomeFeature>
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: columns, spacing: 20) { // spacing을 늘려서 항목들 간의 간격을 조정합니다.
                ForEach(T.allCases, id: \.self) { item in
                    Button(action: {
                        item.performAction(with: store)
                    }) {
                        VStack(spacing: 15) { // spacing을 조정하여 이미지와 텍스트 간의 간격을 조정합니다.
                            Image("background")
                                .resizable()
                                .scaledToFill()
                                .frame(width: 108, height: 108)
                                .clipped()
                                .clipShape(RoundedRectangle(cornerRadius: 15))
                            
                            Text("\(item.description)")
                                .font(Font.customFont(Font.caption1))
                                .foregroundColor(Color.decoSheetTextColor)
                                .padding(.bottom, 5) // 텍스트와 버튼 하단의 여백 조정
                        }
                        .frame(width: 120, height: 130) // 버튼의 전체 크기를 조정하여 겹침 방지
                        .padding(5) // 버튼의 패딩을 추가하여 여백 확보
                    }
                    
                }
            }
            .padding(.horizontal, 20) // ScrollView의 좌우 여백 조정
        }.frame(height: 300).background(Color.white)
    }
}
