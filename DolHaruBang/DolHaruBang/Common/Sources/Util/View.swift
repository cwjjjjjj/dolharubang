import SwiftUI

// Shimmer 효과를 적용하는 ViewModifier
public struct Shimmer: ViewModifier {

    private let animation: Animation // 사용할 애니메이션
    private let gradient: Gradient // 사용할 그라데이션
    private let min, max: CGFloat // 그라데이션 범위의 최소, 최대값
    @State private var isInitialState = true // 초기 상태 여부
    @Environment(\.layoutDirection) private var layoutDirection // 레이아웃 방향

    /// Shimmer 효과 초기화
    public init(
        animation: Animation = Self.defaultAnimation,
        gradient: Gradient = Self.defaultGradient,
        bandSize: CGFloat = 0.8
    ) {
        self.animation = animation
        self.gradient = gradient
        // 그라데이션 범위
        self.min = 0 - bandSize
        self.max = 1 + bandSize
    }

    // 기본 애니메이션 정의
    // duration 애니메이션 시연 시간
    // delay 애니메이션 시연 후 다음 애니메이션까지의 공백 시간
    public static let defaultAnimation = Animation.easeInOut(duration: 3).delay(0.1).repeatForever(autoreverses: false)

    // 기본 그라데이션 정의
    public static let defaultGradient = Gradient(colors: [
        .black.opacity(0.2),
        .black,
        .black.opacity(0.2)
    ])
    

    // 좌표 시스템 및 예시
    /*
    (0, 0): 왼쪽 상단
    (1, 1): 오른쪽 하단
    x축: 왼쪽에서 오른쪽으로 0에서 1
    y축: 위에서 아래로 0에서 1
     
    왼쪽에서 오른쪽으로:
    초기 상태: [-1, 0.5] -------- [0, 0.5]
    최종 상태:           [1, 0.5] -------- [2, 0.5]

    대각선 이동:
    초기 상태: [-1, -1] /
                    /
    최종 상태:                   /
                              / [2, 2]
    */
    
    var startPoint: UnitPoint {
        if layoutDirection == .rightToLeft {
            isInitialState ? UnitPoint(x: max, y: min) : UnitPoint(x: 0, y: 1)
        } else {
            isInitialState ? UnitPoint(x: min, y: min) : UnitPoint(x: 1, y: 1)
        }
    }

    /// The end unit point of our gradient, adjusting for layout direction.
    var endPoint: UnitPoint {
        if layoutDirection == .rightToLeft {
            isInitialState ? UnitPoint(x: 1, y: 0) : UnitPoint(x: min, y: max)
        } else {
            isInitialState ? UnitPoint(x: 0, y: 0) : UnitPoint(x: max, y: max)
        }
    }

    // ViewModifier 프로토콜 구현
    public func body(content: Content) -> some View {
        applyingGradient(to: content)
            .animation(animation, value: isInitialState)
            .onAppear {
                // 뷰가 나타난 후 비동기적으로 초기 상태 변경
                DispatchQueue.main.asyncAfter(deadline: .now()) {
                    isInitialState = false
                }
            }
    }

    // 그라데이션 적용 메서드
    @ViewBuilder public func applyingGradient(to content: Content) -> some View {
        let gradient = LinearGradient(gradient: gradient, startPoint: startPoint, endPoint: endPoint)
        content.mask(gradient)
    }
}

func calculateScale(width: CGFloat, height: CGFloat) -> CGFloat {
    let ipadWidth: CGFloat = 375
    let iphoneWidth: CGFloat = 390
    let ipadHeight: CGFloat = 647
    let iphoneHeight: CGFloat = 763
    let scaleIpad: CGFloat = 0.75
    let scaleIphone: CGFloat = 1.0

    // 가로, 세로 각각에 대해 보간값 계산
    let tWidth = min(max((width - ipadWidth) / (iphoneWidth - ipadWidth), 0), 1)
    let tHeight = min(max((height - ipadHeight) / (iphoneHeight - ipadHeight), 0), 1)

    // 두 보간값의 평균(혹은 min/max 등 원하는 방식)
    let t = min(tWidth, tHeight)

    // 최종 스케일
    return scaleIpad + (scaleIphone - scaleIpad) * t
}

extension View {
    // Shimmer 효과를 뷰에 적용하는 메서드
    @ViewBuilder func shimmering(
        active: Bool = true,
        animation: Animation = Shimmer.defaultAnimation,
        gradient: Gradient = Shimmer.defaultGradient,
        bandSize: CGFloat = 0.8
    ) -> some View {
        if active {
            modifier(Shimmer(animation: animation, gradient: gradient, bandSize: bandSize))
        } else {
            self
        }
    }
    
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

// 원하는 코너에만 적용하기 위한 메서드
// 종류는 4가지 (.topLeft, .topRight, .bottomLeft, .bottomRight)
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
