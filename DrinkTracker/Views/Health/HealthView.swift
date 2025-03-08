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
        case .severe, .extreme:
            return AppColors.drinkLevelHigh
        }
    }
    
    private func formatSoberingTime() -> String {
        let hours = Int(viewModel.soberingTime)
        let minutes = Int((viewModel.soberingTime - Double(hours)) * 60)
        
        if hours > 0 {
            return "\(hours)時間\(minutes)分"
        } else {
            return "\(minutes)分"
        }
    }
}

struct IntoxicationLevelView: View {
    @ObservedObject var viewModel: HealthViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            Text("酔いのレベル")
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            // Intoxication level indicator
            VStack(spacing: 8) {
                // Level scale
                HStack(spacing: 0) {
                    ForEach(AlcoholCalculator.IntoxicationLevel.allCases, id: \.self) { level in
                        Rectangle()
                            .fill(getColorForLevel(level))
                            .frame(height: 8)
                            .frame(maxWidth: .infinity)
                    }
                }
                .cornerRadius(4)
                
                // Level marker
                GeometryReader { geometry in
                    HStack {
                        Rectangle()
                            .fill(Color.clear)
                            .frame(width: getMarkerPosition(geometry: geometry), height: 1)
                        
                        Image(systemName: "arrowtriangle.up.fill")
                            .font(.system(size: 16))
                            .foregroundColor(getColorForLevel(viewModel.intoxicationLevel))
                        
                        Spacer()
                    }
                }
                .frame(height: 16)
                
                // Current level description
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(viewModel.intoxicationLevel.rawValue)
                            .font(AppFonts.title3)
                            .foregroundColor(getColorForLevel(viewModel.intoxicationLevel))
                        
                        Text(viewModel.intoxicationLevel.description)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(2)
                    }
                    
                    Spacer()
                }
                .padding(.top, 8)
                
                // Recommendation
                if viewModel.intoxicationLevel != .none {
                    HStack {
                        Image(systemName: "info.circle.fill")
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.info)
                        
                        Text(viewModel.intoxicationLevel.recommendation)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .lineLimit(3)
                        
                        Spacer()
                    }
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                            .fill(AppColors.info.opacity(0.1))
                    )
                    .padding(.top, 8)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func getColorForLevel(_ level: AlcoholCalculator.IntoxicationLevel) -> Color {
        switch level {
        case .none:
            return Color.gray.opacity(0.5)
        case .mild:
            return AppColors.drinkLevelSafe
        case .moderate:
            return AppColors.drinkLevelModerate
        case .significant:
            return AppColors.drinkLevelRisky
        case .severe:
            return AppColors.drinkLevelHigh
        case .extreme:
            return AppColors.error
        }
    }
    
    private func getMarkerPosition(geometry: GeometryProxy) -> CGFloat {
        let totalWidth = geometry.size.width
        let levels = AlcoholCalculator.IntoxicationLevel.allCases.count
        let levelWidth = totalWidth / CGFloat(levels)
        
        // Find the index of current level
        if let index = AlcoholCalculator.IntoxicationLevel.allCases.firstIndex(of: viewModel.intoxicationLevel) {
            return levelWidth * CGFloat(index) + (levelWidth / 2) - 8 // Adjust for marker size
        }
        
        return 0
    }
}

struct HealthProjectionsView: View {
    @ObservedObject var viewModel: HealthViewModel
    @State private var reductionPercentage: Double = 20
    @State private var projectionWeeks: Int = 12
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            Text("健康予測")
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            VStack(alignment: .leading, spacing: 16) {
                // Reduction percentage slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("飲酒量削減率")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Text("\(Int(reductionPercentage))%")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.primary)
                    }
                    
                    Slider(
                        value: $reductionPercentage,
                        in: 5...100,
                        step: 5
                    )
                    .accentColor(AppColors.primary)
                }
                
                // Projection period slider
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("予測期間")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Text("\(projectionWeeks)週間")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.primary)
                    }
                    
                    Slider(
                        value: Binding(
                            get: { Double(projectionWeeks) },
                            set: { projectionWeeks = Int($0) }
                        ),
                        in: 4...52,
                        step: 4
                    )
                    .accentColor(AppColors.primary)
                }
                
                Divider()
                
                // Projected impacts
                HStack(spacing: AppConstants.UI.standardPadding) {
                    // Calories reduction
                    ProjectionItem(
                        title: "カロリー削減",
                        value: "\(Int(getCaloriesReduction()))kcal",
                        subtitle: "\(projectionWeeks)週間で",
                        iconName: "flame.fill",
                        color: AppColors.warning
                    )
                    
                    // Weight impact
                    ProjectionItem(
                        title: "体重への影響",
                        value: "\(String(format: "%.1f", getWeightImpact()))kg",
                        subtitle: "推定減量",
                        iconName: "scalemass.fill",
                        color: AppColors.success
                    )
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func getCaloriesReduction() -> Double {
        // Weekly alcohol reduction
        let reducedAlcoholPerWeek = viewModel.weeklyAlcoholGrams * (reductionPercentage / 100)
        
        // Calories per gram of alcohol
        let caloriesPerGram = 7.0
        
        // Weekly calories reduction
        let weeklyCaloriesReduction = reducedAlcoholPerWeek * caloriesPerGram
        
        // Total calories reduction over the projection period
        return weeklyCaloriesReduction * Double(projectionWeeks)
    }
    
    private func getWeightImpact() -> Double {
        // Weekly alcohol reduction
        let reducedAlcoholPerWeek = viewModel.weeklyAlcoholGrams * (reductionPercentage / 100)
        
        // Calculate weight impact
        return viewModel.calculateWeightImpact(
            reducedAlcoholPerWeek: reducedAlcoholPerWeek,
            weeks: projectionWeeks
        )
    }
}

struct ProjectionItem: View {
    let title: String
    let value: String
    let subtitle: String
    let iconName: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: iconName)
                    .foregroundColor(color)
                    .font(.system(size: 14))
                
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Text(value)
                .font(AppFonts.statsSmall)
                .foregroundColor(AppColors.textPrimary)
            
            Text(subtitle)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textTertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
