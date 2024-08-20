//
//  View.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/20/24.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

