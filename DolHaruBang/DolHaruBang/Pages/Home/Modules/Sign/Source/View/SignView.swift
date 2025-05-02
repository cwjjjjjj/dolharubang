//
//  SignView.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/23/24.
//

import ComposableArchitecture
import SwiftUI

struct SignView: View {
    @Binding var showPopup: Bool // 팝업 표시 여부
    @Binding var initMessage : String
    
    @State var store: StoreOf<SignFeature> // Store로 상태 및 액션 전달

    var body: some View {
        VStack(alignment: .center) {
            Spacer().frame(height: 19)
            
            HStack {
                Text("팻말")
                    .font(Font.customFont(Font.subtitle3))
                    .foregroundColor(.decoSheetGreen)
                    .padding(.leading, 24)
                
                Spacer()
                    Button(action: { store.send(.applySign(store.signInfo))
                        initMessage = store.signInfo
                        showPopup = false
                       })
                    {
                            Text("등록")
                                .font(Font.customFont(Font.caption1))
                                .foregroundColor(.white)
                                .padding()// Text
                                .frame(height: 28)
                                .background(Color.commit).cornerRadius(20)
                    }
                
                
                Button(action: {
                    showPopup = false
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.placeHolder)
                }.onAppear {
                    // 저장된 설정값 확인 후 재생/정지
                    let isMusicOn = UserDefaults.standard.bool(forKey: "isBGMMusicOn")
                    if isMusicOn {
                        AudioManager.shared.playBackgroundMusic()
                    } else {
                        AudioManager.shared.stopBackgroundMusic()
                    }
                }

                .padding(.trailing, 24)
            }
            
            Spacer().frame(height: 15)
            
            Divider()
            HStack{
                SignTextView(text: $store.signInfo, placeholder: "팻말에 등록할 문구를 입력해주세요.(최대 50자)", maxTextWidth: UIScreen.main.bounds.width * 150/393)
                    .font(Font.customFont(Font.button35))
                    .background(.white)
                    .transparentScrolling()
                    .foregroundColor(.coreBlack)
                
            }.padding(.horizontal)
                

            
            
            Spacer()
        }
        .frame(width: 320, height: 170)
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 10)
        .onAppear{
            store.send(.fetchSign(initMessage))
            store.send(.fetchfistSign)
        }
        
    }
}
