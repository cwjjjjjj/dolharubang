//
//  View.swift
//  DolHaruBang
//
//  Created by 안상준 on 7/31/24.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
