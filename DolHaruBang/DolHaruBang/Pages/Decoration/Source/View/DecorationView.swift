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
    @State private var selected: Tab = .shape
    let store: StoreOf<HomeFeature>
    
    var body: some View {
        ZStack {
            
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
            
            VStack {
                    tabBar
                    Spacer()
                    }
           
           
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white) // 반투명한 배경
    }
    
    
    var tabBar: some View {
        HStack {
            Spacer()
            
            Button {
                selected = .shape
            } label: {
                VStack(alignment: .center) {
                        Text("얼굴형")
                            .font(.system(size: 11))
                }
            }
            .foregroundStyle(selected == .shape ? Color.black : Color.white)
            
            Spacer()
            
            Button {
                selected = .face
            } label: {
                VStack(alignment: .center) {
                        Text("얼굴")
                            .font(.system(size: 11))
                }
            }
            .foregroundStyle(selected == .face ? Color.black : Color.white)
            
            Spacer()
            
            Button {
                selected = .background
            } label: {
                VStack(alignment: .center) {
                        Text("배경")
                            .font(.system(size: 11))
                }
            }
            .foregroundStyle(selected == .background ? Color.black : Color.white)
            
            Spacer()
        }
        .padding()
        .frame(height: 40)
        // 탭바 디자인
        .background {
            RoundedRectangle(cornerRadius: 24)
                .fill(Color.gray)
                .shadow(color: .black.opacity(0.15), radius: 8, y: 2)
        }
        .padding(.horizontal)
    }
    
   
    
}




    
