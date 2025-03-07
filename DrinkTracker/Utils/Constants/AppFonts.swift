import SwiftUI

struct AppFonts {
    // 見出し用フォント
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .bold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .semibold, design: .rounded)
    
    // 本文用フォント
    static let body = Font.system(size: 17, weight: .regular, design: .default)
    static let bodyBold = Font.system(size: 17, weight: .semibold, design: .default)
    static let bodyItalic = Font.system(size: 17, weight: .regular, design: .default).italic()
    
    // 補足テキスト用フォント
    static let callout = Font.system(size: 16, weight: .regular, design: .default)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .default)
    static let footnote = Font.system(size: 13, weight: .regular, design: .default)
    static let caption = Font.system(size: 12, weight: .regular, design: .default)
    static let caption2 = Font.system(size: 11, weight: .regular, design: .default)
    
    // ボタン用フォント
    static let button = Font.system(size: 17, weight: .semibold, design: .default)
    static let smallButton = Font.system(size: 15, weight: .medium, design: .default)
    
    // 数字表示用フォント（統計・グラフなどで使用）
    static let stats = Font.system(size: 40, weight: .bold, design: .rounded)
    static let statsSmall = Font.system(size: 28, weight: .bold, design: .rounded)
    
    // フォントのスケーリング用
    enum ScaledSize {
        static let xxxl: CGFloat = 30
        static let xxl: CGFloat = 24
        static let xl: CGFloat = 20
        static let l: CGFloat = 18
        static let m: CGFloat = 16
        static let s: CGFloat = 14
        static let xs: CGFloat = 12
        static let xxs: CGFloat = 10
    }
}
