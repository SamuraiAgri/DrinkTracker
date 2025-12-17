import Foundation

struct DrinkPreset: Identifiable, Codable, Equatable {
    var id: UUID
    var name: String
    var drinkType: DrinkType
    var volume: Double // ml
    var alcoholPercentage: Double // %
    var price: Double? // 円
    var location: String?
    var note: String?
    var colorHex: String?
    var isDefault: Bool // デフォルトかどうか
    
    init(
        id: UUID = UUID(),
        name: String,
        drinkType: DrinkType,
        volume: Double,
        alcoholPercentage: Double? = nil,
        price: Double? = nil,
        location: String? = nil,
        note: String? = nil,
        colorHex: String? = nil,
        isDefault: Bool = false
    ) {
        self.id = id
        self.name = name
        self.drinkType = drinkType
        self.volume = volume
        self.alcoholPercentage = alcoholPercentage ?? drinkType.defaultPercentage
        self.price = price
        self.location = location
        self.note = note
        self.colorHex = colorHex
        self.isDefault = isDefault
    }
    
    // DrinkRecordに変換するヘルパーメソッド
    func toDrinkRecord(date: Date = Date()) -> DrinkRecord {
        // 日付を日の開始時刻にする（時刻情報をリセット）
        let calendar = Calendar.current
        let normalizedDate = calendar.startOfDay(for: date)
        
        return DrinkRecord(
            date: normalizedDate,
            drinkType: drinkType,
            volume: volume,
            alcoholPercentage: alcoholPercentage,
            price: price,
            location: location,
            note: note,
            isFavorite: false
        )
    }
}
