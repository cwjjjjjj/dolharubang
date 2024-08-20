import SwiftUI
import UIKit

struct CustomButton: UIViewRepresentable {
    class Coordinator: NSObject {
        var parent: CustomButton

        init(parent: CustomButton) {
            self.parent = parent
        }

        @objc func buttonTapped() {
            print("tabbed1")
            if !parent.isDisabled {
                print("tabbed2")
                parent.action()
            } else {
                print("Button is disabled")
            }
        }

        @objc func buttonPressedDown(_ sender: UIButton) {
            if !parent.isDisabled {
                // 눌렸을 때 배경색과 텍스트 색상 변경
                sender.setTitleColor(parent.pressedTextColor ?? parent.textColor ?? UIColor(Color.mainBlack), for: .normal)
                sender.backgroundColor = parent.pressedBackgroundColor ?? parent.backgroundColor ?? UIColor(Color.mainGreen)
            }
        }

        @objc func buttonReleased(_ sender: UIButton) {
            if !parent.isDisabled {
                // 눌린 상태에서 손을 뗐을 때 선택 여부에 따라 색상 복원
                if parent.isSelected {
                    sender.setTitleColor(parent.selectedTextColor ?? parent.textColor ?? UIColor(Color.mainWhite), for: .normal)
                    sender.backgroundColor = parent.selectedBackgroundColor ?? parent.backgroundColor ?? UIColor(Color.mainDarkGreen)
                } else {
                    sender.setTitleColor(parent.textColor ?? UIColor(Color.mainBlack), for: .normal)
                    sender.backgroundColor = parent.backgroundColor ?? UIColor(Color.mainGreen)
                }
            }
        }
    }

    var title: String
    var font: Font
    var textColor: UIColor? = UIColor(Color.mainWhite) // 기본 텍스트 색상
    var backgroundColor: UIColor? = UIColor(Color.mainGreen) // 기본 배경 색상
    var pressedTextColor: UIColor? // 눌렸을 때의 텍스트 색상
    var pressedBackgroundColor: UIColor? // 눌렸을 때의 배경색상
    var isSelected: Bool = false // 선택여부
    var selectedTextColor: UIColor? // 선택되었을 때의 텍스트 색상
    var selectedBackgroundColor: UIColor? // 선택되었을 때의 배경색상
    @Binding var isDisabled: Bool // 비활성화 여부
    var disabledTextColor: UIColor? = UIColor(Color.mainBlack) // 비활성화 시 텍스트 색상
    var disabledBackgroundColor: UIColor? = UIColor(Color.disabled) // 비활성화 시 배경색상
    var action: () -> Void // 눌렸을 때 수행할 것

    init(
        title: String,
        font: Font,
        textColor: UIColor? = UIColor(Color.mainWhite),
        backgroundColor: UIColor? = UIColor(Color.mainGreen),
        pressedTextColor: UIColor? = nil,
        pressedBackgroundColor: UIColor? = nil,
        isSelected: Bool = false,
        selectedTextColor: UIColor? = nil,
        selectedBackgroundColor: UIColor? = nil,
        isDisabled: Binding<Bool> = .constant(false), // 기본값 추가
        disabledTextColor: UIColor? = UIColor(Color.mainBlack),
        disabledBackgroundColor: UIColor? = UIColor(Color.disabled),
        action: @escaping () -> Void
    ) {
        self.title = title
        self.font = font
        self.textColor = textColor
        self.backgroundColor = backgroundColor
        self.pressedTextColor = pressedTextColor
        self.pressedBackgroundColor = pressedBackgroundColor
        self.isSelected = isSelected
        self.selectedTextColor = selectedTextColor
        self.selectedBackgroundColor = selectedBackgroundColor
        self._isDisabled = isDisabled // 바인딩 사용
        self.disabledTextColor = disabledTextColor
        self.disabledBackgroundColor = disabledBackgroundColor
        self.action = action
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIView(context: Context) -> UIButton {
        let button = UIButton(type: .system)
        button.setTitle(title, for: .normal)
        button.titleLabel?.font = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: 16)
        button.layer.cornerRadius = 24
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonTapped), for: .touchUpInside)
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonPressedDown(_:)), for: [.touchDown, .touchDragEnter])
        button.addTarget(context.coordinator, action: #selector(Coordinator.buttonReleased(_:)), for: [.touchUpInside, .touchCancel, .touchDragExit])

        return button
    }

    func updateUIView(_ uiView: UIButton, context: Context) {
        uiView.setTitle(title, for: .normal)
        uiView.titleLabel?.font = Font.uiFont(for: Font.button1) ?? UIFont.systemFont(ofSize: 16)

        if isDisabled {
            uiView.setTitleColor(disabledTextColor, for: .normal)
            uiView.backgroundColor = disabledBackgroundColor
        } else if isSelected {
            uiView.setTitleColor(selectedTextColor ?? textColor ?? UIColor(Color.mainWhite), for: .normal)
            uiView.backgroundColor = selectedBackgroundColor ?? backgroundColor ?? UIColor(Color.mainDarkGreen)
        } else {
            uiView.setTitleColor(textColor ?? UIColor(Color.mainBlack), for: .normal)
            uiView.backgroundColor = backgroundColor ?? UIColor(Color.mainGreen)
        }

        uiView.isEnabled = !isDisabled
    }
}
