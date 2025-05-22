import SwiftUI
import UIKit
import Combine

enum Align {
    case leading, trailing, center
    
    var uiTextAlignment: NSTextAlignment {
        switch self {
        case .leading: return .left
        case .trailing: return .right
        case .center: return .center
        }
    }
}

struct CustomTextField: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var placeholderColor: UIColor?
    var font: Font?
    var textColor: UIColor?
    var backgroundColor: UIColor? = .coreGray
    var minLength: Int = 1
    var maxLength: Int
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
        private let textSubject = PassthroughSubject<String, Never>()
        private var cancellables = Set<AnyCancellable>()
        
        init(parent: CustomTextField) {
            self.parent = parent
            super.init()
            textSubject
                .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
                .sink { [weak self] text in
                    self?.parent.text = text
                }
                .store(in: &cancellables)
        }
        
        @objc func textFieldDidChange(_ textField: UITextField) {
            if let text = textField.text, text.count > parent.maxLength {
                textField.text = String(text.prefix(parent.maxLength))
            }
            textSubject.send(textField.text ?? "")
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            parent.onSubmit?()
            return true
        }
        
        func textFieldDidEndEditing(_ textField: UITextField) {
            if parent.useDidEndEditing {
                if parent.text.count < parent.minLength {
                    if let alertTitle = parent.alertTitle,
                       let alertMessage = parent.alertMessage,
                       let dismissButtonTitle = parent.dismissButtonTitle {
                        textField.resignFirstResponder()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                            self?.parent.showAlert(
                                title: alertTitle,
                                message: alertMessage,
                                dismissButtonTitle: dismissButtonTitle
                            )
                        }
                    }
                } else {
                    parent.onEndEditing?()
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
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange), for: .editingChanged)
        textField.text = text
        let customFont = customFontStyle.map { Font.uiFont(for: $0) ?? UIFont.systemFont(ofSize: $0.size) } ?? UIFont.systemFont(ofSize: 16)
        textField.font = customFont
        textField.textColor = textColor ?? .black
        textField.backgroundColor = backgroundColor ?? .gray
        textField.textAlignment = alignment.uiTextAlignment
        textField.addPadding(left: leftPadding, right: rightPadding)
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment.uiTextAlignment
        
        textField.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: placeholderColor ?? .gray,
                .font: customFont,
                .paragraphStyle: paragraphStyle
            ]
        )
        
        return textField
    }
    
    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        let customFont = customFontStyle.map { Font.uiFont(for: $0) ?? UIFont.systemFont(ofSize: $0.size) } ?? UIFont.systemFont(ofSize: 16)
        uiView.font = customFont
        uiView.textColor = textColor ?? .black
        uiView.backgroundColor = backgroundColor ?? .gray
        uiView.textAlignment = alignment.uiTextAlignment
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = alignment.uiTextAlignment
        
        uiView.attributedPlaceholder = NSAttributedString(
            string: placeholder,
            attributes: [
                .foregroundColor: placeholderColor ?? .gray,
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
        private let textSubject = PassthroughSubject<String, Never>()
        private var cancellables = Set<AnyCancellable>()

        init(parent: SimpleCustomTextField) {
            self.parent = parent
            super.init()
            textSubject
                .debounce(for: .milliseconds(100), scheduler: DispatchQueue.main)
                .sink { [weak self] text in
                    self?.parent.text = text
                }
                .store(in: &cancellables)
        }

        @objc func textFieldDidChange(_ textField: UITextField) {
            if let text = textField.text, text.count > parent.maxLength {
                textField.text = String(text.prefix(parent.maxLength))
            }
            textSubject.send(textField.text ?? "")
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
        textField.addTarget(context.coordinator, action: #selector(Coordinator.textFieldDidChange), for: .editingChanged)
        textField.text = text
        textField.placeholder = placeholder
        textField.textColor = textColor ?? .black
        textField.font = font ?? UIFont.systemFont(ofSize: 14)
        textField.borderStyle = .none
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setContentHuggingPriority(.required, for: .vertical)
        textField.setContentCompressionResistancePriority(.required, for: .vertical)
        textField.autocorrectionType = .no
        textField.spellCheckingType = .no

        if let placeholderColor = placeholderColor {
            textField.attributedPlaceholder = NSAttributedString(
                string: placeholder,
                attributes: [NSAttributedString.Key.foregroundColor: placeholderColor]
            )
        }

        return textField
    }

    func updateUIView(_ uiView: UITextField, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
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
    let font: UIFont = Font.uiFont(for: Font.body3Regular) ?? UIFont.systemFont(ofSize: 42)
    var maxTextWidth: CGFloat
    @State private var textHeight: CGFloat = 48
    
    var body: some View {
        TextEditor(text: $text)
            .frame(height: textHeight)
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 12, trailing: 16))
            .onAppear {
                calculateHeight()
            }
            .onChange(of: text) {
                calculateHeight()
            }
    }

    private func calculateHeight() {
        let lineCount = autoLineCount(text: text, font: font, maxTextWidth: maxTextWidth - 40)
        let minH: CGFloat = font.lineHeight + (UIDevice.isPad ? 20 : 2)
        let maxH: CGFloat = 120.0
        textHeight = min(max(minH, lineCount * (font.lineHeight + 2)), maxH)
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
        return lineCount
    }
}

extension UITextField {
    func addPadding(left: CGFloat, right: CGFloat) {
        if left > 0 {
            let leftView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: frame.height))
            self.leftView = leftView
            self.leftViewMode = .always
        }
        if right > 0 {
            let rightView = UIView(frame: CGRect(x: 0, y: 0, width: right, height: frame.height))
            self.rightView = rightView
            self.rightViewMode = .always
        }
    }
}


