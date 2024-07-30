//
//  SplashView.swift
//  DolHaruBang
//
//  Created by 안상준 on 7/29/24.
//

import SwiftUI

struct SplashView: View {
    var body: some View {
        ZStack {
            Color.mainGreen
                .edgesIgnoringSafeArea(.all) // 화면 전체를 배경색으로 채우기 위해

            VStack {
                Spacer()
                
                Image("Logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 130, height: 132.9) // 이미지 크기 조절

                Text("돌과 함께 하루를 보내는 방")
                    .font(.customFont(Font.body1Bold))
                    .foregroundColor(.mainWhite)
                    .padding(.top, 4)

                Text("돌하루방")
                    .font(.customFont(Font.h2))
                    .foregroundColor(.mainWhite)
                    .padding(.top, 4)

                Spacer()
                
                HStack {
                    Spacer() // 왼쪽에 Spacer 추가
                    Text("♬ HYP - Spring Has Come\n\n♬ BGM provided by HYP MUSIC\n\n♬ https://youtu.be/fhSzUbsd5cY")
                        .font(.customFont(Font.caption2))
                        .foregroundColor(.gray)
                        .opacity(0.7)
                        .multilineTextAlignment(.trailing)
                }
                .padding(.bottom, 20)
                .padding(.trailing, 20)
            }
        }
    }
}

