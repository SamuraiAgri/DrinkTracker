import SwiftUI

struct AppColors {
    // メインカラー
    static let primary = Color("PrimaryColor") // テーマカラー（深い青緑色）
    static let secondary = Color("SecondaryColor") // アクセントカラー（ライトブルー）
    static let accent = Color("AccentColor") // アクセントカラー（鮮やかな青）
    
    // 背景色
    static let background = Color("BackgroundColor") // 背景色（オフホワイト）
    static let secondaryBackground = Color("SecondaryBackgroundColor") // セカンダリ背景（薄いグレー）
    static let cardBackground = Color("CardBackgroundColor") // カード背景（白）
    
    // テキストカラー
    static let textPrimary = Color("TextPrimaryColor") // 主要テキスト（濃いグレー）
    static let textSecondary = Color("TextSecondaryColor") // 二次テキスト（中間グレー）
    static let textTertiary = Color("TextTertiaryColor") // 三次テキスト（薄いグレー）
    
    // 機能的なカラー
    static let success = Color("SuccessColor") // 成功（緑）
    static let warning = Color("WarningColor") // 警告（オレンジ）
    static let error = Color("ErrorColor") // エラー（赤）
    static let info = Color("InfoColor") // 情報（青）
    
    // 飲酒レベル表示用カラー
    static let drinkLevelSafe = Color("DrinkLevelSafeColor") // 安全レベル（緑）
    static let drinkLevelModerate = Color("DrinkLevelModerateColor") // 中程度（黄色）
    static let drinkLevelRisky = Color("DrinkLevelRiskyColor") // 危険レベル（オレンジ）
    static let drinkLevelHigh = Color("DrinkLevelHighColor") // 高リスク（赤）
    
    // アルコール種類別カラー
    static let beerColor = Color("BeerColor") // ビール（黄金色）
    static let wineColor = Color("WineColor") // ワイン（赤紫色）
    static let spiritsColor = Color("SpiritsColor") // 蒸留酒（琥珀色）
    static let cocktailColor = Color("CocktailColor") // カクテル（水色）
    static let sakeColor = Color("SakeColor") // 日本酒（淡い黄色）
}
