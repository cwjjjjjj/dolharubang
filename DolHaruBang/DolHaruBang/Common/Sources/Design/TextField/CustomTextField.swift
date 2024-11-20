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
    var backgroundColor: UIColor? = .coreGray // backgroundColor 추가, 기본값 설정
    var minLength: Int = 1  // 최소 글자 수 기본값 1
    var maxLength: Int  // 최대 글자 수는 반드시 입력받음
    var alertTitle: String?
    var alertMessage: String?
    var dismissButtonTitle: String?
    var onSubmit: (() -> Void)?
    var onEndEditing: (() -> Void)?
    var useDidEndEditing: Bool = true
    var customFontStyle: Font.FontStyle?
    var alignment: Align = .center
    var leftPadding: CGFloat = 0
    var rightPadding: CGFloat = 0
    
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

//        func textFieldDidEndEditing(_ textField: UITextField) {
//            if parent.useDidEndEditing {
//                if parent.text.count < parent.minLength {
//                    parent.showAlert(
//                        title: parent.alertTitle ?? "경고",
//                        message: parent.alertMessage ?? "올바르지 않은 입력입니다.",
//                        dismissButtonTitle: parent.dismissButtonTitle ?? "확인"
//                    )
//                } else {
//                    parent.onEndEditing?()  // 텍스트 편집 종료 시 동작
//                }
//            }
//        }
        // 조건 추가해서 매개변수로 알림 관련 버튼 내용이 있을 때만 알림 표시하도록 함!
        func textFieldDidEndEditing(_ textField: UITextField) {
            if parent.useDidEndEditing {
                if parent.text.count < parent.minLength {
                    if let alertTitle = parent.alertTitle,
                       let alertMessage = parent.alertMessage,
                       let dismissButtonTitle = parent.dismissButtonTitle {
                        parent.showAlert(
                            title: alertTitle,
                            message: alertMessage,
                            dismissButtonTitle: dismissButtonTitle
                        )
                    }
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
        
        let customFont: UIFont
        if let style = customFontStyle {
            customFont = Font.uiFont(for: style) ?? UIFont.systemFont(ofSize: style.size)
        } else {
            customFont = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: 16)
        }

        textField.font = customFont
        textField.textColor = textColor ?? .coreBlack
        textField.borderStyle = .roundedRect
        textField.backgroundColor = backgroundColor ?? .coreGray // backgroundColor 설정
        textField.textAlignment = alignment.uiTextAlignment
        textField.addPadding(left: leftPadding, right: rightPadding)

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment.uiTextAlignment

        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: placeholderColor ?? .coreBlack,
                .font: customFont,
                .paragraphStyle: paragraphStyle
            ]
        )

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text

        let customFont: UIFont
        if let style = customFontStyle {
            customFont = Font.uiFont(for: style) ?? UIFont.systemFont(ofSize: style.size)
        } else {
            customFont = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: 16)
        }
        uiView.font = customFont
        uiView.textColor = textColor ?? .coreBlack
        uiView.backgroundColor = backgroundColor ?? .coreGray // backgroundColor 설정
        uiView.textAlignment = alignment.uiTextAlignment

        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment.uiTextAlignment

        uiView.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: placeholderColor ?? .coreBlack,
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


struct SimpleCustomTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var placeholderColor: UIColor?
    var textColor: UIColor?
    var font: UIFont?
    var maxLength: Int
    var onEditingChanged: ((Bool) -> Void)?

    class Coordinator: NSObject, UITextFieldDelegate {
        var parent: SimpleCustomTextField

        init(parent: SimpleCustomTextField) {
            self.parent = parent
        }

        func textFieldDidChangeSelection(_ textField: UITextField) {
            if let text = textField.text, text.count > parent.maxLength {
                textField.text = String(text.prefix(parent.maxLength))
            }
            parent.text = textField.text ?? ""
        }

        func textFieldDidBeginEditing(_ textField: UITextField) {
            parent.onEditingChanged?(true)
        }

        func textFieldDidEndEditing(_ textField: UITextField) {
            parent.onEditingChanged?(false)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UITextField {
        let textField = UITextField()
        textField.delegate = context.coordinator
        textField.text = text
        textField.placeholder = placeholder
        textField.textColor = textColor ?? .black
        textField.font = font ?? UIFont.systemFont(ofSize: 14)
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setContentHuggingPriority(.required, for: .vertical)
        textField.setContentCompressionResistancePriority(.required, for: .vertical)

        if let placeholderColor = placeholderColor {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
            )
        }

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        uiView.text = text
        uiView.font = font ?? UIFont.systemFont(ofSize: 14)
        uiView.textColor = textColor ?? .black

        if let placeholderColor = placeholderColor {
            uiView.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
            )
        }
    }
}

struct ResizableTextView: View {
    @Binding var text: String
    let font: UIFont = UIFont(name: Font.body3Regular.customFont.rawValue, size: Font.body3Regular.size) ?? UIFont.systemFont(ofSize: 12)

    // TextEditor 최대 너비
    var maxTextWidth: CGFloat
    
    // TextEditor 높이
    @State private var textHeight: CGFloat = 48
    
    var body: some View {
        TextEditor(text: $text)
            .frame(height: textHeight)
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 12, trailing: 16))
            .onAppear {
                calculateHeight()
            }
            .onChange(of: text) { _ in
                calculateHeight()
            }
    }

    private func calculateHeight() {
        let lineCount = autoLineCount(text: text, font: font, maxTextWidth: maxTextWidth - 40)
        let minH : CGFloat = font.lineHeight + 2
        let maxH : CGFloat = 120.0
        textHeight = min(max(minH, lineCount * (font.lineHeight+2)), maxH)
    }
    
    private func autoLineCount(text: String, font: UIFont, maxTextWidth: CGFloat) -> CGFloat {
        var lineCount: CGFloat = 0
        text.components(separatedBy: "\n").forEach { line in
            let label = UILabel()
            label.font = font
            label.text = line
            label.sizeToFit()
            let currentTextWidth = label.frame.width
            lineCount += ceil(currentTextWidth / maxTextWidth)
        }
        print("lineCount = \(lineCount)")
        return lineCount
    }
}
