import Foundation
import Combine

class DrinkDataManager: ObservableObject {
    @Published var drinkRecords: [DrinkRecord] = []
    
    private let storageKey = AppConstants.StorageKeys.drinkRecords
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
        
        // drinkRecordsが変更されたら自動的に保存
        $drinkRecords
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveData()
            }
            .store(in: &cancellables)
    }
    
    // データをUserDefaultsから読み込む
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        
        do {
            let decoder = JSONDecoder()
            drinkRecords = try decoder.decode([DrinkRecord].self, from: data)
        } catch {
            print("Error loading drink records: \(error)")
        }
    }
    
    // データをUserDefaultsに保存
    private func saveData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(drinkRecords)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Error saving drink records: \(error)")
        }
    }
    
    // 飲み物を追加
    func addDrinkRecord(_ record: DrinkRecord) {
        drinkRecords.append(record)
    }
    
    // 飲み物を更新
    func updateDrinkRecord(_ record: DrinkRecord) {
        if let index = drinkRecords.firstIndex(where: { $0.id == record.id }) {
            drinkRecords[index] = record
        }
    }
    
    // 飲み物を削除
    func deleteDrinkRecord(_ id: UUID) {
        drinkRecords.removeAll(where: { $0.id == id })
    }
    
    // 日付で飲み物を取得
    func getDrinkRecords(for date: Date) -> [DrinkRecord] {
        return drinkRecords.recordsForDay(date)
    }
    
    // 週間データを取得
    func getWeeklyRecords(endingAt date: Date = Date()) -> [DrinkRecord] {
        return drinkRecords.recordsForWeek(endingAt: date)
    }
    
    // 月間データを取得
    func getMonthlyRecords(containing date: Date = Date()) -> [DrinkRecord] {
        return drinkRecords.recordsForMonth(containing: date)
    }
    
    // 日間の合計飲酒量（純アルコールg）
    func getDailyTotalAlcohol(for date: Date = Date()) -> Double {
        return drinkRecords.totalAlcoholForDay(date)
    }
    
    // 週間の合計飲酒量（純アルコールg）
    func getWeeklyTotalAlcohol(endingAt date: Date = Date()) -> Double {
        let weeklyRecords = getWeeklyRecords(endingAt: date)
        return weeklyRecords.reduce(0) { $0 + $1.pureAlcoholGrams }
    }
    
    // 月間の合計飲酒量（純アルコールg）
    func getMonthlyTotalAlcohol(containing date: Date = Date()) -> Double {
        let monthlyRecords = getMonthlyRecords(containing: date)
        return monthlyRecords.reduce(0) { $0 + $1.pureAlcoholGrams }
    }
    
    // 日間の総支出
    func getDailyTotalSpending(for date: Date = Date()) -> Double {
        return getDrinkRecords(for: date).reduce(0) { $0 + ($1.price ?? 0) }
    }
    
    // 週間の総支出
    func getWeeklyTotalSpending(endingAt date: Date = Date()) -> Double {
        return getWeeklyRecords(endingAt: date).reduce(0) { $0 + ($1.price ?? 0) }
    }
    
    // 月間の総支出
    func getMonthlyTotalSpending(containing date: Date = Date()) -> Double {
        return getMonthlyRecords(containing: date).reduce(0) { $0 + ($1.price ?? 0) }
    }
    
    // よく飲む種類の取得
    func getMostConsumedDrinkType(timeRange: TimeRange = .month) -> DrinkType? {
        let records: [DrinkRecord]
        
        switch timeRange {
        case .day:
            records = getDrinkRecords(for: Date())
        case .week:
            records = getWeeklyRecords()
        case .month:
            records = getMonthlyRecords()
        case .all:
            records = drinkRecords
        }
        
        guard !records.isEmpty else { return nil }
        
        let typeCount = Dictionary(grouping: records, by: { $0.drinkType })
            .mapValues { $0.count }
        
        return typeCount.max(by: { $0.value < $1.value })?.key
    }
    
    // 休肝日かどうかを判定
    func isAlcoholFreeDay(_ date: Date = Date()) -> Bool {
        return getDrinkRecords(for: date).isEmpty
    }
    
    // 過去の期間における休肝日の数を取得
    func getAlcoholFreeDaysCount(in timeRange: TimeRange = .month) -> Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        var daysInRange = 0
        var alcoholFreeDaysCount = 0
        
        switch timeRange {
        case .day:
            return isAlcoholFreeDay() ? 1 : 0
        case .week:
            daysInRange = 7
        case .month:
            daysInRange = 30
        case .all:
            if let oldestRecord = drinkRecords.min(by: { $0.date < $1.date }) {
                let oldestDate = calendar.startOfDay(for: oldestRecord.date)
                daysInRange = calendar.dateComponents([.day], from: oldestDate, to: today).day ?? 0
            } else {
                return 0
            }
        }
        
        for dayOffset in 0..<daysInRange {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            if isAlcoholFreeDay(date) {
                alcoholFreeDaysCount += 1
            }
        }
        
        return alcoholFreeDaysCount
    }
    
    // 時間範囲の列挙型
    enum TimeRange {
        case day
        case week
        case month
        case all
    }
}
