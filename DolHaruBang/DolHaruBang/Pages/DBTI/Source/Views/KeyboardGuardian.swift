//
//  KeyboardGuardian.swift
//  DolHaruBang
//
//  Created by 안상준 on 8/3/24.
//

import SwiftUI
import Combine

class KeyboardGuardian: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0

    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default
            .publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .compactMap { notification in
                (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect)?.height
            }
            .merge(with: NotificationCenter.default
                .publisher(for: UIResponder.keyboardWillHideNotification)
                .map { _ in CGFloat(0) })
            .assign(to: \.keyboardHeight, on: self)
    }
}

