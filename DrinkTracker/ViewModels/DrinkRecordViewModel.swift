import Foundation
import Combine

class DrinkRecordViewModel: ObservableObject {
    // 現在の入力値
    @Published var selectedDrinkType: DrinkType = .beer
    @Published var volume: Double = 350.0
    @Published var alcoholPercentage: Double = 5.0
    @Published var price: String = ""
    @Published var date: Date = Date()
    @Published var location: String = ""
    @Published var note: String = ""
    @Published var isFavorite: Bool = false
    
    // 編集モード関連
    @Published var isEditMode: Bool = false
    private var existingDrinkId: UUID?
    
    // サービス
    public let drinkDataManager: DrinkDataManager
    
    // フォームの進行状態
    @Published var currentStep: RecordStep = .drinkType
    
    // ナビゲーション制御
    @Published var shouldDismiss: Bool = false
    @Published var savedSuccessMessage: String = ""
    
    // よく使う飲み物のプリセット（場所で分類）
    @Published var favoritePresets: [DrinkRecord] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    init(drinkDataManager: DrinkDataManager, existingDrink: DrinkRecord? = nil, initialDate: Date? = nil) {
        // 最初にプロパティを初期化
        self.drinkDataManager = drinkDataManager
        
        // 既存の記録を編集する場合
        if let drink = existingDrink {
            self.isEditMode = true
            self.existingDrinkId = drink.id
            
            // 既存の値をフォームにセット
            self.selectedDrinkType = drink.drinkType
            self.volume = drink.volume
            self.alcoholPercentage = drink.alcoholPercentage
            self.price = drink.price != nil ? String(format: "%.0f", drink.price!) : ""
            self.date = drink.date
            self.location = drink.location ?? ""
            self.note = drink.note ?? ""
            self.isFavorite = drink.isFavorite
        } else {
            // デフォルト値をセット
            resetToDefaults()
            // 初期日付が指定されている場合は設定
            // 日付部分はinitialDateを使用し、時刻部分は現在時刻を設定
            if let initialDate = initialDate {
                let calendar = Calendar.current
                let dateComponents = calendar.dateComponents([.year, .month, .day], from: initialDate)
                let timeComponents = calendar.dateComponents([.hour, .minute, .second], from: Date())
                
                var combinedComponents = dateComponents
                combinedComponents.hour = timeComponents.hour
                combinedComponents.minute = timeComponents.minute
                combinedComponents.second = timeComponents.second
                
                if let combinedDate = calendar.date(from: combinedComponents) {
                    self.date = combinedDate
                } else {
                    self.date = initialDate
                }
            }
        }
        
        // お気に入りのプリセットを読み込み
        loadFavoritePresets()
        
        // 飲み物の種類を変更したときに、デフォルトのアルコール度数とボリュームを更新
        $selectedDrinkType
            .sink { [weak self] drinkType in
                if !self!.isEditMode {
                    self?.alcoholPercentage = drinkType.defaultPercentage
                    self?.volume = drinkType.defaultSize
                }
            }
            .store(in: &cancellables)
    }
    
    // よく使う飲み物のプリセットを読み込む
    private func loadFavoritePresets() {
        // お気に入りマークがついたものを取得
        favoritePresets = drinkDataManager.drinkRecords.filter { $0.isFavorite }
    }
    
    // 次のステップに進む
    func nextStep() {
        switch currentStep {
        case .drinkType:
            currentStep = .amount
        case .amount:
            currentStep = .details
        case .details:
            saveRecord()
        }
    }
    
    // 前のステップに戻る
    func previousStep() {
        switch currentStep {
        case .drinkType:
            // 最初のステップなので何もしない
            break
        case .amount:
            currentStep = .drinkType
        case .details:
            currentStep = .amount
        }
    }
    
    // 記録をリセット
    func resetToDefaults() {
        selectedDrinkType = .beer
        volume = selectedDrinkType.defaultSize
        alcoholPercentage = selectedDrinkType.defaultPercentage
        price = ""
        // 現在の日時をそのまま使用（時刻情報も保持）
        date = Date()
        location = ""
        note = ""
        isFavorite = false
        currentStep = .drinkType
    }
    
