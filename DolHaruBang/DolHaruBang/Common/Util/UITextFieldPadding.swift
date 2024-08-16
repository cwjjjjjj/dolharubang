//
//  UITextFieldPadding.swift
//  DolHaruBang
//
//  Created by 양희태 on 8/16/24.
//
import SwiftUI

extension UITextField {
    func addPadding(left: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: left, height: self.frame.height))
        paddingView.backgroundColor = UIColor.clear
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}
