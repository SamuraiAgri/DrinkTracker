import Foundation

class SavingsCalculator {
    
    // 特定期間の節約額を計算（予算と実際の支出から）
    static func calculateSavings(budget: Double, actualSpending: Double) -> Double {
        return max(0, budget - actualSpending)
    }
    
    // 飲酒量の削減による健康改善の経済的価値を推定
    static func estimateHealthSavings(reducedAlcoholGrams: Double) -> Double {
        // 1年間の飲酒関連医療費の平均削減額を推定
        // 研究によると、過度の飲酒は年間平均で約2~5万円の医療費増加と関連
        
        // 週間換算の削減量に基づいて計算（年間への換算）
        let annualReducedGrams = reducedAlcoholGrams * 52
        
        // 1000g削減あたり、2000円の医療費削減と仮定
        let healthSavings = annualReducedGrams / 1000 * 2000
        
        // 日割り計算（年間推定値の日割り）
        return healthSavings / 365
    }
    
    // 飲酒削減による生産性向上の経済価値を推定
    static func estimateProductivityGains(reducedAlcoholGrams: Double) -> Double {
        // 研究では、過度の飲酒は年間労働生産性の1-3%低下と関連
        // 年収500万円の人の場合、約5-15万円の生産性損失
        
        // 簡易計算: 年収500万円と仮定し、飲酒量削減に応じた生産性向上を推定
        let avgAnnualIncome = 5000000.0 // 円
        let dailyIncome = avgAnnualIncome / 365
        
        // 1日あたりの飲酒量削減が30g（約3ドリンク）を超えると、生産性が0.5%向上すると仮定
        let productivityImprovement = min(0.03, reducedAlcoholGrams / 30 * 0.005)
        
        return dailyIncome * productivityImprovement
    }
    
    // 長期的な節約額の予測
    static func projectLongTermSavings(
        weeklySpending: Double,
        reductionTarget: Double,
        timeframeMonths: Int
    ) -> Double {
        // 週間の削減額
        let weeklyReduction = weeklySpending * reductionTarget
        
        // 月間換算
        let monthlyReduction = weeklyReduction * 4.33
        
        // 指定期間の累積削減額
        return monthlyReduction * Double(timeframeMonths)
    }
    
    // 飲酒習慣を変えた場合の予測的な節約額を計算
    static func calculateProjectedSavings(
        currentRecords: [DrinkRecord],
        targetReductionPercent: Double
    ) -> ProjectedSavings {
        // 現在の平均的な支出を計算
        let totalSpending = currentRecords.reduce(0) { $0 + ($1.price ?? 0) }
        let recordsWithPrice = currentRecords.filter { $0.price != nil }
        
        guard !recordsWithPrice.isEmpty else {
            return ProjectedSavings(weekly: 0, monthly: 0, yearly: 0)
        }
        
        let averageDailySpending = totalSpending / Double(currentRecords.count)
        
        // 削減率に基づく削減額
        let reducedDailySpending = averageDailySpending * (targetReductionPercent / 100)
        
        // 期間ごとの節約額
        let weeklySavings = reducedDailySpending * 7
        let monthlySavings = reducedDailySpending * 30
        let yearlySavings = reducedDailySpending * 365
        
        return ProjectedSavings(
            weekly: weeklySavings,
            monthly: monthlySavings,
            yearly: yearlySavings
        )
    }
    
    // 飲酒量削減による推定カロリー削減量
    static func estimateCalorieReduction(reducedAlcoholGrams: Double) -> Double {
        // アルコール1gあたり約7kcal
        return reducedAlcoholGrams * 7.0
    }
    
    // 削減カロリーから体重減少を推定
    static func estimateWeightLoss(reducedCalories: Double, timeframeInDays: Int) -> Double {
        // 体脂肪1kgは約7,700kcalに相当
        let caloriesPerKg = 7700.0
        
        // 期間内の総カロリー削減量
        let totalCalorieReduction = reducedCalories * Double(timeframeInDays)
        
        // 推定体重減少量（kg）
        return totalCalorieReduction / caloriesPerKg
    }
    
    // 予測節約額データ構造
    struct ProjectedSavings {
        let weekly: Double
        let monthly: Double
        let yearly: Double
    }
}
