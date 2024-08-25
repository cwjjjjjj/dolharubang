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
    
    @State private var selectedItem : T?
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                ScrollView(.horizontal) {
                    LazyHGrid(rows: columns, spacing: 14) {
                        ForEach(T.allCases, id: \.self) { item in
                            Button(action: {
                                selectedItem = item
                                item.performAction(with: store)
                            }) {
                                VStack(spacing: 4) {
                                    Image("plz")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 108, height: 108)
                                        .clipped()
                                        .clipShape(RoundedRectangle(cornerRadius: 15))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 15)
                                                .stroke(selectedItem == item ? Color.decoSheetGreen : Color.clear, lineWidth: 1)
                                        )
                                    
                                    Text("\(item.description)")
                                        .font(Font.customFont(Font.caption1))
                                        .foregroundColor(Color.decoSheetTextColor)
                                        .padding(.bottom, 5)
                                }
                                .frame(width: 108, height: 140)
                            }
                        }
                    }
                    .padding(.leading, 20)
                }
                .frame(height: geometry.size.height) // ScrollView의 높이를 GeometryReader의 높이로 설정
                .background(Color.white)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // VStack의 최대 크기를 무한대로 설정
            .padding(.bottom, 30) 
        }
    }
}
