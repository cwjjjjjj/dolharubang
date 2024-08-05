//
//  respnseKeyboard.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/4/24.
//

import SwiftUI
import Combine

struct KeyboardResponder: ViewModifier {
    @Binding var isKeyboardVisible: Bool
    var keyboardHeight: CGFloat = 0

    init(isKeyboardVisible: Binding<Bool>) {
        self._isKeyboardVisible = isKeyboardVisible
    }

    func body(content: Content) -> some View {
        content
            .onAppear(perform: subscribeToKeyboardEvents)
            .onDisappear(perform: unsubscribeFromKeyboardEvents)
    }

    private func subscribeToKeyboardEvents() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.isKeyboardVisible = true
        }

        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            self.isKeyboardVisible = false
        }
    }

    private func unsubscribeFromKeyboardEvents() {
        NotificationCenter.default.removeObserver(self)
    }
}

extension View {
    func keyboardResponder(isKeyboardVisible: Binding<Bool>) -> some View {
        self.modifier(KeyboardResponder(isKeyboardVisible: isKeyboardVisible))
    }
}