// 펫말용 테스트

struct CustomTextView2: UIViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var placeholderColor: UIColor = .lightGray
    var font: UIFont = .systemFont(ofSize: 16)
    var textColor: UIColor = .black
    var backgroundColor: UIColor = .white
    var maxLength: Int = 50
    var leftPadding: CGFloat = 5
    var rightPadding: CGFloat = 5

    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextView2

        init(_ parent: CustomTextView2) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            // 최대 글자 수 제한
            if textView.text.count > parent.maxLength {
                textView.text = String(textView.text.prefix(parent.maxLength))
            }
            parent.text = textView.text
        }

        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.textColor == parent.placeholderColor {
                textView.text = ""
                textView.textColor = parent.textColor
            }
        }

        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = parent.placeholderColor
            }
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        textView.font = font
        textView.textColor = text.isEmpty ? placeholderColor : textColor
        textView.backgroundColor = backgroundColor
        textView.text = text.isEmpty ? placeholder : text
        textView.isScrollEnabled = true
        textView.textContainerInset = UIEdgeInsets(top: 8, left: leftPadding, bottom: 8, right: rightPadding)
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
        uiView.font = font
        uiView.textColor = text.isEmpty ? placeholderColor : textColor
        uiView.backgroundColor = backgroundColor
        uiView.textContainerInset = UIEdgeInsets(top: 8, left: leftPadding, bottom: 8, right: rightPadding)
        if text.isEmpty {
            uiView.text = placeholder
            uiView.textColor = placeholderColor
        }
    }
}



struct SignTextView: View {
    @Binding var text: String
    let placeholder: String
    let font: UIFont = UIFont(name: Font.body3Regular.customFont.rawValue, size: Font.body3Regular.size) ?? UIFont.systemFont(ofSize: 12)
    var maxTextWidth: CGFloat
    @State private var textHeight: CGFloat = 48

    var body: some View {
        ZStack(alignment: .topLeading) {
            // 플레이스홀더
            if text.isEmpty {
                Text(placeholder)
                    .foregroundColor(.gray)
                    .padding(EdgeInsets(top: 16, leading: 20, bottom: 0, trailing: 0))
            }
            // TextEditor
            TextEditor(text: Binding(
                get: { text },
                set: { newValue in
                    if newValue.count <= 50 {
                        text = newValue
                    } else {
                        text = String(newValue.prefix(50))
                    }
                }
            ))
            .scrollDisabled(true) // << 스크롤 완전 비활성화 (iOS 16+)
            .frame(height: textHeight)
            .padding(EdgeInsets(top: 10, leading: 16, bottom: 12, trailing: 16))
            .background(Color.clear)
            .onAppear { calculateHeight() }
            .onChange(of: text) { calculateHeight() }
        }
    }

    private func calculateHeight() {
        let lineCount = autoLineCount(text: text, font: font, maxTextWidth: maxTextWidth - 100)
        let minH: CGFloat = font.lineHeight + 10
        let maxH: CGFloat = 70
        textHeight = min(max(minH, lineCount * (font.lineHeight + 2)), maxH)
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
        return lineCount
    }
}
