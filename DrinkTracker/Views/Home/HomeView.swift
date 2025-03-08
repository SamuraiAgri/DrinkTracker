import SwiftUI

struct HomeView: View {
    @StateObject var viewModel: HomeViewModel
    @State private var showingAddDrinkSheet = false
    
    init(drinkDataManager: DrinkDataManager, userProfileManager: UserProfileManager) {
        _viewModel = StateObject(wrappedValue: HomeViewModel(
            drinkDataManager: drinkDataManager,
            userProfileManager: userProfileManager
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.UI.standardPadding) {
                // ヘッダー
                HeaderView()
                
                // 今日の飲酒サマリー
                DrinkSummaryView(viewModel: viewModel)
                
                // クイック追加ボタン
                QuickAddView(viewModel: viewModel)
                
                // 週間サマリー
                WeeklySummaryView(viewModel: viewModel)
                
                // 最近の飲み物リスト
                RecentDrinksView(drinks: viewModel.recentDrinks)
                
                // 健康アドバイス
                HealthAdviceView(advice: viewModel.healthAdvice)
            }
            .padding(.horizontal)
        }
        .sheet(isPresented: $showingAddDrinkSheet) {
            DrinkRecordView(drinkDataManager: viewModel.drinkDataManager)
        }
        .navigationTitle("ホーム")
        .onAppear {
            viewModel.updateDisplayData()
        }
    }
}

// 以下のコードは変更なし

// ヘッダービュー
struct HeaderView: View {
    var body: some View {
        HStack {
            Text(Date(), style: .date)
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Image(systemName: "chart.bar.fill")
                .font(.system(size: AppConstants.UI.iconSize))
                .foregroundColor(AppColors.primary)
        }
        .padding(.top)
    }
}

// 日次サマリービュー
struct DailySummaryView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(spacing: AppConstants.UI.smallPadding) {
            Text("今日の飲酒状況")
                .font(AppFonts.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: AppConstants.UI.standardPadding) {
                // アルコール摂取量プログレスバー
                AlcoholProgressView(
                    current: viewModel.dailyAlcoholGrams,
                    limit: viewModel.recommendedDailyLimit,
                    percentage: viewModel.dailyLimitPercentage,
                    colorName: viewModel.getDrinkLevelColor()
                )
                
                // 支出表示
                if viewModel.dailySpending > 0 {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("本日の支出")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("¥\(Int(viewModel.dailySpending))")
                            .font(AppFonts.statsSmall)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(width: 100)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// アルコール摂取プログレスビュー
struct AlcoholProgressView: View {
    let current: Double
    let limit: Double
    let percentage: Double
    let colorName: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("\(Int(current))g / \(Int(limit))g")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    // 背景
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 12)
                    
                    // プログレスバー
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(colorName))
                        .frame(width: max(percentage * geometry.size.width, 0), height: 12)
                        .animation(.easeInOut, value: percentage)
                }
            }
            .frame(height: 12)
            
            Text(getRiskText())
                .font(AppFonts.caption)
                .foregroundColor(Color(colorName))
        }
        .frame(maxWidth: .infinity)
    }
    
    private func getRiskText() -> String {
        if percentage < 0.5 {
            return "安全範囲内"
        } else if percentage < 0.75 {
            return "適度な量"
        } else if percentage < 1.0 {
            return "上限に近づいています"
        } else {
            return "推奨量を超えています"
        }
    }
}

