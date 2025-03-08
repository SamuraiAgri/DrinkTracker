import SwiftUI

struct DrinkSummaryView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            Text("今日の飲酒サマリー")
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(alignment: .top, spacing: AppConstants.UI.standardPadding) {
                // アルコール摂取量
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "drop.fill")
                            .foregroundColor(getLevelColor())
                            .font(.system(size: 14))
                        
                        Text("アルコール")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Text("\(Int(viewModel.dailyAlcoholGrams))g")
                        .font(AppFonts.statsSmall)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("推奨: \(Int(viewModel.recommendedDailyLimit))g")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textTertiary)
                    
                    // プログレスバー
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // 背景
                            Rectangle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 6)
                                .cornerRadius(3)
                            
                            // バー
                            Rectangle()
                                .fill(getLevelColor())
                                .frame(width: CGFloat(min(viewModel.dailyLimitPercentage, 1.0)) * geometry.size.width, height: 6)
                                .cornerRadius(3)
                        }
                    }
                    .frame(height: 6)
                    .padding(.top, 4)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Divider()
                
                // 支出
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: "yensign.circle.fill")
                            .foregroundColor(AppColors.secondary)
                            .font(.system(size: 14))
                        
                        Text("支出")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    
                    Text("¥\(Int(viewModel.dailySpending))")
                        .font(AppFonts.statsSmall)
                        .foregroundColor(AppColors.textPrimary)
                    
                    if let budget = viewModel.weeklyBudget {
                        Text("予算: ¥\(Int(budget/7))/日")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func getLevelColor() -> Color {
        let percentage = viewModel.dailyLimitPercentage
        
        if percentage < 0.5 {
            return AppColors.drinkLevelSafe
        } else if percentage < 0.75 {
            return AppColors.drinkLevelModerate
        } else if percentage < 1.0 {
            return AppColors.drinkLevelRisky
        } else {
            return AppColors.drinkLevelHigh
        }
    }
}
