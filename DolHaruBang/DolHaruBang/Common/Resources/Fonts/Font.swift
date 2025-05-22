import SwiftUI
import UIKit

let defaultTextSize : CGFloat = 50

struct StrokeText: View {
    let text: String
    let width: CGFloat
    let color: Color

    var body: some View {
        ZStack{
            ZStack{
                Text(text).offset(x:  width, y:  width)
                Text(text).offset(x: -width, y: -width)
                Text(text).offset(x: -width, y:  width)
                Text(text).offset(x:  width, y: -width)
            }
            .foregroundColor(color)
            Text(text)
        }
    }
}

extension Font {
    enum CustomFont: String {
        case cafe24SsurroundBold = "Cafe24Ssurround"
        case nanumSquareRoundRegular = "NanumSquareRoundOTFR"
        case nanumSquareRoundBold = "NanumSquareRoundOTFB"
        case nanumSquareRoundExtraBold = "NanumSquareRoundOTFEB"
    }
    
    struct FontStyle {
        let customFont: CustomFont
        let size: CGFloat
        
        var adjustedSize: CGFloat {
                    return UIDevice.isPad ? size + 8 : size
                }
    }
    
    static var h1: FontStyle { FontStyle(customFont: .cafe24SsurroundBold, size: 64) }
    static var h2: FontStyle { FontStyle(customFont: .cafe24SsurroundBold, size: 56) }
    static var h3: FontStyle { FontStyle(customFont: .cafe24SsurroundBold, size: 48) }
    static var h4: FontStyle { FontStyle(customFont: .cafe24SsurroundBold, size: 40) }
    static var h5: FontStyle { FontStyle(customFont: .cafe24SsurroundBold, size: 34) }
    static var h6: FontStyle { FontStyle(customFont: .cafe24SsurroundBold, size: 26) }
    static var h7: FontStyle { FontStyle(customFont: .cafe24SsurroundBold, size: 22) }
    static var h8: FontStyle { FontStyle(customFont: .cafe24SsurroundBold, size: 20) }
    static var h9: FontStyle { FontStyle(customFont: .cafe24SsurroundBold, size: 18) }
    static var subtitle11: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 30) }
    
    static var subtitle1: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 24) }
    static var subtitle2: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 22) }
    static var subtitle3: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 18) }
    static var body1Bold: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 16) }
    static var body2Bold: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 14) }
    static var body3Bold: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 12) }
    static var body35Bold: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 13) }
    static var body4Bold: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 11) }
    static var body5Bold: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 10) }
    
    static var body6Bold: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 8) }
   
    static var bodyRegular: FontStyle { FontStyle(customFont: .nanumSquareRoundRegular, size: 18) }
    static var body1Regular: FontStyle { FontStyle(customFont: .nanumSquareRoundRegular, size: 16) }
    static var body2Regular: FontStyle { FontStyle(customFont: .nanumSquareRoundRegular, size: 14) }
    static var body3Regular: FontStyle { FontStyle(customFont: .nanumSquareRoundRegular, size: 12) }
    static var body4Regular: FontStyle { FontStyle(customFont: .nanumSquareRoundRegular, size: 11) }
    static var body5Regular: FontStyle { FontStyle(customFont: .nanumSquareRoundRegular, size: 10) }
    
    static var body6Regular: FontStyle { FontStyle(customFont: .nanumSquareRoundRegular, size: 8) }
    
    static var button1: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 16) }
    static var button2: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 14) }
    static var button3: FontStyle { FontStyle(customFont: .nanumSquareRoundExtraBold, size: 14) }
    static var button35: FontStyle { FontStyle(customFont: .nanumSquareRoundExtraBold, size: 15) }
    static var button4: FontStyle { FontStyle(customFont: .nanumSquareRoundExtraBold, size: 12) }
    static var caption1: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 10) }
    static var caption2: FontStyle { FontStyle(customFont: .nanumSquareRoundRegular, size: 10) }
    static var overline: FontStyle { FontStyle(customFont: .nanumSquareRoundRegular, size: 10) }
    static var dolname: FontStyle { FontStyle(customFont: .nanumSquareRoundExtraBold, size: 19) }
    static var dollevel: FontStyle { FontStyle(customFont: .nanumSquareRoundExtraBold, size: 17) }
    static var signCount: FontStyle { FontStyle(customFont: .nanumSquareRoundExtraBold, size: 13) }
    
    static var caption4: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 8) }
    
    static var signtext: FontStyle { FontStyle(customFont: .nanumSquareRoundBold, size: 9) }
    
    static func uiFont(for style: FontStyle) -> UIFont? {
        return UIFont(name: style.customFont.rawValue, size: style.adjustedSize)
    }
    
    static func customFont(_ style: FontStyle) -> Font {
        return Font.custom(style.customFont.rawValue, size: style.adjustedSize)
    }
}
