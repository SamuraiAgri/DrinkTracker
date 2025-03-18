import Foundation
import Combine

class DrinkPresetManager: ObservableObject {
    @Published public var drinkPresets: [DrinkPreset] = []
    
    private let storageKey = "drinkPresets"
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        loadData()
        
        // データ変更時の自動保存
        $drinkPresets
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] _ in
                self?.saveData()
            }
            .store(in: &cancellables)
        
        // 初回起動時にデフォルトプリセットを作成
        if drinkPresets.isEmpty {
            createDefaultPresets()
        }
    }
    
    // データをUserDefaultsから読み込む
    private func loadData() {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return }
        
        do {
            let decoder = JSONDecoder()
            drinkPresets = try decoder.decode([DrinkPreset].self, from: data)
        } catch {
            print("Error loading drink presets: \(error)")
        }
    }
    
    // データをUserDefaultsに保存
    private func saveData() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(drinkPresets)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Error saving drink presets: \(error)")
        }
    }
    
    // プリセットを追加
    func addPreset(_ preset: DrinkPreset) {
        drinkPresets.append(preset)
    }
    
    // プリセットを更新
    func updatePreset(_ preset: DrinkPreset) {
        if let index = drinkPresets.firstIndex(where: { $0.id == preset.id }) {
            drinkPresets[index] = preset
        }
    }
    
    // プリセットを削除
    func deletePreset(_ id: UUID) {
        drinkPresets.removeAll(where: { $0.id == id })
    }
    
    // ドリンクレコードからプリセットを作成
    func createPresetFromRecord(_ record: DrinkRecord, name: String) -> DrinkPreset {
        return DrinkPreset(
            name: name,
            drinkType: record.drinkType,
            volume: record.volume,
            alcoholPercentage: record.alcoholPercentage,
            price: record.price,
            location: record.location,
            note: record.note
        )
    }
    
    // デフォルトのプリセットを作成
    private func createDefaultPresets() {
        let defaults = [
            DrinkPreset(
                name: "生ビール 中ジョッキ",
                drinkType: .beer,
                volume: 500,
                alcoholPercentage: 5.0,
                price: 600,
                isDefault: true
            ),
            DrinkPreset(
                name: "缶ビール",
                drinkType: .beer,
                volume: 350,
                alcoholPercentage: 5.0,
                price: 250,
                isDefault: true
            ),
            DrinkPreset(
                name: "ワイングラス",
                drinkType: .wine,
                volume: 150,
                alcoholPercentage: 12.0,
                price: 700,
                isDefault: true
            ),
            DrinkPreset(
                name: "ハイボール",
                drinkType: .highball,
                volume: 350,
                alcoholPercentage: 7.0,
                price: 500,
                isDefault: true
            ),
            DrinkPreset(
                name: "日本酒 1合",
                drinkType: .sake,
                volume: 180,
                alcoholPercentage: 15.0,
                price: 500,
                isDefault: true
            )
        ]
        
        defaults.forEach { addPreset($0) }
    }
}
