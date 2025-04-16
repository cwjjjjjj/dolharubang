//
//  TrophyListView.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/23/24.
//

import SwiftUI
import ComposableArchitecture

struct TrophyListView : View {
    @State var store : StoreOf<TrophyListFeature>
    var geometry : GeometryProxy
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    
    var body: some View {
        VStack{
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    if let trophys = store.state.trophys {
                        ForEach(Array(trophys.enumerated()), id: \.element.missionName) { index, trophy in
                            VStack(alignment: .center){
                                ZStack{
                                    if trophy.rewarded == true{
                                        Image("goldTrophy")
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 80, height: 75)
                                            .padding(.top, 15)
                                    }else{
                                    Image("silverTrophy")
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .frame(width: 80, height: 75)
                                        .padding(.top, 15)
                                    }
                                }
                                
                                // 업적명, 업적 과제
                                VStack(spacing: 12) {
                                    Text("\(trophy.missionName)")
                                        .font(Font.customFont(Font.body1Bold))
                                        .lineSpacing(28.80)
                                        .foregroundColor(Color(red: 0.38, green: 0.52, blue: 0))
                                    
                                    Text("\(trophy.missionDescription)")
                                        .font(Font.customFont(Font.body4Regular))
                                        .lineSpacing(19.80)
                                        .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                                }.padding(.bottom, 15)
                                
                                // 절취선
                                Divider()
                                    .background(Color(red: 0.90, green: 0.87, blue: 0.84))
                                    .frame(height: 0.25)
                                
                                //  보상 표시
                                HStack(spacing: 8) {
                                    
//                                    if let uiImage = UIImage(data: trophy.rewardImage) {
//                                        Image(uiImage: uiImage)
//                                            .resizable()
//                                            .aspectRatio(contentMode: .fit)
//                                            .frame(width: 48, height: 48)
//                                    } else {
//                                        Text("이미지 로드 실패")
//                                    }
                                    
                                    Text("\(trophy.rewardName)")  .font(Font.customFont(Font.body5Bold))
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
                    }else{
                        Text("로딩중")
                    }
                }
                // LazyVGrid 패딩
                .padding(20) // 수평 패딩 추가
                .padding(.top,10)
            }
        }
        .frame(width: geometry.size.width ,height : geometry.size.height * 0.83)
            .background(Color(red: 0.98, green: 0.98, blue: 0.97))
            .cornerRadius(15) // 뭉툭한 테두리
            .onAppear {
                store.send(.fetchTrophys)
            }
            
    }
}