// クイック追加ビュー
struct QuickAddView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var showingAddDrinkSheet = false
    
    var body: some View {
        VStack(spacing: AppConstants.UI.smallPadding) {
            Text("クイック追加")
                .font(AppFonts.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                // ビールクイック追加
                QuickAddButton(
                    drinkType: .beer,
                    action: {
                        addQuickDrink(.beer)
                    }
                )
                
                // ワインクイック追加
                QuickAddButton(
                    drinkType: .wine,
                    action: {
                        addQuickDrink(.wine)
                    }
                )
                
                // カスタム追加
                Button(action: {
                    showingAddDrinkSheet = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppColors.primary)
                        
                        Text("カスタム")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingAddDrinkSheet) {
            DrinkRecordView(drinkDataManager: viewModel.drinkDataManager)
        }
    }
    
    private func addQuickDrink(_ drinkType: DrinkType) {
        let newDrink = DrinkRecord(
            date: Date(),
            drinkType: drinkType,
            volume: drinkType.defaultSize,
            alcoholPercentage: drinkType.defaultPercentage
        )
        
        viewModel.addDrink(newDrink)
    }
}

struct QuickAddButton: View {
    let drinkType: DrinkType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                DrinkTypeIcon(drinkType: drinkType, size: 40, isSelected: true)
                
                Text(drinkType.shortName)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                    .fill(drinkType.color.opacity(0.1))
            )
        }
    }
}

// 週間サマリービュー
struct WeeklySummaryView: View {
    @ObservedObject var viewModel: HomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            Text("週間サマリー")
                .font(AppFonts.title3)
                .padding(.bottom, 4)
            
            HStack(alignment: .top, spacing: AppConstants.UI.standardPadding) {
                // 週間アルコール摂取量
                VStack(alignment: .leading) {
                    Text("アルコール")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("\(Int(viewModel.weeklyAlcoholGrams))g")
                        .font(AppFonts.stats)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("健康リスク: \(viewModel.healthRiskLevel.rawValue)")
                        .font(AppFonts.caption)
                        .foregroundColor(Color(getRiskColor(viewModel.healthRiskLevel)))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 週間支出
                VStack(alignment: .leading) {
                    Text("支出")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("¥\(Int(viewModel.weeklySpending))")
                        .font(AppFonts.stats)
                        .foregroundColor(AppColors.textPrimary)
                    
                    if let budget = viewModel.weeklyBudget {
                        Text("予算: ¥\(Int(budget))")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                // 休肝日
                VStack(alignment: .leading) {
                    Text("休肝日")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("\(viewModel.alcoholFreeDaysCount)")
                        .font(AppFonts.stats)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("今週")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func getRiskColor(_ risk: AlcoholCalculator.HealthRiskLevel) -> String {
        switch risk {
        case .low:
            return "DrinkLevelSafeColor"
        case .moderate:
            return "DrinkLevelModerateColor"
        case .high:
            return "DrinkLevelRiskyColor"
        case .veryHigh:
            return "DrinkLevelHighColor"
        }
    }
}

// 最近の飲み物リスト
struct RecentDrinksView: View {
    let drinks: [DrinkRecord]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            Text("最近の記録")
                .font(AppFonts.title3)
            
            if drinks.isEmpty {
                Text("最近の記録はありません")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .padding()
            } else {
                ForEach(drinks.prefix(5)) { drink in
                    DrinkListItemView(drink: drink)
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// 飲み物リストアイテム
struct DrinkListItemView: View {
    let drink: DrinkRecord
    
    var body: some View {
        HStack {
            // 時間
            Text(drink.date, style: .time)
                .font(AppFonts.footnote)
                .foregroundColor(AppColors.textSecondary)
                .frame(width: 60, alignment: .leading)
            
            // 飲み物情報
            VStack(alignment: .leading) {
                Text(drink.drinkType.rawValue)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(Int(drink.volume))ml (\(String(format: "%.1f", drink.alcoholPercentage))%)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            // アルコール量
            VStack(alignment: .trailing) {
                Text("\(String(format: "%.1f", drink.pureAlcoholGrams))g")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                if let price = drink.price {
                    Text("¥\(Int(price))")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .padding(.vertical, 8)
        .background(AppColors.cardBackground)
    }
}

// 健康アドバイスビュー
struct HealthAdviceView: View {
    let advice: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            HStack {
                Image(systemName: "heart.fill")
                    .foregroundColor(AppColors.primary)
                
                Text("健康アドバイス")
                    .font(AppFonts.title3)
            }
            
            Text(advice)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let drinkDataManager = DrinkDataManager()
        let userProfileManager = UserProfileManager()
        
        return NavigationView {
            HomeView(
                drinkDataManager: drinkDataManager,
                userProfileManager: userProfileManager
            )
        }
    }
}
