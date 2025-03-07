import SwiftUI

struct AppColors {
    // メインカラー
    static let primary = Color.blue // テーマカラー
    static let secondary = Color.teal // アクセントカラー
    static let accent = Color.cyan // アクセントカラー
    
    // 背景色
    static let background = Color.white // 背景色
    static let secondaryBackground = Color(UIColor.systemGray6) // セカンダリ背景
    static let cardBackground = Color.white // カード背景
    
    // テキストカラー
    static let textPrimary = Color.black // 主要テキスト
    static let textSecondary = Color.gray // 二次テキスト
    static let textTertiary = Color(UIColor.systemGray4) // 三次テキスト
    
    // 機能的なカラー
    static let success = Color.green // 成功
    static let warning = Color.orange // 警告
    static let error = Color.red // エラー
    static let info = Color.blue // 情報
    
    // 飲酒レベル表示用カラー
    static let drinkLevelSafe = Color.green // 安全レベル
    static let drinkLevelModerate = Color.yellow // 中程度
    static let drinkLevelRisky = Color.orange // 危険レベル
    static let drinkLevelHigh = Color.red // 高リスク
    
    // アルコール種類別カラー
    static let beerColor = Color.yellow // ビール（黄金色）
    static let wineColor = Color.purple // ワイン（赤紫色）
    static let spiritsColor = Color.brown // 蒸留酒（琥珀色）
    static let cocktailColor = Color.blue // カクテル（水色）
    static let sakeColor = Color(UIColor.systemYellow).opacity(0.7) // 日本酒（淡い黄色）
}
