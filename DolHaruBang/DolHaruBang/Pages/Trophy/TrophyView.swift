//
//  TrophyView.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/21/24.
//

import SwiftUI
import ComposableArchitecture

struct TrophyView : View {
    @State var store : StoreOf<TrophyFeature>
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body : some View {
        GeometryReader { geometry in
            ZStack {
                // 배경이미지 설정
                // 추후 통신을 통해 받아오면 됨
                
                // 배경 이미지
                Image(Background(rawValue: store.selectedBackground.rawValue)!.fileName)
                    .resizable()
                    .scaledToFill()
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing:0){
                    
                    HStack{
                        Text("업적")
                            .font(Font.custom("Cafe24 Ssurround", size: 26).weight(.bold))
                            .lineSpacing(41.60)
                            .foregroundColor(Color(red: 0.98, green: 0.98, blue: 0.97))
                            .padding(.bottom,15)
                        
                    }
                    .frame(height : geometry.size.height * 0.1)
                    .padding(.top , geometry.size.height * 0.07)
                    
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(0..<10) { index in
                                VStack(alignment: .center){
                                    ZStack{
                                        
                                            Image("silverTrophy")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 80, height: 75)
                                                .padding(.top, 15)
                                    }
                                        
                                    // 업적명, 업적 과제
                                        VStack(spacing: 12) {
                                            Text("작심삼십일")
                                                .font(Font.custom("NanumSquareRound", size: 16).weight(.bold))
                                                .lineSpacing(28.80)
                                                .foregroundColor(Color(red: 0.38, green: 0.52, blue: 0))
                                            
                                            Text("누적 30일 출석")
                                                .font(Font.custom("NanumSquareRound", size: 11))
                                                .lineSpacing(19.80)
                                                .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                                        }.padding(.bottom, 15)
                                        
                                    // 절취선
                                        Divider()
                                            .background(Color(red: 0.90, green: 0.87, blue: 0.84))
                                            .frame(height: 0.25)
                                        
                                    //  보상 표시
                                        HStack(spacing: 8) {
                                            Image("goldTrophy")
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 48, height: 48)
                                            
                                            Text("아이템 이름")
                                                .font(Font.custom("NanumSquareRound", size: 10).weight(.bold))
                                                .lineSpacing(18)
                                                .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                                        }.padding(.top,7)
                                    }
                                
                          .frame(width: geometry.size.width * 0.42, height: geometry.size.height * 0.37) // 두 개의 카드 너비 조정
                                .overlay(
                                        RoundedRectangle(cornerRadius: 15)
                                          .inset(by: 0.30)
                                          .stroke(
                                            Color(red: 0.90, green: 0.87, blue: 0.84).opacity(0.70), lineWidth: 0.30
                                          )
                                      )
                                .background(Color.white)
                                .cornerRadius(15)
                            }
                        }
                        // LazyVGrid 패딩
                        .padding(20) // 수평 패딩 추가
                        .padding(.top,10)
                    }
                    .frame(width: geometry.size.width ,height : geometry.size.height * 0.78)
                    .background(Color(red: 0.98, green: 0.98, blue: 0.97))
                    .cornerRadius(15) // 뭉툭한 테두리
                    
                    Spacer()
                    
                }
                
            } // ZStack
            .edgesIgnoringSafeArea(.all)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    HStack {
                        Button(action: {
                            store.send(.goBack)
                        }) {
                            Image("BackIcon")
                                .resizable()
                                .frame(width: 38, height: 38)
                        }
                    }
                    .offset(x: 8, y: 8)
                }
            }

        }
    }
}

           
