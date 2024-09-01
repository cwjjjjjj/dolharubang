import SwiftUI
import UIKit

extension CALayer {
    func applyShadow(
        color: UIColor,
        alpha: Float,
        x: CGFloat,
        y: CGFloat,
        blur: CGFloat,
        spread: CGFloat
    ) {
        shadowColor = color.cgColor
        shadowOpacity = alpha
        shadowOffset = CGSize(width: x, height: y)
        shadowRadius = blur / UIScreen.main.scale
        if spread == 0 {
            shadowPath = nil
        } else {
            let dx = -spread
            let rect = bounds.insetBy(dx: dx, dy: dx)
            shadowPath = UIBezierPath(rect: rect).cgPath
        }
    }
    
    func applyInnerShadow(
        color: UIColor,
        alpha: Float,
        x: CGFloat,
        y: CGFloat,
        blur: CGFloat,
        spread: CGFloat
    ) {
        let shadowLayer = CALayer()
        shadowLayer.frame = bounds
        shadowLayer.backgroundColor = UIColor.clear.cgColor

        let path = UIBezierPath(rect: shadowLayer.bounds)
        let insetPath = UIBezierPath(rect: shadowLayer.bounds.insetBy(dx: spread, dy: spread))
        path.append(insetPath.reversing())

        shadowLayer.shadowPath = path.cgPath
        shadowLayer.masksToBounds = true
        shadowLayer.shadowColor = color.cgColor
        shadowLayer.shadowOpacity = alpha
        shadowLayer.shadowOffset = CGSize(width: x, height: y)
        shadowLayer.shadowRadius = blur / UIScreen.main.scale

        shadowLayer.shouldRasterize = true
        shadowLayer.rasterizationScale = UIScreen.main.scale

        // 기존의 레이어들을 클리어하지 않고 새 레이어만 추가
        if let existingShadowLayer = sublayers?.first(where: { $0.name == "innerShadowLayer" }) {
            existingShadowLayer.removeFromSuperlayer()
        }

        shadowLayer.name = UUID().uuidString
        insertSublayer(shadowLayer, at: 0)
    }
}

struct ShadowView: UIViewRepresentable {
    let color: UIColor
    let alpha: Float
    let x: CGFloat
    let y: CGFloat
    let blur: CGFloat
    let spread: CGFloat
    let isInnerShadow: Bool

    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        view.backgroundColor = .clear

        // 뷰 생성 시 그림자 바로 추가
        if isInnerShadow {
            view.layer.applyInnerShadow(
                color: color,
                alpha: alpha,
                x: x,
                y: y,
                blur: blur,
                spread: spread
            )
        } else {
            view.layer.applyShadow(
                color: color,
                alpha: alpha,
                x: x,
                y: y,
                blur: blur,
                spread: spread
            )
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // 고유한 레이어 이름 생성
        let uniqueLayerName = UUID().uuidString

        DispatchQueue.main.async {
            if isInnerShadow {
                if uiView.layer.sublayers?.first(where: { $0.name == uniqueLayerName }) == nil {
                    uiView.layer.applyInnerShadow(
                        color: color,
                        alpha: alpha,
                        x: x,
                        y: y,
                        blur: blur,
                        spread: spread
                    )
                    uiView.layer.sublayers?.first?.name = uniqueLayerName // 생성된 레이어의 이름을 설정
                }
            } else {
                if uiView.layer.sublayers?.first(where: { $0.name == uniqueLayerName }) == nil {
                    uiView.layer.applyShadow(
                        color: color,
                        alpha: alpha,
                        x: x,
                        y: y,
                        blur: blur,
                        spread: spread
                    )
                    uiView.layer.sublayers?.first?.name = uniqueLayerName // 생성된 레이어의 이름을 설정
                }
            }
        }
    }
}


struct CustomShadowModifier: ViewModifier {
    let color: Color
    let alpha: Float
    let x: CGFloat
    let y: CGFloat
    let blur: CGFloat
    let spread: CGFloat
    let isInnerShadow: Bool

    func body(content: Content) -> some View {
        content
            .background(
                ShadowView(
                    color: UIColor(color),
                    alpha: alpha,
                    x: x,
                    y: y,
                    blur: blur,
                    spread: spread,
                    isInnerShadow: isInnerShadow
                )
            )
    }
}

struct BlurView: UIViewRepresentable {
    let blurType: UIBlurEffect.Style

    func makeUIView(context: Context) -> UIVisualEffectView {
        let blurEffect = UIBlurEffect(style: blurType)
        return UIVisualEffectView(effect: blurEffect)
    }

    func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
        uiView.effect = UIBlurEffect(style: blurType)
    }
}

struct BlurEffectModifier: ViewModifier {
    let blurType: UIBlurEffect.Style

    func body(content: Content) -> some View {
        content
            .background(BlurView(blurType: blurType))
    }
}

extension View {
    func customShadow(
        color: Color,
        alpha: Float = 1.0,
        x: CGFloat = 0,
        y: CGFloat = 0,
        blur: CGFloat = 10,
        spread: CGFloat = 0,
        isInnerShadow: Bool = false
    ) -> some View {
        self.modifier(CustomShadowModifier(
            color: color,
            alpha: alpha,
            x: x,
            y: y,
            blur: blur,
            spread: spread,
            isInnerShadow: isInnerShadow
        ))
    }

    func blurEffect(blurType: UIBlurEffect.Style = .light) -> some View {
        self.modifier(BlurEffectModifier(blurType: blurType))
    }
}

// Color에서 UIColor로 변환하는 초기화 메서드
extension UIColor {
    convenience init(_ color: Color) {
        let scanner = Scanner(string: color.description.trimmingCharacters(in: .alphanumerics.inverted))
        var hexNumber: UInt64 = 0
        
        if scanner.scanHexInt64(&hexNumber) {
            let r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255
            let g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255
            let b = CGFloat(hexNumber & 0x0000FF) / 255
            self.init(red: r, green: g, blue: b, alpha: 1.0)
        } else {
            self.init(red: 0, green: 0, blue: 0, alpha: 1.0)
        }
    }
}
