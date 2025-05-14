//
//  SandView.swift
//  DolHaruBang
//
//  Created by 양희태 on 4/29/25.
//
import SwiftUI
import ComposableArchitecture

struct SandView: View {
    @State var store: StoreOf<HomeFeature>
    
    var body: some View {
        VStack(alignment:.leading,spacing:0 ){
            HStack{
                Text("모래알 수집")
                    .font(Font.customFont(Font.body1Bold))
                    .foregroundColor(Color(red: 0.38, green: 0.52, blue: 0))
                Spacer()
                Button(action: {
                    store.send(.closeSand)
                }) {
                    Image(systemName: "xmark")
                        .resizable()
                        .frame(width: 14, height: 14)
                        .foregroundColor(.placeHolder)
                }
            }
            .padding(.horizontal,20)
            .padding(.top,20)
            
            HStack(spacing:1){
                Text("하루 수집 가능한 모래알 :")
                    .font(Font.customFont(Font.body4Bold))
                    .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
                Text("50개")
                    .font(Font.customFont(Font.body4Bold))
                    .foregroundColor(Color(red: 0.78, green: 0.56, blue: 0.31))
            }
            .padding(.horizontal,20)
            .padding(.bottom,10)
            
            Rectangle()
                .foregroundColor(.clear)
                .frame(maxWidth: .infinity, maxHeight: 1)
                .overlay(
                    Rectangle()
                        .stroke(Color(red: 0.90, green: 0.87, blue: 0.84), lineWidth: 0.40)
                )
            VStack{
                SandRow(title: "출석하기", count: "10개")
                SandRow(title: "하루방 일기 쓰기", count: "10개")
                SandRow(title: "클로버 보내기", count: "4개")
                SandRow(title: "교감하기", count: "4개")
                SandRow(title: "돌과 대화하기", count: "4개")
            }.padding(20)
        }
        
    }
}





struct SandRow: View {
    let title: String
    let count: String
    
    var body: some View {
        HStack(spacing: 0) {
            Text(title)
                .font(Font.customFont(Font.body3Bold))
                .lineLimit(1)
                .foregroundColor(Color(red: 0.22, green: 0.16, blue: 0.10))
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(
                            key: WidthPreferenceKey.self,
                            value: geo.size.width
                        )
                    }
                )
            
            // 동적 Divider
            Rectangle()
                .fill(Color(red: 0.90, green: 0.87, blue: 0.84))
                .frame(height: 0.4)
                .padding(.horizontal, 8)
                .layoutPriority(-1)
            
            Text(count)
                .font(Font.customFont(Font.body3Bold))
                .lineLimit(1)
                .foregroundColor(Color(red: 0.78, green: 0.56, blue: 0.31))
        }
        .frame(maxWidth: .infinity)
        .onPreferenceChange(WidthPreferenceKey.self) { widths in
//            print("디버깅: 텍스트 너비 - \(widths)")
        }
    }
}

struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
