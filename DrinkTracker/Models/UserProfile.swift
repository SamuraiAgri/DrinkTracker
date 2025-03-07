import Foundation

struct UserProfile: Codable, Equatable {
    var id: UUID
    var displayName: String
    var gender: Gender
    var birthDate: Date
    var weight: Double // kg
    var height: Double? // cm
    var drinkingGoal: DrinkingGoal
    var weeklyBudget: Double? // 円
    var notificationsEnabled: Bool
    var preferredRemindTime: Date
    var createdAt: Date
    var lastUpdated: Date
    
    init(
        id: UUID = UUID(),
        displayName: String = "",
        gender: Gender = .notSpecified,
        birthDate: Date = Calendar.current.date(byAdding: .year, value: -30, to: Date()) ?? Date(),
        weight: Double = 60.0,
        height: Double? = nil,
        drinkingGoal: DrinkingGoal = .moderate,
        weeklyBudget: Double? = 5000,
        notificationsEnabled: Bool = true,
        preferredRemindTime: Date = UserProfile.defaultReminderTime(),
        createdAt: Date = Date(),
        lastUpdated: Date = Date()
    ) {
        self.id = id
        self.displayName = displayName
        self.gender = gender
        self.birthDate = birthDate
        self.weight = weight
        self.height = height
        self.drinkingGoal = drinkingGoal
        self.weeklyBudget = weeklyBudget
        self.notificationsEnabled = notificationsEnabled
        self.preferredRemindTime = preferredRemindTime
        self.createdAt = createdAt
        self.lastUpdated = lastUpdated
    }
    
    // 年齢を計算
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
    
    // BMIを計算（身長がある場合）
    var bmi: Double? {
        guard let height = height, height > 0 else { return nil }
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    // 推奨される1日あたりの最大アルコール摂取量（g）
    var recommendedDailyLimit: Double {
        switch drinkingGoal {
        case .reduce:
            return max(AppConstants.Drinking.lowRiskLimit * 0.5, 10.0)
        case .moderate:
            return AppConstants.Drinking.lowRiskLimit
        case .maintain:
            return min(AppConstants.Drinking.moderateRiskLimit, AppConstants.Drinking.weeklyRecommendedLimit / 7)
        }
    }
    
    // 性別によるアルコール代謝率の違いを考慮した推奨値の調整
    var adjustedDailyLimit: Double {
        switch gender {
        case .male:
            return recommendedDailyLimit
        case .female:
            // 女性は一般的に男性よりもアルコール代謝が遅いため、約20%下方修正
            return recommendedDailyLimit * 0.8
        case .notSpecified:
            return recommendedDailyLimit * 0.9 // 中間値として設定
        }
    }
    
    // ユーザー設定を更新
    mutating func update(from newProfile: UserProfile) {
        self.displayName = newProfile.displayName
        self.gender = newProfile.gender
        self.birthDate = newProfile.birthDate
        self.weight = newProfile.weight
        self.height = newProfile.height
        self.drinkingGoal = newProfile.drinkingGoal
        self.weeklyBudget = newProfile.weeklyBudget
        self.notificationsEnabled = newProfile.notificationsEnabled
        self.preferredRemindTime = newProfile.preferredRemindTime
        self.lastUpdated = Date()
    }
    
    // デフォルトのリマインド時間を取得（20:00）
    static func defaultReminderTime() -> Date {
        let components = DateComponents(hour: 20, minute: 0)
        return Calendar.current.date(from: components) ?? Date()
    }
    
    // 性別の列挙型
    enum Gender: String, Codable, CaseIterable {
        case male = "男性"
        case female = "女性"
        case notSpecified = "指定なし"
    }
    
    // 飲酒目標の列挙型
    enum DrinkingGoal: String, Codable, CaseIterable {
        case reduce = "減らす"
        case moderate = "適度に保つ"
        case maintain = "現状維持"
        
        var description: String {
            switch self {
            case .reduce:
                return "飲酒量を減らし、健康的な習慣を形成する"
            case .moderate:
                return "推奨される適量内で飲酒を楽しむ"
            case .maintain:
                return "現在の習慣を維持しながら健康に気を付ける"
            }
        }
    }
}
