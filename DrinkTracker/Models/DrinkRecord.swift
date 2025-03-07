import Foundation

struct DrinkRecord: Identifiable, Codable, Equatable {
    var id: UUID
    var date: Date
    var drinkType: DrinkType
    var volume: Double // ml
    var alcoholPercentage: Double // %
    var price: Double? // 円
    var location: String?
    var note: String?
    var isFavorite: Bool
    
    init(
        id: UUID = UUID(),
        date: Date = Date(),
        drinkType: DrinkType,
        volume: Double,
        alcoholPercentage: Double? = nil,
        price: Double? = nil,
        location: String? = nil,
        note: String? = nil,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.date = date
        self.drinkType = drinkType
        self.volume = volume
        self.alcoholPercentage = alcoholPercentage ?? drinkType.defaultPercentage
        self.price = price
        self.location = location
        self.note = note
        self.isFavorite = isFavorite
    }
    
    // 純アルコール量を計算（g）
    var pureAlcoholGrams: Double {
        // アルコール比重: 約0.8g/ml
        let alcoholDensity = 0.8
        return volume * (alcoholPercentage / 100) * alcoholDensity
    }
    
    // 標準ドリンク数に換算
    var standardDrinks: Double {
        return pureAlcoholGrams / AppConstants.Drinking.standardDrinkGrams
    }
    
    // カロリー計算（kcal） - アルコールは1gあたり約7kcal
    var calories: Double {
        return pureAlcoholGrams * 7.0
    }
    
    // リスクレベルを評価
    var riskLevel: RiskLevel {
        let alcohol = pureAlcoholGrams
        
        if alcohol <= AppConstants.Drinking.lowRiskLimit {
            return .safe
        } else if alcohol <= AppConstants.Drinking.moderateRiskLimit {
            return .moderate
        } else if alcohol <= AppConstants.Drinking.highRiskLimit {
            return .risky
        } else {
            return .high
        }
    }
    
    // 日付のみの比較用（時間は無視）
    func isSameDay(as date: Date) -> Bool {
        return Calendar.current.isDate(self.date, inSameDayAs: date)
    }
    
    // リスクレベルの定義
    enum RiskLevel: String, Codable {
        case safe = "安全"
        case moderate = "中程度"
        case risky = "リスク"
        case high = "高リスク"
        
        var color: String {
            switch self {
            case .safe:
                return "DrinkLevelSafeColor"
            case .moderate:
                return "DrinkLevelModerateColor"
            case .risky:
                return "DrinkLevelRiskyColor"
            case .high:
                return "DrinkLevelHighColor"
            }
        }
    }
}

// DrinkRecordの集合を扱うための拡張
extension Array where Element == DrinkRecord {
    // 特定の日の記録をフィルタリング
    func recordsForDay(_ date: Date) -> [DrinkRecord] {
        self.filter { $0.isSameDay(as: date) }
    }
    
    // 特定の日の合計アルコール摂取量（g）
    func totalAlcoholForDay(_ date: Date) -> Double {
        recordsForDay(date).reduce(0) { $0 + $1.pureAlcoholGrams }
    }
    
    // 特定の日の合計支出
    func totalSpendingForDay(_ date: Date) -> Double {
        recordsForDay(date).reduce(0) { $0 + ($1.price ?? 0) }
    }
    
    // 週間の記録を取得
    func recordsForWeek(endingAt date: Date) -> [DrinkRecord] {
        let calendar = Calendar.current
        let endDate = calendar.startOfDay(for: date)
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: endDate) else {
            return []
        }
        
        return self.filter {
            let recordDate = calendar.startOfDay(for: $0.date)
            return (recordDate >= startDate && recordDate <= endDate)
        }
    }
    
    // 月間の記録を取得
    func recordsForMonth(containing date: Date) -> [DrinkRecord] {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: date)
        guard let startOfMonth = calendar.date(from: components),
              let endOfMonth = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
            return []
        }
        
        return self.filter {
            let recordDate = calendar.startOfDay(for: $0.date)
            return (recordDate >= startOfMonth && recordDate <= endOfMonth)
        }
    }
}
