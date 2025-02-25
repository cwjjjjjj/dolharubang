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
    @State private var showPurchaseAlert = false
    
    // 타입별로 다른 변수 받아오는 로직 구현
    private var items: [CustomizeItem] {
           switch T.self {
           case is Background.Type:
               return store.backItems
           case is Face.Type:
               return store.faceItems
           case is FaceShape.Type:
               return store.faceShapeItems
           case is Nest.Type:
               return store.nestItems
           case is Accessory.Type:
               return store.accessoryItems
           default:
               return []
           }
       }
      
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
                            let matchedItem = items.first { $0.name == item.description }
                                                       
                            
                            Button(action: {
                                // if문 추가 1
                                if matchedItem?.isOwned == false {
                                    showPurchaseAlert = true
                                } else {
                                    // 기존 동작
                                    selectedItem = item
                                    item.performAction(with: store)
                                }
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
                            // 추가2
                            .alert("구매 확인", isPresented: $showPurchaseAlert) {
                                Button("취소", role: .cancel) {
                                    print("취소 버튼 클릭: showPurchaseAlert = \(showPurchaseAlert)")  // 상태 확인
                                  
                                }
                                Button("구매", role: .none) {
//                                    // 여기에 구매 로직 추가
                                    // 현재 너무 복잡한 타입검사가 들어간다고 실행불가
//                                    if let id = matchedItem?.itemId {
//                                        store.send(.purchaseItem(id, type: T))
//                                    }
//                                    if let itemId = matchedItem?.itemId {
//                                        store.send(.purchaseItem(itemId, type: T.self))
//                                    }
                                }
                            } message: {
                                if let price = matchedItem?.price {
                                    Text("\(price) Sand를 사용하여 구매하시겠습니까?")
                                } else {
                                    Text("네트워크 오류")
                                }
                            }
                            // 추가끝2
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
//        .onAppear {
//            switch T.self {
//                        case is Background.Type:
//                            store.send(.fetchBackground)
//                            // Background 타입에 대한 처리
//                        case is Face.Type:
//                            store.send(.fetchFace)
//                        case is FaceShape.Type:
//                            store.send(.fetchFaceShape)
//                        default:
//                            print("Unknown type")
//                        }
//        }
    }
}
