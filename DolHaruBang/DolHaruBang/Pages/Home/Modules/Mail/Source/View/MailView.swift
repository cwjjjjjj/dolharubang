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
    
    @State var store: StoreOf<MailFeature> // Store로 상태 및 액션 전달
    
    var body: some View {
        ZStack{
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
                        ZStack{
                            ForEach(Array(mails.enumerated()), id:\.element.id){ index,mail in
                                HStack(spacing:10) {
                                    VStack{
                                        Image(getImageName(for: mail.type))
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 40, height: 26)
                                            .padding(.top, 8)
                                        
                                        Text("\(mail.content)")
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
                                            .frame(width: 222, height : 48, alignment: .leading)
                                            .lineSpacing(5)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.leading)
                                            .padding(.vertical, 8) // 세로 여백 추가
                                            
                                        }}
                                    
                                }.frame(width: 272, height: 48).padding(.bottom,10)
                            }
                            
                        }
                        
                    }
                }.frame(height: 304).padding(10)
                
                //
                
            }
            .frame(width: 320, height : 400)
            .background(Color.white)
            .cornerRadius(25)
            .shadow(radius: 10)
            if let mail = store.state.selectMail{
                VStack(alignment: .center){
                        HStack{
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
                        Image("clover")
                            .resizable()
                            .scaledToFill()
                        HStack{
                            (
                                Text(mail.nickname ?? "").foregroundColor(Color.init(hex: "618501"))
                                
                                +
                                
                                Text("\(mail.content)".splitCharacter())
                                    .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                            )
                            .font(Font.customFont(Font.body2Bold))
                            .frame(width: 222, height : 48, alignment: .leading)
                            .lineSpacing(5)
                            .lineLimit(2)
                            .multilineTextAlignment(.leading)
                            .padding(.vertical, 8) // 세로 여백 추가
                            
                        }
                    }
                .frame(width: 320, height : 400)
                .background(Color.white)
                .cornerRadius(25)
                .shadow(radius: 10).opacity(store.clickMail ? 1 : 0)
            }
        }
        .onAppear{
            store.send(.fetchMail)
            store.send(.fetchUnRead)
        }
    }
}
