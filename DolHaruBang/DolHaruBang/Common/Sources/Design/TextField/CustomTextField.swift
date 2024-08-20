import SwiftUI
import UIKit

enum Align {
    case leading
    case trailing
    case center
    
    var uiTextAlignment: NSTextAlignment {
        switch self {
        case .leading:
            return .left
        case .trailing:
            return .right
        case .center:
            return .center
        }
    }
}

struct CustomTextField: UIViewRepresentable {
    
    
    @Binding var text: String
    var placeholder: String
    var placeholderColor: UIColor?
    var font: Font?
    var textColor: UIColor?
    var minLength: Int = 1  // 최소 글자 수 기본값 1
    var maxLength: Int  // 최대 글자 수는 반드시 입력받음
    var alertTitle: String?
    var alertMessage: String?
    var dismissButtonTitle: String?
    var onSubmit: (() -> Void)?
    var onEndEditing: (() -> Void)?
    // 홈에서도 쓰려고 추가함
    var useDidEndEditing : Bool = true
    // 폰트 스타일를 위해
    var customFontStyle : Font.FontStyle?
    var alignment : Align = .center
    var leftPadding : CGFloat = 0
    
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
        
        // 닉네임 확인 메서드
        func textFieldDidEndEditing(_ textField: UITextField) {
            if parent.useDidEndEditing {
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
    }
    

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        
        let customFont : UIFont
        if let style = customFontStyle {
            customFont = Font.uiFont(for: style) ?? UIFont.systemFont(ofSize: style.size)
        }else{
            customFont = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: 16)
        }
       
        textField.font = customFont
        textField.textColor = textColor ?? UIColor(Color.mainBlack)
        textField.borderStyle = .roundedRect
        textField.backgroundColor = UIColor(Color.mainGray)
        textField.textAlignment = alignment.uiTextAlignment
        textField.addPadding(left: leftPadding)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment.uiTextAlignment

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

        let customFont : UIFont
        if let style = customFontStyle {
            customFont = Font.uiFont(for: style) ?? UIFont.systemFont(ofSize: style.size)
        }else{
            customFont = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: 16)
        }
        uiView.font = customFont
        uiView.textColor = textColor ?? UIColor(Color.mainBlack)
        uiView.textAlignment = alignment.uiTextAlignment

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment.uiTextAlignment

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
