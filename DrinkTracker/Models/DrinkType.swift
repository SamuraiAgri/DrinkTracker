import Foundation
import SwiftUI

enum DrinkType: String, CaseIterable, Codable, Identifiable {
    case beer = "ビール"
    case wine = "ワイン"
    case spirits = "蒸留酒"
    case sake = "日本酒"
    case cocktail = "カクテル"
    case other = "その他"
    
    var id: String { self.rawValue }
    
    var defaultPercentage: Double {
        switch self {
        case .beer:
            return AppConstants.Drinking.beerAlcoholPercentage
        case .wine:
            return AppConstants.Drinking.wineAlcoholPercentage
        case .spirits:
            return AppConstants.Drinking.spiritsAlcoholPercentage
        case .sake:
            return AppConstants.Drinking.sakeAlcoholPercentage
        case .cocktail:
            return AppConstants.Drinking.cocktailAlcoholPercentage
        case .other:
            return 5.0
        }
    }
    
    var defaultSize: Double {
        switch self {
        case .beer:
            return AppConstants.Drinking.beerDefaultSize
        case .wine:
            return AppConstants.Drinking.wineDefaultSize
        case .spirits:
            return AppConstants.Drinking.spiritsDefaultSize
        case .sake:
            return AppConstants.Drinking.sakeDefaultSize
        case .cocktail:
            return AppConstants.Drinking.cocktailDefaultSize
        case .other:
            return 250.0
        }
    }
    
    var color: Color {
        switch self {
        case .beer:
            return AppColors.beerColor
        case .wine:
            return AppColors.wineColor
        case .spirits:
            return AppColors.spiritsColor
        case .sake:
            return AppColors.sakeColor
        case .cocktail:
            return AppColors.cocktailColor
        case .other:
            return AppColors.secondary
        }
    }
    
    var iconName: String {
        switch self {
        case .beer:
            return "beer"
        case .wine:
            return "wine"
        case .spirits:
            return "spirits"
        case .sake:
            return "sake"
        case .cocktail:
            return "cocktail"
        case .other:
            return "other"
        }
    }
    
    var description: String {
        switch self {
        case .beer:
            return "一般的なビール、発泡酒、クラフトビールなど"
        case .wine:
            return "赤ワイン、白ワイン、ロゼ、スパークリングワインなど"
        case .spirits:
            return "ウイスキー、ジン、ウォッカ、ラム、テキーラなど"
        case .sake:
            return "日本酒、純米酒、本醸造酒、吟醸酒など"
        case .cocktail:
            return "カクテル、サワー、ハイボール、チューハイなど"
        case .other:
            return "その他のアルコール飲料"
        }
    }
    
    // 省略表示用の短い名前
    var shortName: String {
        switch self {
        case .beer:
            return "ビール"
        case .wine:
            return "ワイン"
        case .spirits:
            return "蒸留酒"
        case .sake:
            return "酒"
        case .cocktail:
            return "カクテル"
        case .other:
            return "その他"
        }
    }
}
