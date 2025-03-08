import SwiftUI

struct HealthView: View {
    @StateObject var viewModel: HealthViewModel
    
    init(drinkDataManager: DrinkDataManager, userProfileManager: UserProfileManager) {
        _viewModel = StateObject(wrappedValue: HealthViewModel(
            drinkDataManager: drinkDataManager,
            userProfileManager: userProfileManager
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.UI.standardPadding) {
                // Current status
                CurrentHealthStatusView(viewModel: viewModel)
                
                // Intoxication level
                IntoxicationLevelView(viewModel: viewModel)
                
                // Health indicators
                HealthIndicatorsView(viewModel: viewModel)
                
                // Health advice
                AdviceView(viewModel: viewModel)
                
                // Health projections
                HealthProjectionsView(viewModel: viewModel)
            }
            .padding()
        }
        .navigationTitle("健康")
        .onAppear {
            viewModel.updateHealthData()
        }
    }
}

// Current health status view
struct CurrentHealthStatusView: View {
    @ObservedObject var viewModel: HealthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            Text("現在の状態")
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            HStack(spacing: AppConstants.UI.standardPadding) {
                // BAC indicator
                VStack(alignment: .leading, spacing: 4) {
                    Text("推定血中アルコール濃度")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text(String(format: "%.3f", viewModel.currentBAC) + "%")
                        .font(AppFonts.stats)
                        .foregroundColor(getIntoxicationColor())
                    
                    Text(viewModel.intoxicationLevel.rawValue)
                        .font(AppFonts.caption)
                        .foregroundColor(getIntoxicationColor())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // Sobering time
                VStack(alignment: .leading, spacing: 4) {
                    Text("推定分解時間")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    if viewModel.soberingTime > 0 {
                        Text(formatSoberingTime())
                            .font(AppFonts.statsSmall)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("完全に分解されるまで")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textTertiary)
                    } else {
                        Text("0時間")
                            .font(AppFonts.statsSmall)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("体内にアルコールはありません")
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
    
    private func getIntoxicationColor() -> Color {
        switch viewModel.intoxicationLevel {
        case .none:
            return AppColors.drinkLevelSafe
        case .mild:
            return AppColors.drinkLevelSafe
        case .moderate:
            return AppColors.drinkLevelModerate
        case .significant:
            return AppColors.drinkLevelRisky
        case .severe, .
