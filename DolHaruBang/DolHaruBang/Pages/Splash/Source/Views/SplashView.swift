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
            LinearGradient(
                stops: [
                    .init(color: Color(hex: "BEE1F5"), location: 0),
                    .init(color: Color(hex: "BEE1F5"), location: 0.21),
                    .init(color: Color(hex: "86CAF0"), location: 1),
//                    .init(color: Color(hex: "72bde5"), location: 1),
//                        .init(color: Color(hex: "86CAF0"), location: 0.21),
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()
                
                VStack {
                    ZStack {
                        //                    Ellipse()
                        //                      .foregroundColor(Color(hex: "E2F2FA"))
                        ////                        .foregroundColor(Color.red)
                        //                        .frame(width: 150, height: 20)
                        ////                      .background(Color(hex: "E2F2FA"))
                        //                        .blur(radius: 20)
                        //                        .offset(y: 72)
                        //                        .blendMode(.multiply)
                        Image("Logo")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 160, height: 160) // 이미지 크기 조절
                            .background(
                                Ellipse()
                                    .foregroundColor(Color(hex: "E2F2FA"))
//                                    .foregroundColor(Color.red)
                                    .frame(width: 150, height: 20)
                                //                      .background(Color(hex: "E2F2FA"))
                                    .blur(radius: 20)
                                    .offset(y: 72)
                                    .blendMode(.multiply)
                            )
                    }
                    
                    //                Spacer().frame(height: UIScreen.main.bounds.height * 32 / 893)
                    Spacer().frame(height: 28)
                    
                    Text("돌과 함께 하루를 보내는 방")
                        .font(.customFont(Font.body1Bold))
                        .foregroundColor(.mainWhite)
                    
                    Spacer().frame(height: 18)
                    
                    Image("DolHaruBangText")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 216, height: 52)
                    
                    //                StrokeText(text: "돌하루방", width: 2, color: Color(hex: "837C74").opacity(0.4))
                    //                    .font(.customFont(Font.h2))
                    //                    .foregroundColor(.mainWhite)
                    
                    //                Text("돌하루방")
                    //                    .font(.customFont(Font.h2))
                    //                    .foregroundColor(.mainWhite)
                    //                    .shadow(color: Color(hex: "837C74").opacity(0.4), radius: 0.6)
                    //                    .padding(.top, 4)
                }

                Spacer().frame(height: 25)
                Spacer()
            }
        }
    }
}
