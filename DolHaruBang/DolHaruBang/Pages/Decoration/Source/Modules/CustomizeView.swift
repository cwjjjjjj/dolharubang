//
//  CustomizeView.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/22/24.
//

import SwiftUI
import ComposableArchitecture

struct CustomizeView<T : Customizable> : View where T.AllCases == [T]{
    
    let store: StoreOf<HomeFeature>
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView(.horizontal) {
            LazyHGrid(rows: columns, spacing: 10) {
                ForEach(T.allCases, id: \.self) { item in
                    Button(action: {
                        item.performAction(with: store)
                        
                    }) {
                        VStack{
                            Text("이미지가 들어갈 곳")
                            Spacer()
                            Text("\(item.description)")
                        }
                    }
                    .frame(width: 100, height: 100)
                }
            }
            .padding()
        }
    }
}
