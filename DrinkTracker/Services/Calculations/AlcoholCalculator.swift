import Foundation

class AlcoholCalculator {
    
    // ボディウォーターによるおおよそのBAC（血中アルコール濃度）計算
    // Widmarkの式をベースにした計算
    static func estimateBAC(
        alcoholGrams: Double,
        gender: UserProfile.Gender,
        weight: Double,
        hoursSinceDrinking: Double
    ) -> Double {
        // アルコール分布比率（男性は約0.68、女性は約0.55）
        let distributionRatio: Double = {
            switch gender {
            case .male:
                return 0.68
            case .female:
                return 0.55
            case .notSpecified:
                return 0.615 // 中間値
            }
        }()
        
        // アルコール代謝速度（約0.015%/時間）
        let metabolismRate = 0.015
        
        // BAC計算（単位: %）
        let bac = (alcoholGrams / (weight * 1000 * distributionRatio) * 100) - (metabolismRate * hoursSinceDrinking)
        
        // 0未満にならないよう調整
        return max(0, bac)
    }
    
    // BACに基づいた影響レベルの取得
    static func getIntoxicationLevel(bac: Double) -> IntoxicationLevel {
        switch bac {
        case 0..<0.03:
            return .none
        case 0.03..<0.06:
            return .mild
        case 0.06..<0.10:
            return .moderate
        case 0.10..<0.15:
            return .significant
        case 0.15..<0.25:
            return .severe
        default:
            return .extreme
        }
    }
    
    // アルコール分解までの推定時間（時間）
    static func estimateSoberingTime(alcoholGrams: Double) -> Double {
        // 平均的な肝臓は1時間あたり約8-10gのアルコールを分解
        // やや保守的に7g/時として計算
        let metabolismRate = 7.0 // g/時
        return alcoholGrams / metabolismRate
    }
    
    // 飲酒後の運転可能時間を推定
    static func estimateSafeDrivingTime(
        alcoholGrams: Double,
        gender: UserProfile.Gender,
        weight: Double
    ) -> Double {
        // 法定基準: BAC 0.03%未満
        let legalLimit = 0.03
        
        // Widmarkの式を逆算して、BAC < 0.03になるまでの時間を求める
        let distributionRatio: Double = {
            switch gender {
            case .male:
                return 0.68
            case .female:
                return 0.55
            case .notSpecified:
                return 0.615
            }
        }()
        
        let initialBAC = alcoholGrams / (weight * 1000 * distributionRatio) * 100
        let metabolismRate = 0.015 // %/時間
        
        // 法定基準を下回るまでに必要な時間
        return max(0, (initialBAC - legalLimit) / metabolismRate)
    }
    
    // 週間摂取量に基づく健康リスク評価
    static func assessHealthRisk(weeklyAlcoholGrams: Double) -> HealthRiskLevel {
        // WHO/日本の厚生労働省ガイドラインベース
        switch weeklyAlcoholGrams {
        case 0..<70: // 週に純アルコール70g未満（男性）
            return .low
        case 70..<140: // 週に純アルコール70-140g（男性）
            return .moderate
        case 140..<280: // 週に純アルコール140-280g
            return .high
        default: // 週に純アルコール280g以上
            return .veryHigh
        }
    }
    
    // カロリー計算
    static func calculateCalories(alcoholGrams: Double) -> Double {
        // アルコールは1gあたり約7kcal
        return alcoholGrams * 7.0
    }
    
    // 飲酒記録に基づく推奨水分摂取量（ml）
    static func recommendedWaterIntake(alcoholGrams: Double) -> Double {
        // 一般的なガイドライン: アルコール飲料1杯につき水1杯（約250ml）
        // ここでは純アルコール10gにつき250mlの水として計算
        return (alcoholGrams / 10.0) * 250.0
    }
    
    // 酔いレベルの定義
    enum IntoxicationLevel: String, CaseIterable {
        case none = "影響なし"
        case mild = "軽度"
        case moderate = "中度"
        case significant = "顕著"
        case severe = "重度"
        case extreme = "危険"
        
        var description: String {
            switch self {
            case .none:
                return "ほとんど影響がない状態です。"
            case .mild:
                return "わずかにリラックスした感覚。"
            case .moderate:
                return "穏やかな酔い感。反応速度がやや低下。"
            case .significant:
                return "顕著な酔い。判断力と運動機能の低下。"
            case .severe:
                return "著しい酩酊。記憶障害や嘔吐の可能性。"
            case .extreme:
                return "危険な酩酊レベル。意識喪失のリスク。医療的注意が必要です。"
            }
        }
        
        var recommendation: String {
            switch self {
            case .none, .mild:
                return "水分をしっかり取りましょう。"
            case .moderate:
                return "水分補給と食事を取ることをお勧めします。"
            case .significant:
                return "これ以上の飲酒は控え、水を飲み、休息を取りましょう。"
            case .severe, .extreme:
                return "すぐに飲酒を中止し、十分な水分と休息を取ってください。必要なら医療機関に相談してください。"
            }
        }
    }
    
    // 健康リスクレベルの定義
    enum HealthRiskLevel: String, CaseIterable {
        case low = "低リスク"
        case moderate = "中程度リスク"
        case high = "高リスク"
        case veryHigh = "非常に高いリスク"
        
        var description: String {
            switch self {
            case .low:
                return "健康への影響は比較的少ないでしょう。"
            case .moderate:
                return "長期的な健康リスクが増加する可能性があります。"
            case .high:
                return "肝機能障害などの健康リスクが高まっています。"
            case .veryHigh:
                return "深刻な健康リスクがあり、飲酒量の削減が強く推奨されます。"
            }
        }
        
        var recommendation: String {
            switch self {
            case .low:
                return "現在の飲酒パターンを維持しつつ、定期的な休肝日を設けましょう。"
            case .moderate:
                return "週に2-3日の休肝日を設け、1日あたりの飲酒量を減らすことを検討してください。"
            case .high:
                return "飲酒量の大幅な削減と週に少なくとも3-4日の休肝日が推奨されます。"
            case .veryHigh:
                return "医療専門家に相談し、飲酒量を大幅に削減するための支援を求めることを強くお勧めします。"
            }
        }
    }
}
