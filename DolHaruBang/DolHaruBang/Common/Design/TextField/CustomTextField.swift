import SwiftUI
import UIKit

struct CustomTextField: UIViewRepresentable {
    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: CustomTextField

        init(parent: CustomTextField) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            if let text = textField.text, text.count > parent.maxLength {
                textField.text = String(text.prefix(parent.maxLength))
            }
            parent.text = textField.text ?? ""
        }

        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            parent.onSubmit?()  // 엔터 키를 눌렀을 때의 동작
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            // 최소 글자 수 확인
            if parent.text.count < parent.minLength {
                parent.showAlert(
                    title: parent.alertTitle ?? "경고",
                    message: parent.alertMessage ?? "올바르지 않은 입력입니다.",
                    dismissButtonTitle: parent.dismissButtonTitle ?? "확인"
                )
            } else {
                parent.onEndEditing?()  // 텍스트 편집 종료 시 동작
            }
        }
    }

    @Binding var text: String
    var placeholder: String
    var placeholderColor: UIColor?
    var font: Font
    var textColor: UIColor?
    var minLength: Int = 1  // 최소 글자 수 기본값 1
    var maxLength: Int  // 최대 글자 수는 반드시 입력받음
    var alertTitle: String?
    var alertMessage: String?
    var dismissButtonTitle: String?
    var onSubmit: (() -> Void)?
    var onEndEditing: (() -> Void)?

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator

        let customFont = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: 16)
        textField.font = customFont
        textField.textColor = textColor ?? UIColor(Color.mainBlack)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(Color.mainGray)
        textField.textAlignment = .center

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center

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

        let customFont = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: 16)
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

    func showAlert(title: String, message: String, dismissButtonTitle: String) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }

        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: dismissButtonTitle, style: .default, handler: nil))

        rootViewController.present(alert, animated: true, completion: nil)
    }
}
