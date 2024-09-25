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
                            let matchedItem = store.customizeInfo.first { $0.name == item.description }
                                                       
                            
                            Button(action: {
                                selectedItem = item
                                item.performAction(with: store)
                            }) {
                                VStack(spacing: 4) {
                                    ZStack(alignment: .topTrailing){
                                        
                                        Image("plz")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 108, height: 108)
                                            .clipped()
                                            .clipShape(RoundedRectangle(cornerRadius: 15))
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 15)
                                                    .stroke(matchedItem?.isSelected == true ? Color.decoSheetGreen : Color.clear, lineWidth: 1)
                                            )
                                            
                                        // 보유중인 경우 가격 미표시
                                            if matchedItem?.isOwned == false {
                                                HStack(spacing : 0){
                                                    Image("Sand")
                                                        .resizable()
                                                        .scaledToFit()
                                                        .frame(width: 10, height: 10)
                                                        .padding(.leading , 2)
                                                    Text("\(matchedItem?.price != nil ? "\(matchedItem!.price)" : "가격 없음")")
                                                        .font(Font.customFont(Font.caption1))
                                                        .lineSpacing(18)
                                                        .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                                                        .padding(4)
                                                   
                                                }.frame(width: 33, height: 16)
                                                    .background(Color(red: 0.98, green: 0.98, blue: 0.97))
                                                    .cornerRadius(10)
                                                    .padding(6)
                                            }
                                    }
                                   
                                    
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
        .onAppear {
            switch T.self {
                        case is Background.Type:
                            store.send(.fetchBackground)
                            // Background 타입에 대한 처리
                        case is Face.Type:
                            store.send(.fetchFace)
                        case is FaceShape.Type:
                            store.send(.fetchFaceShape)
                        default:
                            print("Unknown type")
                        }
        }// onAppear
    }
}