    // プリセットを選択
    func selectPreset(_ preset: DrinkRecord) {
        selectedDrinkType = preset.drinkType
        volume = preset.volume
        alcoholPercentage = preset.alcoholPercentage
        price = preset.price != nil ? String(format: "%.0f", preset.price!) : ""
        location = preset.location ?? ""
        currentStep = .details // 詳細画面に飛ばす
    }
    
    // 記録を保存
    func saveRecord() {
        // 価格を数値に変換
        let priceValue = Double(price.replacingOccurrences(of: ",", with: ""))
        
        // ユーザーがDatePickerで選択した日時をそのまま使用
        // 時刻情報はBAC計算に必要なため保持する
        let recordDate = date
        
        // 新しい記録を作成
        let record = DrinkRecord(
            id: existingDrinkId ?? UUID(),
            date: recordDate,
            drinkType: selectedDrinkType,
            volume: volume,
            alcoholPercentage: alcoholPercentage,
            price: priceValue,
            location: location.isEmpty ? nil : location,
            note: note.isEmpty ? nil : note,
            isFavorite: isFavorite
        )
        
        // データマネージャーに保存
        if isEditMode {
            drinkDataManager.updateDrinkRecord(record)
        } else {
            drinkDataManager.addDrinkRecord(record)
        }
        
        // お気に入りに追加された場合はプリセットを更新
        if isFavorite {
            loadFavoritePresets()
        }
        
        // 保存成功メッセージを生成
        let dailyTotal = drinkDataManager.getDailyTotalAlcohol()
        savedSuccessMessage = "記録しました！今日のアルコール摂取量: \(String(format: "%.1f", dailyTotal))g"
        
        // インタースティシャル広告を表示（頻度制限付き）
        InterstitialAdManager.shared.showAdIfAvailable()
        
        // 画面を閉じる
        shouldDismiss = true
    }
    
    // 記録フォームのステップ
    enum RecordStep: String {
        case drinkType
        case amount
        case details
    }
    
    // 純アルコール量のリアルタイム計算
    var pureAlcoholGrams: Double {
        let alcoholDensity = 0.8 // アルコールの密度（g/ml）
        return volume * (alcoholPercentage / 100) * alcoholDensity
    }
    
    // カロリーの計算
    var calories: Double {
        return pureAlcoholGrams * 7.0
    }
    
    // 標準ドリンク数に換算
    var standardDrinks: Double {
        return pureAlcoholGrams / AppConstants.Drinking.standardDrinkGrams
    }
    
    // 飲み物のサイズ選択肢を取得
    func getSizesForDrinkType() -> [Double] {
        switch selectedDrinkType {
        case .beer:
            return [250, 350, 500, 633]
        case .wine:
            return [125, 150, 175, 250]
        case .spirits:
            return [30, 45, 60]
        case .sake:
            return [90, 180, 270]
        case .cocktail:
            return [200, 250, 300, 350]
        case .highball:
            return [250, 350, 500, 630]
        case .chuhai:
            return [250, 350, 500, 630]
        case .other:
            return [200, 250, 300, 350]
        }
    }
    
    // アルコール度数の選択肢を取得
    func getPercentagesForDrinkType() -> [Double] {
        switch selectedDrinkType {
        case .beer:
            return [3.0, 4.0, 5.0, 5.5, 7.0, 8.0]
        case .wine:
            return [9.0, 11.0, 12.0, 13.0, 14.0, 15.0]
        case .spirits:
            return [35.0, 40.0, 43.0, 45.0, 50.0]
        case .sake:
            return [13.0, 14.0, 15.0, 16.0, 17.0]
        case .cocktail:
            return [4.0, 6.0, 8.0, 10.0, 12.0, 15.0]
        case .highball:
            return [5.0, 7.0, 9.0, 12.0]
        case .chuhai:
            return [3.0, 4.0, 5.0, 6.0, 7.0, 9.0]
        case .other:
            return [3.0, 5.0, 8.0, 12.0, 15.0, 20.0, 30.0, 40.0]
        }
    }
}
