import SwiftUI

struct HealthIndicatorsView: View {
    @ObservedObject var viewModel: HealthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            Text("健康指標")
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: AppConstants.UI.standardPadding) {
                // Weekly alcohol consumption
                VStack(alignment: .leading, spacing: 4) {
                    Text("週間アルコール摂取量")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("\(Int(viewModel.weeklyAlcoholGrams))g")
                        .font(AppFonts.statsSmall)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text(viewModel.healthRiskLevel.rawValue)
                        .font(AppFonts.caption)
                        .foregroundColor(getRiskLevelColor())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Calories
                VStack(alignment: .leading, spacing: 4) {
                    Text("今日のカロリー")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("\(Int(viewModel.caloriesFromAlcohol))kcal")
                        .font(AppFonts.statsSmall)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("アルコールから")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Water recommendation
                VStack(alignment: .leading, spacing: 4) {
                    Text("推奨水分摂取量")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("\(Int(viewModel.waterRecommendation))ml")
                        .font(AppFonts.statsSmall)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("水または飲料")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func getRiskLevelColor() -> Color {
        switch viewModel.healthRiskLevel {
        case .low:
            return AppColors.drinkLevelSafe
        case .moderate:
            return AppColors.drinkLevelModerate
        case .high:
            return AppColors.drinkLevelRisky
        case .veryHigh:
            return AppColors.drinkLevelHigh
        }
    }
}
