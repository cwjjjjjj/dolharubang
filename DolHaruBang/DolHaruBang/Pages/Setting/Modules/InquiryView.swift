//
//  InquiryView.swift
//  DolHaruBang
//
//  Created by 양희태 on 4/29/25.
//

import SwiftUI

// 문의하기 버튼
struct InquiryView: View {
    @Environment(\.openURL) private var openURL

    var body: some View {
        Button("문의하기") {
            sendInquiryMail()
        }
        .font(Font.customFont(Font.body1Regular))
        .foregroundColor(Color.decoSheetTextColor)
    }

    func sendInquiryMail() {
        let to = "smyang0220@gmail.com" // 받을 이메일 주소
        let subject = "돌하루방 문의사항"
        let body = """
        안녕하세요! \n앱을 사용하면서 불편하셨던점 \n개선바라는 점들 마음껏 적어 보내주세요!

        - 문의 내용:
        """

        // URL 인코딩(공백, 한글 등 특수문자 처리)
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "mailto:\(to)?subject=\(encodedSubject)&body=\(encodedBody)"

        if let url = URL(string: urlString) {
            openURL(url)
        }
    }
}
