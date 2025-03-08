import Foundation
import Combine
import SwiftUI

class StatisticsViewModel: ObservableObject {
    // データ
    @Published var dailyData: [DailyStatData] = []
    @Published var weeklyData: [WeeklyStatData] = []
    @Published var monthlyData: [MonthlyStatData] = []
    
    // 設定
    @Published var selectedTimeFrame: TimeFrame = .week
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
        switch selectedTimeFrame {
        case .day:
            updateDailyData()
        case .week:
            updateWeeklyData()
        case .month:
            updateMonthlyData()
        case .year:
            updateMonthlyData(forYear: true)
        }
    }
    
    // 日別データの更新（最近の24時間）
    private func updateDailyData() {
        let calendar = Calendar.current
        let now = Date()
        var hourlyData: [DailyStatData] = []
        
        // 過去24時間分のデータを集計
        for hourOffset in 0..<24 {
            guard let hourDate = calendar.date(
                byAdding: .hour,
                value: -hourOffset,
                to: now
            ) else { continue }
            
            // その時間帯の記録を取得
            let hourStart = calendar.date(
                bySettingHour: calendar.component(.hour, from: hourDate),
                minute: 0,
                second: 0,
                of: hourDate
            ) ?? hourDate
            
            let hourEnd = calendar.date(
                byAdding: .hour,
                value: 1,
                to: hourStart
            ) ?? hourStart
            
            // この時間帯の記録をフィルタリング
            let hourlyRecords = drinkDataManager.drinkRecords.filter { record in
                record.date >= hourStart && record.date < hourEnd
            }
            
            // 時間ごとの集計データ
            let alcoholGrams = hourlyRecords.reduce(0) { $0 + $1.pureAlcoholGrams }
            let spending = hourlyRecords.reduce(0) { $0 + ($1.price ?? 0) }
            let count = hourlyRecords.count
            
            // データポイントを作成
            let dataPoint = DailyStatData(
                hour: calendar.component(.hour, from: hourDate),
                date: hourDate,
                alcoholGrams: alcoholGrams,
                spending: spending,
                count: count
            )
            
            hourlyData.append(dataPoint)
        }
        
        // 時間順にソート
        dailyData = hourlyData.sorted(by: { $0.date < $1.date })
    }
    
    // 週間データの更新（過去7日間）
    private func updateWeeklyData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var dailyStats: [WeeklyStatData] = []
        
        // 過去7日分のデータを集計
        for dayOffset in 0..<7 {
            guard let date = calendar.date(
                byAdding: .day,
                value: -dayOffset,
                to: today
            ) else { continue }
            
            // この日の記録を取得
            let dayRecords = drinkDataManager.getDrinkRecords(for: date)
            
            // 日ごとの集計データ
            let alcoholGrams = dayRecords.reduce(0) { $0 + $1.pureAlcoholGrams }
            let spending = dayRecords.reduce(0) { $0 + ($1.price ?? 0) }
            let count = dayRecords.count
            
            // データポイントを作成
            let dataPoint = WeeklyStatData(
                dayOfWeek: calendar.component(.weekday, from: date),
                date: date,
                alcoholGrams: alcoholGrams,
                spending: spending,
                count: count,
                isAlcoholFreeDay: alcoholGrams == 0
            )
            
            dailyStats.append(dataPoint)
        }
        
        // 日付順にソート
        weeklyData = dailyStats.sorted(by: { $0.date < $1.date })
    }
    
    // 月間データの更新（現在の月の日ごとのデータ）
    private func updateMonthlyData(forYear: Bool = false) {
        let calendar = Calendar.current
        let today = Date()
        var monthlyStats: [MonthlyStatData] = []
        
        // 日数または月数を決定
        let range: Int
        let component: Calendar.Component
        
        if forYear {
            range = 12 // 12ヶ月
            component = .month
        } else {
            // 現在の月の日数を取得
            let daysInMonth = calendar.range(of: .day, in: .month, for: today)?.count ?? 30
            range = daysInMonth
            component = .day
        }
        
        // 現在の月の始まりを取得
        var components = calendar.dateComponents([.year, .month], from: today)
        components.day = 1
        guard let startOfMonth = calendar.date(from: components) else { return }
        
        // 日ごとまたは月ごとのデータを集計
        for offset in 0..<range {
            guard let date = calendar.date(
                byAdding: component,
                value: forYear ? -offset : offset,
                to: forYear ? today : startOfMonth
            ) else { continue }
            
            // データポイントの準備
            let alcoholGrams: Double
            let spending: Double
            let count: Int
            
            if forYear {
                // 月ごとのデータ
                let monthRecords = drinkDataManager.getMonthlyRecords(containing: date)
                alcoholGrams = monthRecords.reduce(0) { $0 + $1.pureAlcoholGrams }
                spending = monthRecords.reduce(0) { $0 + ($1.price ?? 0) }
                count = monthRecords.count
            } else {
                // 日ごとのデータ
                let dayRecords = drinkDataManager.getDrinkRecords(for: date)
                alcoholGrams = dayRecords.reduce(0) { $0 + $1.pureAlcoholGrams }
                spending = dayRecords.reduce(0) { $0 + ($1.price ?? 0) }
                count = dayRecords.count
            }
            
            // データポイントを作成
            let dataPoint = MonthlyStatData(
                day: forYear ? calendar.component(.month, from: date) : calendar.component(.day, from: date),
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
    
    // 時間枠を変更
    func changeTimeFrame(_ timeFrame: TimeFrame) {
        selectedTimeFrame = timeFrame
        updateData()
    }
    
    // データ種類を変更
    func changeDataType(_ dataType: DataType) {
        selectedDataType = dataType
    }
    
    // 日付を変更
    func changeDate(_ date: Date) {
        selectedDate = date
        updateData()
    }
    
    // 統計データ取得
    func getStatistics() -> Statistics? {
        // 現在選択されている期間の記録を取得
        let records: [DrinkRecord]
        
        switch selectedTimeFrame {
        case .day:
            records = drinkDataManager.getDrinkRecords(for: selectedDate)
        case .week:
            records = drinkDataManager.getWeeklyRecords(endingAt: selectedDate)
        case .month:
            records = drinkDataManager.getMonthlyRecords(containing: selectedDate)
        case .year:
            // 年間データは月間データの12ヶ月分
            let calendar = Calendar.current
            guard let startOfYear = calendar.date(
                from: calendar.dateComponents([.year], from: selectedDate)
            ) else {
                return nil  // nil を返す
            }
            
            guard let endOfYear = calendar.date(
                byAdding: .year,
                value: 1,
                to: startOfYear
            ) else {
                return nil  // nil を返す
            }
            
            records = drinkDataManager.drinkRecords.filter { record in
                record.date >= startOfYear && record.date < endOfYear
            }
        }
        
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
        let alcoholFreeDays = calculateAlcoholFreeDays(for: selectedTimeFrame)
        
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
        let divisor: Double
        
        switch selectedTimeFrame {
        case .day:
            divisor = 1
        case .week:
            divisor = 7
        case .month:
            // 月の日数を動的に計算
            let calendar = Calendar.current
            if let range = calendar.range(of: .day, in: .month, for: selectedDate) {
                divisor = Double(range.count)
            } else {
                divisor = 30 // デフォルト
            }
        case .year:
            divisor = 365
        }
        
        return total / divisor
    }
    
    // 休肝日の数を計算
    private func calculateAlcoholFreeDays(for timeFrame: TimeFrame) -> Int {
        switch timeFrame {
        case .day:
            return drinkDataManager.isAlcoholFreeDay(selectedDate) ? 1 : 0
        case .week:
            return drinkDataManager.getAlcoholFreeDaysCount(in: .week)
        case .month:
            return drinkDataManager.getAlcoholFreeDaysCount(in: .month)
        case .year:
            // 年間のデータは計算が重いので、概算として
            let calendar = Calendar.current
            guard let startOfYear = calendar.date(
                from: calendar.dateComponents([.year], from: selectedDate)
            ) else { return 0 }
            
            let daysSinceStartOfYear = calendar.dateComponents([.day], from: startOfYear, to: Date()).day ?? 0
            
            // 記録がある日をカウント
            let daysWithRecords = Set(drinkDataManager.drinkRecords.map {
                calendar.startOfDay(for: $0.date)
            }).count
            
            // ざっくりとした計算
            return max(0, min(daysSinceStartOfYear, 365) - daysWithRecords)
        }
    }
    
    // 節約額の計算（予算と比較）
    func calculateSavings() -> Double? {
        guard let budget = weeklyBudget else { return nil }
        
        let actualSpending: Double
        switch selectedTimeFrame {
        case .day:
            actualSpending = drinkDataManager.getDailyTotalSpending(for: selectedDate)
            // 日単位の予算（週間予算の1/7）
            return SavingsCalculator.calculateSavings(budget: budget / 7, actualSpending: actualSpending)
        case .week:
            actualSpending = drinkDataManager.getWeeklyTotalSpending(endingAt: selectedDate)
            return SavingsCalculator.calculateSavings(budget: budget, actualSpending: actualSpending)
        case .month:
            actualSpending = drinkDataManager.getMonthlyTotalSpending(containing: selectedDate)
            // 月単位の予算（週間予算の4.33倍）
            return SavingsCalculator.calculateSavings(budget: budget * 4.33, actualSpending: actualSpending)
        case .year:
            // 年間データの場合は概算
            let monthlySpending = monthlyData.reduce(0) { $0 + $1.spending }
            return SavingsCalculator.calculateSavings(budget: budget * 52, actualSpending: monthlySpending)
        }
    }
    
    // 時間枠の列挙型
    enum TimeFrame: String, CaseIterable {
        case day = "日"
        case week = "週"
        case month = "月"
        case year = "年"
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
    
    // 日単位の統計データ
    struct DailyStatData: Identifiable {
        let id = UUID()
        let hour: Int
        let date: Date
        let alcoholGrams: Double
        let spending: Double
        let count: Int
    }
    
    // 週単位の統計データ
    struct WeeklyStatData: Identifiable {
        let id = UUID()
        let dayOfWeek: Int
        let date: Date
        let alcoholGrams: Double
        let spending: Double
        let count: Int
        let isAlcoholFreeDay: Bool
        
        // 曜日名を取得
        var dayName: String {
            let formatter = DateFormatter()
            formatter.dateFormat = "E"
            return formatter.string(from: date)
        }
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
