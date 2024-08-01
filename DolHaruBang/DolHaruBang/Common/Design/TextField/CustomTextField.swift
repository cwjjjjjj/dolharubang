import SwiftUI
import UIKit

struct CustomTextField: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField

        init(parent: CustomTextField) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            if let text = textField.text, text.count > 12 {
                textField.text = String(text.prefix(12))
            }
            parent.text = textField.text ?? ""
        }
    }

    @Binding var text: String
    var placeholder: String
    var placeholderColor: UIColor?
    var font: Font
    var textColor: UIColor?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        
        let customFont = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: defaultTextSize)

        textField.font = customFont
        textField.textColor = textColor ?? UIColor(Color.mainBlack)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(Color.mainGray)
        textField.textAlignment = .center

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        // placeholder 색상, 폰트, 정렬 변경
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: placeholderColor ?? UIColor(Color.mainBlack),
                .font: customFont,
                .paragraphStyle: paragraphStyle
            ]
        )

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        
        let customFont = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: defaultTextSize)

        uiView.font = customFont
        uiView.textColor = textColor ?? UIColor(Color.mainBlack)
        uiView.textAlignment = .center

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

        uiView.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: placeholderColor ?? UIColor(Color.mainBlack),
                .font: customFont,
                .paragraphStyle: paragraphStyle
            ]
        )
    }
}
