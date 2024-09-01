import SwiftUI
import UIKit

struct CustomText: UIViewRepresentable {
    var text: String
    var font: UIFont
    var textColor: UIColor
    var letterSpacingPercentage: CGFloat = -2.5 // 자간 비율 기본값 -2.5%
    var lineSpacingPercentage: CGFloat = 160 // 행간 비율 기본값 160%
    var textAlign: NSTextAlignment = .center // 기본값으로 중앙 정렬

    func makeUIView(context: Context) -> UILabel {
        let label = UILabel()
        label.numberOfLines = 0 // 여러 줄 지원
        label.textAlignment = textAlign

        // 자간과 행간 설정
        let attributedString = createAttributedString()
        label.attributedText = attributedString
        label.font = font
        label.textColor = textColor

        return label
    }

    func updateUIView(_ uiView: UILabel, context: Context) {
        // 자간과 행간 설정
        let attributedString = createAttributedString()
        uiView.attributedText = attributedString
        uiView.font = font
        uiView.textColor = textColor
        uiView.textAlignment = textAlign
    }

    // 자간 및 행간 설정을 위한 메서드 from UIKit
    private func createAttributedString() -> NSMutableAttributedString {
        let attributedString = NSMutableAttributedString(string: text)

        // 자간 값 계산 (글꼴 크기의 비율)
        let letterSpacing = font.pointSize * (letterSpacingPercentage / 100)
        
        // 행간 값 계산 (기본 라인 높이에 대한 비율)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineHeightMultiple = lineSpacingPercentage / 100
        paragraphStyle.alignment = textAlign

        // 자간과 행간 적용
        attributedString.addAttribute(.kern, value: letterSpacing, range: NSRange(location: 0, length: attributedString.length))
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: NSRange(location: 0, length: attributedString.length))
        
        return attributedString
    }
}
