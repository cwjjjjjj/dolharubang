//
//  MailView.swift
//  DolHaruBang
//
//  Created by 양희태 on 9/25/24.
//

import ComposableArchitecture
import SwiftUI

struct MailView: View {
    // 팝업 표시 여부
    @Binding var showPopup: Bool
    
    let geometry : GeometryProxy
    
    @State var store: StoreOf<MailFeature>
    
    var body: some View {
        Group {
            if let mail = store.state.selectMail {
                selectedMailView(mail: mail)
            } else {
                mailListView
            }
        }
    }
    
    // MARK: 선택된 메일 뷰
    private func selectedMailView(mail: MailInfo) -> some View {
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
                mailContentText(mail: mail)
            }
            .frame(height : UIDevice.isPad ? 100 : 48)
            
            Spacer()
        }
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 10)
        .opacity(store.clickMail ? 1 : 0)
    }
    
    // MARK: 메일 내용 텍스트
    private func mailContentText(mail: MailInfo) -> some View {
        let nicknameText = Text(mail.nickname ?? "")
            .foregroundColor(Color.init(hex: "618501"))
        
        let contentText = Text("\(mail.content)".splitCharacter())
            .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
        
        return (nicknameText + contentText)
            .font(Font.customFont(Font.body2Bold))
            .frame(width: UIDevice.isPad ? 444 :222, alignment: .leading)
            .lineSpacing(5)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .padding(.vertical, 8)
    }
    
    // MARK: 메일 리스트 뷰 (헤더 + 스크롤 뷰)
    private var mailListView: some View {
        VStack(alignment: .center) {
            Spacer().frame(height: 24)
            
            mailListHeader
            
            Spacer().frame(height: 20)
            
            Divider().background(Color(hex: "E5DFD7"))
            
            mailScrollView
        }
        .background(Color.white)
        .cornerRadius(25)
        .shadow(radius: 10)
        .onAppear{
            store.send(.fetchMail)
            store.send(.fetchUnRead)
        }
    }
    
    // MARK: 헤더 부분
    private var mailListHeader: some View {
        HStack(spacing: 6) {
            Text("우편함")
                .font(Font.customFont(Font.subtitle3))
                .foregroundColor(.decoSheetGreen)
                .padding(.leading, 24)
            
            Text("최근 7일동안 받은 우편")
                .font(Font.customFont(Font.body5Regular))
                .lineSpacing(13)
                .foregroundColor(Color(red: 0.65, green: 0.61, blue: 0.57))
            
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
    }
    
    // MARK: 메일 스크롤 뷰
    private var mailScrollView: some View {
        ScrollView(.vertical){
            LazyVStack {
                
                if store.state.isRefreshing {
                    HStack {
                        Spacer()
                        CustomCircularProgress()
                        Spacer()
                    }
                    .padding()
                }

                if let mails = store.state.mails {
                    ForEach(Array(mails.enumerated()), id:\.element.id){ index, mail in
                        mailRowView(index: index, mail: mail)
                    }
                }
                
                if store.state.isLoading && !store.state.isRefreshing {
                    CustomCircularProgress()
                        .padding()
                }
                
            }
        }
        .simultaneousGesture(
            DragGesture()
                .onChanged { value in
                    // CGSize의 height 프로퍼티 사용
                    if value.translation.height > 50 && !store.state.isRefreshing {
                        store.send(.refreshMail)
                    }
                }
        )
        .padding(10)
    }
    
    // MARK: 개별 메일 행 뷰
    private func mailRowView(index: Int, mail: MailInfo) -> some View {
        HStack(spacing:10) {
            mailImageView(mail: mail)
            mailContentButton(mail: mail)
        }
        .frame(
            width: UIDevice.isPad ? 544 : 272,
            height: UIDevice.isPad ? 96 : 48
        )
        .padding(.bottom,10)
        .onAppear {
            if let mails = store.state.mails,
               index == mails.count - 3 && store.state.hasMorePages && !store.state.isLoading {
                store.send(.fetchMoreMail)
            }
        }
    }
    
    // MARK: 메일 이미지 뷰
    private func mailImageView(mail: MailInfo) -> some View {
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
                .padding(.top, mail.isRead ? 2 : 1)
        }
    }
    
    // MARK: 메일 내용 버튼
    private func mailContentButton(mail: MailInfo) -> some View {
        Button(action: {
            store.send(.selectMail(mail))
        }){
            HStack{
                mailButtonText(mail: mail)
            }
        }
    }
    
    // MARK: 버튼 내부 텍스트
    private func mailButtonText(mail: MailInfo) -> some View {
        let nicknameText = Text(mail.nickname ?? "")
            .foregroundColor(Color.init(hex: "618501"))
        
        let contentText = Text("\(mail.content)".splitCharacter())
            .foregroundColor(Color(red: 0.51, green: 0.49, blue: 0.45))
        
        return (nicknameText + contentText)
            .font(Font.customFont(Font.body2Bold))
            .frame(
                width: UIDevice.isPad ? 444 : 222,
                height: UIDevice.isPad ? 96 : 48,
                alignment: .leading
            )
            .lineSpacing(5)
            .lineLimit(2)
            .multilineTextAlignment(.leading)
            .padding(.vertical, 8)
    }
}

