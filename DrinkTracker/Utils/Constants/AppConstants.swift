import Foundation
import SwiftUI

struct AppConstants {
    // アプリ一般設定
    static let appName = "DrinkTracker"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    
    // UI定数
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let smallCornerRadius: CGFloat = 8
        static let cardPadding: CGFloat = 16
        static let standardPadding: CGFloat = 20
        static let smallPadding: CGFloat = 8
        static let iconSize: CGFloat = 24
        static let largeIconSize: CGFloat = 32
        static let buttonHeight: CGFloat = 54
        static let smallButtonHeight: CGFloat = 44
        static let tabBarHeight: CGFloat = 60
        static let animationDuration: Double = 0.3
    }
    
    // 飲酒データ関連定数
    struct Drinking {
        // 標準ドリンク換算（1ドリンク = 純アルコール10g）
        static let standardDrinkGrams: Double = 10.0
        
        // アルコール度数の平均値（%）
        static let beerAlcoholPercentage: Double = 5.0
        static let wineAlcoholPercentage: Double = 12.0
        static let spiritsAlcoholPercentage: Double = 40.0
        static let sakeAlcoholPercentage: Double = 15.0
        static let cocktailAlcoholPercentage: Double = 8.0
        
        // デフォルトの飲酒サイズ（ml）
        static let beerDefaultSize: Double = 350.0
        static let wineDefaultSize: Double = 150.0
        static let spiritsDefaultSize: Double = 45.0
        static let sakeDefaultSize: Double = 180.0
        static let cocktailDefaultSize: Double = 250.0
        
        // 健康リスクレベルの基準（1日あたりの純アルコールg）
        static let lowRiskLimit: Double = 20.0
        static let moderateRiskLimit: Double = 40.0
        static let highRiskLimit: Double = 60.0
        
        // 週間推奨上限（純アルコールg）
        static let weeklyRecommendedLimit: Double = 140.0
    }
    
    // 保存キー
    struct StorageKeys {
        static let drinkRecords = "drinkRecords"
        static let userProfile = "userProfile"
        static let notificationSettings = "notificationSettings"
        static let lastVersion = "lastVersion"
        static let onboardingComplete = "onboardingComplete"
    }
    
    // 通知関連定数
    struct Notifications {
        static let reminderCategory = "reminderCategory"
        static let reminderActionIdentifier = "reminderAction"
        static let defaultReminderTime = "20:00" // 8 PM
    }
    
    // 健康アドバイス関連
    struct HealthAdvice {
        static let hydrationReminder = "アルコール摂取後は水分をしっかり摂りましょう"
        static let moderationAdvice = "休肝日を週に2日以上設けることをお勧めします"
        static let nutritionAdvice = "アルコールと一緒に栄養価の高い食事を摂ることで、アルコールの吸収を緩やかにできます"
    }
}
