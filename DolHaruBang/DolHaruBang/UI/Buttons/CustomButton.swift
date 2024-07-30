import SwiftUI
import UIKit

struct CustomButton: UIViewRepresentable {
    class Coordinator: NSObject {
        var parent: CustomButton

        init(parent: CustomButton) {
            self.parent = parent
        }

        @objc func buttonTapped() {
            parent.action()
        }
    }

    var title: String
    var font: Font
    var textColor: UIColor?
    var action: () -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: 16)
        button.setTitleColor(textColor ?? UIColor(Color.mainBlack), for: .normal)
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        button.layer.cornerRadius = 24

        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        uiView.setTitle(title, for: .normal)
        uiView.titleLabel?.font = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: 16)
        uiView.setTitleColor(textColor ?? UIColor(Color.mainBlack), for: .normal)
    }
}
