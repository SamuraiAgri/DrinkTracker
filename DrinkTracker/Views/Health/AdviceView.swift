import SwiftUI

struct AdviceView: View {
    @ObservedObject var viewModel: HealthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(AppColors.primary)
                    .font(.system(size: 20))
                
                Text("健康アドバイス")
                    .font(AppFonts.title3)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                // Risk level advice
                AdviceItem(
                    title: "あなたの健康リスクレベル: \(viewModel.healthRiskLevel.rawValue)",
                    content: viewModel.healthRiskLevel.description,
                    recommendation: viewModel.healthRiskLevel.recommendation,
                    iconName: "chart.bar.fill",
                    color: getRiskLevelColor()
                )
                
                // Water advice
                AdviceItem(
                    title: "水分補給のすすめ",
                    content: "アルコールは脱水症状を引き起こす可能性があります。適切な水分補給を心がけましょう。",
                    recommendation: "飲酒中と飲酒後に少なくとも\(Int(viewModel.waterRecommendation))mlの水分を摂取することをお勧めします。",
                    iconName: "drop.fill",
                    color: AppColors.info
                )
                
                // General advice
                AdviceItem(
                    title: "健康的な飲酒習慣",
                    content: "適度な飲酒は社交的な場面で楽しむことができますが、健康への影響を考慮することが重要です。",
                    recommendation: AppConstants.HealthAdvice.moderationAdvice,
                    iconName: "calendar",
                    color: AppColors.success
                )
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

struct AdviceItem: View {
    let title: String
    let content: String
    let recommendation: String
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Image(systemName: iconName)
                    .foregroundColor(color)
                    .font(.system(size: 16))
                
                Text(title)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
            }
            
            Text(content)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.leading)
            
            HStack {
                Rectangle()
                    .fill(color)
                    .frame(width: 4)
                    .cornerRadius(2)
                
                Text(recommendation)
                    .font(AppFonts.bodyItalic)
                    .foregroundColor(AppColors.textPrimary)
                    .multilineTextAlignment(.leading)
            }
            .padding(.vertical, 4)
            .padding(.horizontal, 8)
            .background(color.opacity(0.1))
            .cornerRadius(AppConstants.UI.smallCornerRadius)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
    }
}
