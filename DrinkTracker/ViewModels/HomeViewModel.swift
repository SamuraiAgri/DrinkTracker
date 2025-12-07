// DrinkTracker/ViewModels/HomeViewModel.swift
import Foundation
import Combine

class HomeViewModel: ObservableObject {
    // 表示データ
    @Published var dailyAlcoholGrams: Double = 0
    @Published var weeklyAlcoholGrams: Double = 0
    @Published var dailySpending: Double = 0
    @Published var weeklySpending: Double = 0
    @Published var alcoholFreeDaysCount: Int = 0
    @Published var recentDrinks: [DrinkRecord] = []
    @Published var currentDate: Date = Date()
    
    // サービス
    public let drinkDataManager: DrinkDataManager
    private let userProfileManager: UserProfileManager
    
    // 推奨摂取限度量
    @Published var recommendedDailyLimit: Double = 0
    @Published var weeklyBudget: Double? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init(drinkDataManager: DrinkDataManager, userProfileManager: UserProfileManager) {
        // すべてのプロパティを初期化してから監視を設定
        self.drinkDataManager = drinkDataManager
        self.userProfileManager = userProfileManager
        
        // ユーザープロファイルの変更を監視
        userProfileManager.$userProfile
            .sink { [weak self] profile in
                self?.recommendedDailyLimit = profile.adjustedDailyLimit
                self?.weeklyBudget = profile.weeklyBudget
            }
            .store(in: &cancellables)
        
        // 飲酒データの変更を監視
        drinkDataManager.$drinkRecords
            .sink { [weak self] _ in
                self?.updateDisplayData()
            }
            .store(in: &cancellables)
            
        // 初期データを読み込む
        updateDisplayData()
    }
    
    // 表示データを更新
    func updateDisplayData() {
        // 今日の摂取量
        dailyAlcoholGrams = drinkDataManager.getDailyTotalAlcohol()
        
        // 週間の摂取量
        weeklyAlcoholGrams = drinkDataManager.getWeeklyTotalAlcohol()
        
        // 支出
        dailySpending = drinkDataManager.getDailyTotalSpending()
        weeklySpending = drinkDataManager.getWeeklyTotalSpending()
        
        // 休肝日の数
        alcoholFreeDaysCount = drinkDataManager.getAlcoholFreeDaysCount(in: .week)
        
        // 最近の飲酒記録（今日と昨日）
        let today = drinkDataManager.getDrinkRecords(for: Date())
        
        let calendar = Calendar.current
        if let yesterday = calendar.date(byAdding: .day, value: -1, to: Date()) {
            let yesterdayRecords = drinkDataManager.getDrinkRecords(for: yesterday)
            recentDrinks = today + yesterdayRecords
        } else {
            recentDrinks = today
        }
        
        // 日付を最新に
        currentDate = Date()
    }
    
    // 今日の飲酒量の割合（推奨量に対する%）
    var dailyLimitPercentage: Double {
        guard recommendedDailyLimit > 0 else { return 0 }
        return min(1.0, dailyAlcoholGrams / recommendedDailyLimit)
    }
    
    // 週間の予算消費割合
    var weeklyBudgetPercentage: Double {
        guard let budget = weeklyBudget, budget > 0 else { return 0 }
        return min(1.0, weeklySpending / budget)
    }
    
    // 健康リスクレベルの評価
    var healthRiskLevel: AlcoholCalculator.HealthRiskLevel {
        return AlcoholCalculator.assessHealthRisk(weeklyAlcoholGrams: weeklyAlcoholGrams)
    }
    
    // 週間摂取量に基づく健康アドバイス
    var healthAdvice: String {
        return healthRiskLevel.recommendation
    }
    
    // 飲酒量の削減による推定節約額（月間）
    func calculateProjectedMonthlySavings(reductionPercent: Double = 20) -> Double {
        let projection = SavingsCalculator.calculateProjectedSavings(
            currentRecords: drinkDataManager.getMonthlyRecords(),
            targetReductionPercent: reductionPercent
        )
        return projection.monthly
    }
    
    // 新しい飲み物を記録
    func addDrink(_ drink: DrinkRecord) {
        drinkDataManager.addDrinkRecord(drink)
        updateDisplayData()
    }
    
    // 日付変更時の更新
    func updateDate(to date: Date) {
        currentDate = date
        updateDisplayData()
    }
    
    // 飲酒レベルに基づく色取得（セーフティチェック用）
    func getDrinkLevelColor() -> String {
        let percentage = dailyLimitPercentage
        
        if percentage < 0.5 {
            return "DrinkLevelSafeColor"
        } else if percentage < 0.75 {
            return "DrinkLevelModerateColor"
        } else if percentage < 1.0 {
            return "DrinkLevelRiskyColor"
        } else {
            return "DrinkLevelHighColor"
        }
    }
    
    func deleteDrink(_ id: UUID) {
        // ハプティックフィードバック
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.warning)
        
        drinkDataManager.deleteDrinkRecord(id)
        updateDisplayData()
    }
}