// MARK: 커스텀 로딩 뷰
struct CustomCircularProgress: View {
    @State private var rotation: Double = 0
    @State private var startAngle: Double = 0
    @State private var endAngle: Double = 0
    @State private var isAnimating = false
    
    var body: some View {
        ZStack {
            // 배경 원
            Circle()
                .stroke(
                    Color.coreDisabled.opacity(0.2),
                    style: StrokeStyle(lineWidth: 3)
                )
            
            // 진행 원
            Circle()
                .trim(from: CGFloat(startAngle), to: CGFloat(endAngle))
                .stroke(
                    Color.coreGreen,
                    style: StrokeStyle(lineWidth: 3, lineCap: .round)
                )
                .rotationEffect(.degrees(rotation + 270))
        }
        .frame(width: 24, height: 24)
        .onAppear {
            startAnimations()
        }
        .onDisappear {
            isAnimating = false
        }
    }
    
    private func startAnimations() {
        guard !isAnimating else { return }
        isAnimating = true
        
        // 회전 애니메이션 시작
        withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
            rotation = 360
        }
        
        // 확장/축소 애니메이션 시작
        animateProgress()
    }
    
    private func animateProgress() {
        guard isAnimating else { return }
        
        // 초기화
        startAngle = 0
        endAngle = 0
        
        // 확장 (더 빠르게)
        withAnimation(.easeInOut(duration: 0.4)) {
            endAngle = 0.8
        }
        
        // 확장 완료 후 0.2초 유지
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            guard self.isAnimating else { return }
            
            // 축소
            withAnimation(.easeInOut(duration: 0.4)) {
                self.startAngle = self.endAngle
            }
        }
        
        // 사이클 반복
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            guard self.isAnimating else { return }
            self.animateProgress()
        }
    }
    
//    private func animateProgress() {
//        guard isAnimating else { return }
//        
//        // 초기화: 시작점과 끝점을 같게 만들어서 보이지 않게 함
//        startAngle = 0
//        endAngle = 0
//        
//        // 확장: 끝점만 늘어남
//        withAnimation(.easeInOut(duration: 1.0)) {
//            endAngle = 0.8
//        }
//        
//        // 확장 완료 후 0.5초 유지
//        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
//            guard self.isAnimating else { return }
//            
//            // 축소: 시작점을 늘려서 줄어드는 효과 (더 큰 차이로 설정)
//            withAnimation(.easeInOut(duration: 0.8)) {
//                self.startAngle = 0.7  // 0.8 - 0.7 = 0.1만 남게 됨
//            }
//        }
//        
//        // 사이클 반복
//        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
//            guard self.isAnimating else { return }
//            self.animateProgress()
//        }
//    }

}


