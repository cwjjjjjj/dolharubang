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
    
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
    
    func autoLineCount(text: Binding<String>, font: UIFont, maxTextWidth: CGFloat) -> CGFloat {
        var lineCount: Int = 0
        
        text.wrappedValue.components(separatedBy: "\n").forEach { line in
            let label = UILabel()
            label.font = font
            label.text = line
            label.sizeToFit()
            let currentTextWidth = label.frame.width
            lineCount += Int(ceil(currentTextWidth / maxTextWidth))
        }
        
        return CGFloat(lineCount)
    }
    
    func transparentScrolling() -> some View {
        if #available(iOS 16.0, *) {
            return scrollContentBackground(.hidden)
        } else {
            return onAppear {
                UITextView.appearance().backgroundColor = .clear
            }
        }
    }
}

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}
