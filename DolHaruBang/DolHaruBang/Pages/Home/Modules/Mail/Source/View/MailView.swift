//
//  MailView.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/25/24.
//

import ComposableArchitecture
import SwiftUI

struct MailView: View {
    @Binding var showPopup: Bool // 팝업 표시 여부
    let geometry : GeometryProxy
    
    @State var store: StoreOf<MailFeature> // Store로 상태 및 액션 전달
    
    var body: some View {
        if let mail = store.state.selectMail{
            VStack(alignment: .center){
                    Spacer().frame(height: 24)
                HStack{
                    Spacer()
                    Button(action: {
                        store.send(.closeMail)
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.placeHolder)
                    }
                    .padding(.trailing, 24)
                }
                Image(getSelectImageName(for: mail.type))
                    .resizable()
                    .scaledToFit()
                    .frame(width: UIDevice.isPad ? geometry.size.width * 0.4 : geometry.size.width * 0.7)
                HStack{
                    (
                        Text(mail.nickname ?? "").foregroundColor(Color.init(hex: "618501"))
                        +
                        Text("\(mail.content)".splitCharacter())
                            .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                    )
                    .font(Font.customFont(Font.body2Bold))
                    .frame(width: UIDevice.isPad ? 444 :222, alignment: .leading)
                    .lineSpacing(5)
                    .lineLimit(2)
                    .multilineTextAlignment(.leading)
                    .padding(.vertical, 8) // 세로 여백 추가
                }
                .frame(height : UIDevice.isPad ? 100 : 48)
                
                Spacer()
            }
            .background(Color.white)
            .cornerRadius(25)
            .shadow(radius: 10).opacity(store.clickMail ? 1 : 0)
        }
        else{
            
            VStack(alignment: .center) {
                Spacer().frame(height: 24)
                
                HStack(spacing: 6) {
                    Text("우편함")
                        .font(Font.customFont(Font.subtitle3))
                        .foregroundColor(.decoSheetGreen)
                        .padding(.leading, 24)
                    
                    Text("최근 7일동안 받은 우편")
                        .font(Font.customFont(Font.body5Regular))
                        .lineSpacing(13)
                        .foregroundColor(Color(red: 0.65, green: 0.61, blue: 0.57));
                    
                    Spacer()
                    
                    Button(action: {
                        showPopup = false
                    }) {
                        Image(systemName: "xmark")
                            .resizable()
                            .frame(width: 14, height: 14)
                            .foregroundColor(.placeHolder)
                    }
                    .padding(.trailing, 24)
                }
                
                Spacer().frame(height: 20)
                
                Divider().background(Color(hex: "E5DFD7"))
                
                ScrollView(.vertical){
                    if let mails = store.state.mails {
                            ForEach(Array(mails.enumerated()), id:\.element.id){ index,mail in
                                HStack(spacing:10) {
                                    VStack{
                                        Image(getImageName(for: mail.isRead ? "readMail" : mail.type))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 26)
                                            .padding(.top, 8)
                                        
                                        Text(formatRelativeTime(from:mail.createdAt))
                                            .font(Font.customFont(Font.body6Bold))
                                            .lineSpacing(10.40)
                                            .foregroundColor(Color(red: 0.65, green: 0.61, blue: 0.57))
                                            .padding(.top, mail.isRead ? 2 : 1) // 조건에 따라 padding 변경
                                        
                                    }
                                    
                                    //body2Bold
                                    Button(action: {
                                        store.send(.selectMail(mail))
                                    }){
                                        HStack{
                                            (
                                                Text(mail.nickname ?? "").foregroundColor(Color.init(hex: "618501"))
                                                
                                                +
                                                
                                                Text("\(mail.content)".splitCharacter())
                                                    .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                                            )
                                            .font(Font.customFont(Font.body2Bold))
                                            .frame(
                                                width: UIDevice.isPad ? 444 : 222,
                                                height: UIDevice.isPad ? 96 : 48,
                                                alignment: .leading
                                            )
                                            .lineSpacing(5)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                            .padding(.vertical, 8) // 세로 여백 추가
                                            
                                        }}
                                    
                                }
                                .frame(
                                    width: UIDevice.isPad ? 544 : 272,
                                    height: UIDevice.isPad ? 96 : 48
                                ).padding(.bottom,10)
                            }
                    }
                }.padding(10)
                
            }
            .background(Color.white)
            .cornerRadius(25)
            .shadow(radius: 10)
            .onAppear{
                store.send(.fetchMail)
                store.send(.fetchUnRead)
            }
        }
    }
        
}
