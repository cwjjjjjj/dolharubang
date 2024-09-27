import SwiftUI

extension UITextField {
    func addPadding(left: CGFloat? = nil, right: CGFloat? = nil) {
        if let leftPadding = left {
            let leftPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: leftPadding, height: self.frame.height))
            leftPaddingView.backgroundColor = UIColor.clear
            self.leftView = leftPaddingView
            self.leftViewMode = .always
        }
        
        if let rightPadding = right {
            let rightPaddingView = UIView(frame: CGRect(x: 0, y: 0, width: rightPadding, height: self.frame.height))
            rightPaddingView.backgroundColor = UIColor.clear
            self.rightView = rightPaddingView
            self.rightViewMode = .always
        }
    }
}
