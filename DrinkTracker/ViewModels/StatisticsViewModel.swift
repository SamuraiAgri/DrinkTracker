import Foundation
import Combine
import SwiftUI

class StatisticsViewModel: ObservableObject {
    // データ
    @Published var monthlyData: [MonthlyStatData] = []
    
    // 設定
    @Published var selectedTimeFrame: TimeFrame = .month
    @Published var selectedDataType: DataType = .alcohol
    @Published var selectedDate: Date = Date()
    
    // サービス
    public let drinkDataManager: DrinkDataManager
    private let userProfileManager: UserProfileManager
    
    // ユーザープロファイル情報
    @Published var dailyLimit: Double = 0
    @Published var weeklyBudget: Double? = nil
    
    private var cancellables = Set<AnyCancellable>()
    
    init(drinkDataManager: DrinkDataManager, userProfileManager: UserProfileManager) {
        // プロパティの初期化
        self.drinkDataManager = drinkDataManager
        self.userProfileManager = userProfileManager
        
        // 初期データを読み込む
        updateData()
        
        // ユーザープロファイルの変更を監視
        userProfileManager.$userProfile
            .sink { [weak self] profile in
                self?.dailyLimit = profile.adjustedDailyLimit
                self?.weeklyBudget = profile.weeklyBudget
                self?.updateData()
            }
            .store(in: &cancellables)
        
        // 飲酒データの変更を監視
        drinkDataManager.$drinkRecords
            .sink { [weak self] _ in
                self?.updateData()
            }
            .store(in: &cancellables)
    }
    
    // データの更新
    func updateData() {
        updateMonthlyData()
    }
    
    // 週間グラフ用のデータを取得
    func getWeeklyChartData() -> [DailyAlcoholData] {
        let calendar = Calendar.current
        var data: [DailyAlcoholData] = []
        
        // 今日から過去7日間のデータを取得
        for offset in -6...0 {
            guard let date = calendar.date(byAdding: .day, value: offset, to: Date()) else { continue }
            
            let dayRecords = drinkDataManager.getDrinkRecords(for: date)
            let alcoholGrams = dayRecords.reduce(0) { $0 + $1.pureAlcoholGrams }
            
            // 曜日ラベルを取得
            let weekdaySymbol = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            
            data.append(DailyAlcoholData(
                date: date,
                dayLabel: weekdaySymbol,
                alcoholGrams: alcoholGrams
            ))
        }
        
        return data
    }
    
    // 月間データの更新（現在の月の日ごとのデータ）
    private func updateMonthlyData() {
        let calendar = Calendar.current
        let today = Date()
        var monthlyStats: [MonthlyStatData] = []
        
        // 選択された月を取得
        var components = calendar.dateComponents([.year, .month], from: selectedDate)
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        
        // 月の始まりを取得
        components.day = 1
        guard let startOfMonth = calendar.date(from: components) else { return }
        
        // 日ごとのデータを集計
        for offset in 0..<daysInMonth {
            guard let date = calendar.date(
                byAdding: .day,
                value: offset,
                to: startOfMonth
            ) else { continue }
            
            // データポイントの準備
            let alcoholGrams: Double
            let spending: Double
            let count: Int
            
            // 日ごとのデータ
            let dayRecords = drinkDataManager.getDrinkRecords(for: date)
            alcoholGrams = dayRecords.reduce(0) { $0 + $1.pureAlcoholGrams }
            spending = dayRecords.reduce(0) { $0 + ($1.price ?? 0) }
            count = dayRecords.count
            
            // データポイントを作成
            let dataPoint = MonthlyStatData(
                day: calendar.component(.day, from: date),
                date: date,
                alcoholGrams: alcoholGrams,
                spending: spending,
                count: count,
                isAlcoholFreeDay: alcoholGrams == 0
            )
            
            monthlyStats.append(dataPoint)
        }
        
        // 日付順にソート
        monthlyData = monthlyStats.sorted(by: { $0.date < $1.date })
    }
    
    // 日付を変更
    func changeDate(_ date: Date) {
        selectedDate = date
        updateData()
    }
    
    // 統計データ取得
    func getStatistics() -> Statistics? {
        // 現在選択されている月の記録を取得
        let records = drinkDataManager.getMonthlyRecords(containing: selectedDate)
        
        if records.isEmpty {
            return nil
        }
        
        // 統計データの計算
        let totalAlcohol = records.reduce(0) { $0 + $1.pureAlcoholGrams }
        let totalSpending = records.reduce(0) { $0 + ($1.price ?? 0) }
        let drinkCount = records.count
        
        // 飲酒タイプごとの内訳
        var drinkTypeBreakdown: [DrinkTypeBreakdown] = []
        let groupedByType = Dictionary(grouping: records, by: { $0.drinkType })
        
        for (type, typeRecords) in groupedByType {
            let typeAlcohol = typeRecords.reduce(0) { $0 + $1.pureAlcoholGrams }
            let typeSpending = typeRecords.reduce(0) { $0 + ($1.price ?? 0) }
            let typeCount = typeRecords.count
            let percentage = totalAlcohol > 0 ? (typeAlcohol / totalAlcohol) * 100 : 0
            
            drinkTypeBreakdown.append(
                DrinkTypeBreakdown(
                    type: type,
                    percentage: percentage,
                    alcoholGrams: typeAlcohol,
                    spending: typeSpending,
                    count: typeCount
                )
            )
        }
        
        // 最大値と最小値の日を検出
        let maxAlcoholDay = records.max(by: { $0.pureAlcoholGrams < $1.pureAlcoholGrams })?.date
        let maxSpendingDay = records.max(by: { ($0.price ?? 0) < ($1.price ?? 0) })?.date
        
        // 休肝日の数
        let alcoholFreeDays = calculateAlcoholFreeDays()
        
        return Statistics(
            totalAlcohol: totalAlcohol,
            totalSpending: totalSpending,
            drinkCount: drinkCount,
            averageAlcoholPerDay: calculateAveragePerDay(totalAlcohol),
            averageSpendingPerDay: calculateAveragePerDay(totalSpending),
            drinkTypeBreakdown: drinkTypeBreakdown.sorted(by: { $0.alcoholGrams > $1.alcoholGrams }),
            maxAlcoholDay: maxAlcoholDay,
            maxSpendingDay: maxSpendingDay,
            alcoholFreeDays: alcoholFreeDays
        )
    }
    
    // 平均値の計算（日あたり）
    private func calculateAveragePerDay(_ total: Double) -> Double {
        // 月の日数を動的に計算
        let calendar = Calendar.current
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        
        return total / Double(daysInMonth)
    }
    
    // 休肝日の数を計算
    private func calculateAlcoholFreeDays() -> Int {
        // 選択した月の全日を調べる
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month], from: selectedDate)
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 30
        
        components.day = 1
        guard let startOfMonth = calendar.date(from: components) else { return 0 }
        
        var alcoholFreeDays = 0
        
        for offset in 0..<daysInMonth {
            guard let date = calendar.date(byAdding: .day, value: offset, to: startOfMonth) else { continue }
            
            if drinkDataManager.isAlcoholFreeDay(date) {
                alcoholFreeDays += 1
            }
        }
        
        return alcoholFreeDays
    }
    
    // 節約額の計算（予算と比較）
    func calculateSavings() -> Double? {
        guard let budget = weeklyBudget else { return nil }
        
        let actualSpending = drinkDataManager.getMonthlyTotalSpending(containing: selectedDate)
        // 月単位の予算（週間予算の4.33倍）
        return SavingsCalculator.calculateSavings(budget: budget * 4.33, actualSpending: actualSpending)
    }
    
    // 時間枠の列挙型
    enum TimeFrame: String, CaseIterable {
        case month = "月"
    }
    
    // データ種類の列挙型
    enum DataType: String, CaseIterable {
        case alcohol = "アルコール量"
        case spending = "支出"
        case count = "回数"
    }
    
    // 統計データの構造体
    struct Statistics {
        let totalAlcohol: Double
        let totalSpending: Double
        let drinkCount: Int
        let averageAlcoholPerDay: Double
        let averageSpendingPerDay: Double
        let drinkTypeBreakdown: [DrinkTypeBreakdown]
        let maxAlcoholDay: Date?
        let maxSpendingDay: Date?
        let alcoholFreeDays: Int
    }
    
    // 飲酒タイプごとの内訳
    struct DrinkTypeBreakdown {
        let type: DrinkType
        let percentage: Double
        let alcoholGrams: Double
        let spending: Double
        let count: Int
    }
    
    // 月単位の統計データ
    struct MonthlyStatData: Identifiable {
        let id = UUID()
        let day: Int
        let date: Date
        let alcoholGrams: Double
        let spending: Double
        let count: Int
        let isAlcoholFreeDay: Bool
    }
}
