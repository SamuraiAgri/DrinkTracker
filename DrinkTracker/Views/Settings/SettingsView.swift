import SwiftUI

struct StatisticsView: View {
    @StateObject var viewModel: StatisticsViewModel
    
    init(drinkDataManager: DrinkDataManager, userProfileManager: UserProfileManager) {
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(
            drinkDataManager: drinkDataManager,
            userProfileManager: userProfileManager
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.UI.standardPadding) {
                // 期間セレクター
                TimeFrameSelector(viewModel: viewModel)
                
                // データタイプセレクター
                DataTypeSelector(viewModel: viewModel)
                
                // グラフ表示
                ChartView(viewModel: viewModel)
                
                // 概要統計
                StatisticsSummaryView(viewModel: viewModel)
                
                // 飲酒タイプ内訳
                if let stats = viewModel.getStatistics(), !stats.drinkTypeBreakdown.isEmpty {
                    DrinkTypeBreakdownView(breakdown: stats.drinkTypeBreakdown)
                }
                
                // 詳細データテーブル
                DetailedDataView(viewModel: viewModel)
            }
            .padding(.horizontal)
        }
        .navigationTitle("統計")
        .onAppear {
            viewModel.updateData()
        }
    }
}

// 期間セレクター
struct TimeFrameSelector: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        HStack {
            ForEach(StatisticsViewModel.TimeFrame.allCases, id: \.self) { timeFrame in
                Button(action: {
                    viewModel.changeTimeFrame(timeFrame)
                }) {
                    Text(timeFrame.rawValue)
                        .font(AppFonts.body)
                        .foregroundColor(viewModel.selectedTimeFrame == timeFrame ? .white : AppColors.textPrimary)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                                .fill(viewModel.selectedTimeFrame == timeFrame ? AppColors.primary : Color.gray.opacity(0.1))
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// データタイプセレクター
struct DataTypeSelector: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        HStack {
            ForEach(StatisticsViewModel.DataType.allCases, id: \.self) { dataType in
                Button(action: {
                    viewModel.changeDataType(dataType)
                }) {
                    Text(dataType.rawValue)
                        .font(AppFonts.subheadline)
                        .foregroundColor(viewModel.selectedDataType == dataType ? AppColors.primary : AppColors.textSecondary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 6)
                        .background(
                            RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                                .fill(viewModel.selectedDataType == dataType ? AppColors.primary.opacity(0.1) : Color.clear)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                                .stroke(viewModel.selectedDataType == dataType ? AppColors.primary : Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
    }
}

// グラフビュー
struct ChartView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            // グラフタイトル
            Text(getChartTitle())
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            // グラフの種類に応じたビューを表示
            switch viewModel.selectedTimeFrame {
            case .day:
                DailyChartView(viewModel: viewModel)
            case .week:
                WeeklyChartView(viewModel: viewModel)
            case .month:
                MonthlyChartView(viewModel: viewModel)
            case .year:
                YearlyChartView(viewModel: viewModel)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func getChartTitle() -> String {
        let dataTypeText: String
        switch viewModel.selectedDataType {
        case .alcohol:
            dataTypeText = "アルコール摂取量"
        case .spending:
            dataTypeText = "支出"
        case .count:
            dataTypeText = "飲酒回数"
        }
        
        let timeFrameText: String
        switch viewModel.selectedTimeFrame {
        case .day:
            timeFrameText = "24時間"
        case .week:
            timeFrameText = "週間"
        case .month:
            timeFrameText = "月間"
        case .year:
            timeFrameText = "年間"
        }
        
        return "\(timeFrameText)\(dataTypeText)推移"
    }
}

// 日単位グラフ
struct DailyChartView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        // グラフデータが空の場合のプレースホルダー
        if viewModel.dailyData.isEmpty {
            Text("データがありません")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
        } else {
            // データを描画するビュー
            VStack {
                // バーグラフ
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(viewModel.dailyData) { data in
                        VStack(spacing: 4) {
                            // バー
                            Rectangle()
                                .fill(getBarColor(data))
                                .frame(width: 14, height: getBarHeight(data))
                            
                            // 時間ラベル
                            Text("\(data.hour)")
                                .font(AppFonts.caption2)
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }
                }
                .frame(height: 200)
                .padding(.horizontal)
            }
        }
    }
    
    // データに応じたバーの高さを計算
    private func getBarHeight(_ data: StatisticsViewModel.DailyStatData) -> CGFloat {
        let maxHeight: CGFloat = 180
        
        // データ種類に応じた値を取得
        let value: Double
        let maxValue: Double
        
        switch viewModel.selectedDataType {
        case .alcohol:
            value = data.alcoholGrams
            maxValue = max(viewModel.dailyLimit * 1.5, viewModel.dailyData.map { $0.alcoholGrams }.max() ?? 0)
        case .spending:
            value = data.spending
            maxValue = viewModel.dailyData.map { $0.spending }.max() ?? 0
        case .count:
            value = Double(data.count)
            maxValue = Double(viewModel.dailyData.map { $0.count }.max() ?? 0)
        }
        
        // ゼロ除算を回避
        guard maxValue > 0 else { return 0 }
        
        // 高さを計算
        return CGFloat(value / maxValue) * maxHeight
    }
    
    // データに応じたバーの色を取得
    private func getBarColor(_ data: StatisticsViewModel.DailyStatData) -> Color {
        switch viewModel.selectedDataType {
        case .alcohol:
            // アルコール量に応じた色
            if data.alcoholGrams > viewModel.dailyLimit {
                return AppColors.drinkLevelRisky
            } else if data.alcoholGrams > viewModel.dailyLimit * 0.7 {
                return AppColors.drinkLevelModerate
            } else {
                return AppColors.drinkLevelSafe
            }
        case .spending:
            return AppColors.secondary
        case .count:
            return AppColors.accent
        }
    }
}

// 週間グラフ
struct WeeklyChartView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        if viewModel.weeklyData.isEmpty {
            Text("データがありません")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
        } else {
            // バーグラフ
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(viewModel.weeklyData) { data in
                    VStack(spacing: 4) {
                        // バー
                        ZStack(alignment: .bottom) {
                            // 休肝日のマーク
                            if data.isAlcoholFreeDay && viewModel.selectedDataType == .alcohol {
                                Rectangle()
                                    .fill(AppColors.success.opacity(0.3))
                                    .frame(width: 20, height: 180)
                                    .overlay(
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(AppColors.success)
                                            .font(.system(size: 20))
                                            .offset(y: -80)
                                    )
                            }
                            
                            Rectangle()
                                .fill(getBarColor(data))
                                .frame(width: 20, height: getBarHeight(data))
                        }
                        
                        // 曜日ラベル
                        Text(data.dayName)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 220)
            .padding(.horizontal)
        }
    }
    
    // バーの高さを計算
    private func getBarHeight(_ data: StatisticsViewModel.WeeklyStatData) -> CGFloat {
        let maxHeight: CGFloat = 180
        
        // データ種類に応じた値を取得
        let value: Double
        let maxValue: Double
        
        switch viewModel.selectedDataType {
        case .alcohol:
            value = data.alcoholGrams
            maxValue = max(viewModel.dailyLimit * 1.5, viewModel.weeklyData.map { $0.alcoholGrams }.max() ?? 0)
        case .spending:
            value = data.spending
            maxValue = viewModel.weeklyData.map { $0.spending }.max() ?? 0
        case .count:
            value = Double(data.count)
            maxValue = Double(viewModel.weeklyData.map { $0.count }.max() ?? 0)
        }
        
        // ゼロ除算を回避
        guard maxValue > 0 else { return 0 }
        
        // 高さを計算
        return CGFloat(value / maxValue) * maxHeight
    }
    
    // バーの色を取得
    private func getBarColor(_ data: StatisticsViewModel.WeeklyStatData) -> Color {
        if data.isAlcoholFreeDay && viewModel.selectedDataType == .alcohol {
            return Color.clear // 休肝日は背景色のみ
        }
        
        switch viewModel.selectedDataType {
        case .alcohol:
            // アルコール量に応じた色
            if data.alcoholGrams > viewModel.dailyLimit {
                return AppColors.drinkLevelRisky
            } else if data.alcoholGrams > viewModel.dailyLimit * 0.7 {
                return AppColors.drinkLevelModerate
            } else {
                return AppColors.drinkLevelSafe
            }
        case .spending:
            return AppColors.secondary
        case .count:
            return AppColors.accent
        }
    }
}

// 月間グラフ
struct MonthlyChartView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        if viewModel.monthlyData.isEmpty {
            Text("データがありません")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
        } else {
            // スクロール可能なバーグラフ
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(viewModel.monthlyData) { data in
                        VStack(spacing: 4) {
                            // バー
                            ZStack(alignment: .bottom) {
                                // 休肝日のマーク
                                if data.isAlcoholFreeDay && viewModel.selectedDataType == .alcohol {
                                    Rectangle()
                                        .fill(AppColors.success.opacity(0.3))
                                        .frame(width: 10, height: 180)
                                }
                                
                                Rectangle()
                                    .fill(getBarColor(data))
                                    .frame(width: 10, height: getBarHeight(data))
                            }
                            
                            // 日付ラベル
                            Text("\(data.day)")
                                .font(AppFonts.caption2)
                                .foregroundColor(AppColors.textTertiary)
                        }
                    }
                }
                .frame(height: 220)
                .padding(.horizontal)
            }
        }
    }
    
    // バーの高さを計算
    private func getBarHeight(_ data: StatisticsViewModel.MonthlyStatData) -> CGFloat {
        let maxHeight: CGFloat = 180
        
        // データ種類に応じた値を取得
        let value: Double
        let maxValue: Double
        
        switch viewModel.selectedDataType {
        case .alcohol:
            value = data.alcoholGrams
            maxValue = max(viewModel.dailyLimit * 1.5, viewModel.monthlyData.map { $0.alcoholGrams }.max() ?? 0)
        case .spending:
            value = data.spending
            maxValue = viewModel.monthlyData.map { $0.spending }.max() ?? 0
        case .count:
            value = Double(data.count)
            maxValue = Double(viewModel.monthlyData.map { $0.count }.max() ?? 0)
        }
        
        // ゼロ除算を回避
        guard maxValue > 0 else { return 0 }
        
        // 高さを計算
        return CGFloat(value / maxValue) * maxHeight
    }
    
    // バーの色を取得
    private func getBarColor(_ data: StatisticsViewModel.MonthlyStatData) -> Color {
        if data.isAlcoholFreeDay && viewModel.selectedDataType == .alcohol {
            return Color.clear // 休肝日は背景色のみ
        }
        
        switch viewModel.selectedDataType {
        case .alcohol:
            // アルコール量に応じた色
            if data.alcoholGrams > viewModel.dailyLimit {
                return AppColors.drinkLevelRisky
            } else if data.alcoholGrams > viewModel.dailyLimit * 0.7 {
                return AppColors.drinkLevelModerate
            } else {
                return AppColors.drinkLevelSafe
            }
        case .spending:
            return AppColors.secondary
        case .count:
            return AppColors.accent
        }
    }
}

// 年間グラフ
struct YearlyChartView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    // 月名の配列
    private let monthNames = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]
    
    var body: some View {
        if viewModel.monthlyData.isEmpty {
            Text("データがありません")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
        } else {
            // バーグラフ
            HStack(alignment: .bottom, spacing: 8) {
                ForEach(viewModel.monthlyData) { data in
                    VStack(spacing: 4) {
                        // バー
                        Rectangle()
                            .fill(getBarColor(data))
                            .frame(width: 20, height: getBarHeight(data))
                        
                        // 月名ラベル
                        Text(monthNames[data.day - 1])
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .frame(height: 220)
            .padding(.horizontal)
        }
    }
    
    // バーの高さを計算
    private func getBarHeight(_ data: StatisticsViewModel.MonthlyStatData) -> CGFloat {
        let maxHeight: CGFloat = 180
        
        // データ種類に応じた値を取得
        let value: Double
        let maxValue: Double
        
        switch viewModel.selectedDataType {
        case .alcohol:
            value = data.alcoholGrams
            let weeklyLimit = viewModel.dailyLimit * 7
            maxValue = max(weeklyLimit * 4 * 1.5, viewModel.monthlyData.map { $0.alcoholGrams }.max() ?? 0)
        case .spending:
            value = data.spending
            maxValue = viewModel.monthlyData.map { $0.spending }.max() ?? 0
        case .count:
            value = Double(data.count)
            maxValue = Double(viewModel.monthlyData.map { $0.count }.max() ?? 0)
        }
        
        // ゼロ除算を回避
        guard maxValue > 0 else { return 0 }
        
        // 高さを計算
        return CGFloat(value / maxValue) * maxHeight
    }
    
    // バーの色を取得
    private func getBarColor(_ data: StatisticsViewModel.MonthlyStatData) -> Color {
        switch viewModel.selectedDataType {
        case .alcohol:
            // 月ごとの推奨値（日間推奨値 * 30日）
            let monthlyLimit = viewModel.dailyLimit * 30
            
            // アルコール量に応じた色
            if data.alcoholGrams > monthlyLimit {
                return AppColors.drinkLevelRisky
            } else if data.alcoholGrams > monthlyLimit * 0.7 {
                return AppColors.drinkLevelModerate
            } else {
                return AppColors.drinkLevelSafe
            }
        case .spending:
            return AppColors.secondary
        case .count:
            return AppColors.accent
        }
    }
}

// 統計概要ビュー
struct StatisticsSummaryView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        if let stats = viewModel.getStatistics() {
            VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
                Text("概要")
                    .font(AppFonts.title3)
                    .foregroundColor(AppColors.textPrimary)
                
                // 主要な統計情報
                HStack {
                    // アルコール総量
                    StatItem(
                        title: "総アルコール量",
                        value: "\(Int(stats.totalAlcohol))g",
                        icon: "drop.fill",
                        color: AppColors.drinkLevelModerate
                    )
                    
                    // 総支出
                    StatItem(
                        title: "総支出",
                        value: "¥\(Int(stats.totalSpending))",
                        icon: "yensign.circle.fill",
                        color: AppColors.secondary
                    )
                    
                    // 飲酒回数
                    StatItem(
                        title: "飲酒回数",
                        value: "\(stats.drinkCount)回",
                        icon: "calendar",
                        color: AppColors.accent
                    )
                }
                
                Divider()
                
                // 日平均情報
                HStack {
                    // 日平均アルコール量
                    StatItem(
                        title: "日平均アルコール",
                        value: "\(Int(stats.averageAlcoholPerDay))g",
                        icon: "chart.bar.fill",
                        color: AppColors.primary
                    )
                    
                    // 日平均支出
                    StatItem(
                        title: "日平均支出",
                        value: "¥\(Int(stats.averageSpendingPerDay))",
                        icon: "chart.pie.fill",
                        color: AppColors.primary
                    )
                    
                    // 休肝日
                    StatItem(
                        title: "休肝日",
                        value: "\(stats.alcoholFreeDays)日",
                        icon: "checkmark.seal.fill",
                        color: AppColors.success
                    )
                }
                
                Divider()
                
                // 節約額
                if let savings = viewModel.calculateSavings(), savings > 0 {
                    HStack {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("予算内節約額")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.textSecondary)
                            
                            Text("¥\(Int(savings))")
                                .font(AppFonts.title3)
                                .foregroundColor(AppColors.success)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "leaf.fill")
                            .foregroundColor(AppColors.success)
                            .font(.system(size: 24))
                    }
                }
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(AppConstants.UI.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// 統計項目表示用コンポーネント
struct StatItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Text(value)
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// 飲酒タイプの内訳ビュー
struct DrinkTypeBreakdownView: View {
    let breakdown: [StatisticsViewModel.DrinkTypeBreakdown]
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            Text("飲酒タイプの内訳")
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            ForEach(breakdown, id: \.type.id) { item in
                HStack {
                    // タイプアイコンと名前
                    HStack(spacing: 8) {
                        Circle()
                            .fill(item.type.color)
                            .frame(width: 10, height: 10)
                        
                        Text(item.type.rawValue)
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Spacer()
                    
                    // アルコール量と割合
                    HStack(spacing: 8) {
                        Text("\(Int(item.alcoholGrams))g")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("(\(Int(item.percentage))%)")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                // プログレスバー
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        // 背景
                        Rectangle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(height: 4)
                        
                        // バー
                        Rectangle()
                            .fill(item.type.color)
                            .frame(width: max(CGFloat(item.percentage / 100) * geometry.size.width, 0), height: 4)
                    }
                }
                .frame(height: 4)
                .padding(.bottom, 8)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// 詳細データテーブルビュー
struct DetailedDataView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            Text("詳細データ")
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            // データテーブルの種類に応じたビューを表示
            switch viewModel.selectedTimeFrame {
            case .day:
                DailyDataTable(data: viewModel.dailyData)
            case .week:
                WeeklyDataTable(data: viewModel.weeklyData)
            case .month:
                MonthlyDataTable(data: viewModel.monthlyData)
            case .year:
                YearlyDataTable(data: viewModel.monthlyData)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// 日単位のデータテーブル
struct DailyDataTable: View {
    let data: [StatisticsViewModel.DailyStatData]
    
    var body: some View {
        if data.isEmpty {
            Text("データがありません")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        } else {
            // テーブルヘッダー
            HStack {
                Text("時間")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 60, alignment: .leading)
                
                Spacer()
                
                Text("アルコール")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 80, alignment: .trailing)
                
                Text("支出")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 80, alignment: .trailing)
                
                Text("回数")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 50, alignment: .trailing)
            }
            .padding(.bottom, 4)
            
            Divider()
            
            // データ行
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(data) { item in
                        HStack {
                            // 時間
                            Text("\(item.hour):00")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 60, alignment: .leading)
                            
                            Spacer()
                            
                            // アルコール量
                            Text("\(String(format: "%.1f", item.alcoholGrams))g")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 80, alignment: .trailing)
                            
                            // 支出
                            Text("¥\(Int(item.spending))")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 80, alignment: .trailing)
                            
                            // 回数
                            Text("\(item.count)")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 50, alignment: .trailing)
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                    }
                }
            }
            .frame(height: 300)
        }
    }
}

// 週単位のデータテーブル
struct WeeklyDataTable: View {
    let data: [StatisticsViewModel.WeeklyStatData]
    
    var body: some View {
        if data.isEmpty {
            Text("データがありません")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        } else {
            // テーブルヘッダー
            HStack {
                Text("曜日")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 60, alignment: .leading)
                
                Spacer()
                
                Text("アルコール")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 80, alignment: .trailing)
                
                Text("支出")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 80, alignment: .trailing)
                
                Text("回数")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 50, alignment: .trailing)
            }
            .padding(.bottom, 4)
            
            Divider()
            
            // データ行
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(data) { item in
                        HStack {
                            // 曜日
                            Text(item.dayName)
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 60, alignment: .leading)
                            
                            Spacer()
                            
                            // アルコール量
                            HStack(spacing: 4) {
                                if item.isAlcoholFreeDay {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppColors.success)
                                        .font(.system(size: 12))
                                }
                                
                                Text("\(String(format: "%.1f", item.alcoholGrams))g")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            .frame(width: 80, alignment: .trailing)
                            
                            // 支出
                            Text("¥\(Int(item.spending))")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 80, alignment: .trailing)
                            
                            // 回数
                            Text("\(item.count)")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 50, alignment: .trailing)
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                    }
                }
            }
            .frame(height: 200)
        }
    }
}

// 月単位のデータテーブル
struct MonthlyDataTable: View {
    let data: [StatisticsViewModel.MonthlyStatData]
    
    var body: some View {
        if data.isEmpty {
            Text("データがありません")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        } else {
            // テーブルヘッダー
            HStack {
                Text("日付")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 60, alignment: .leading)
                
                Spacer()
                
                Text("アルコール")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 80, alignment: .trailing)
                
                Text("支出")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 80, alignment: .trailing)
                
                Text("回数")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 50, alignment: .trailing)
            }
            .padding(.bottom, 4)
            
            Divider()
            
            // データ行
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(data) { item in
                        HStack {
                            // 日付
                            Text("\(item.day)日")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 60, alignment: .leading)
                            
                            Spacer()
                            
                            // アルコール量
                            HStack(spacing: 4) {
                                if item.isAlcoholFreeDay {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(AppColors.success)
                                        .font(.system(size: 12))
                                }
                                
                                Text("\(String(format: "%.1f", item.alcoholGrams))g")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textPrimary)
                            }
                            .frame(width: 80, alignment: .trailing)
                            
                            // 支出
                            Text("¥\(Int(item.spending))")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 80, alignment: .trailing)
                            
                            // 回数
                            Text("\(item.count)")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 50, alignment: .trailing)
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                    }
                }
            }
            .frame(height: 300)
        }
    }
}

// 年単位のデータテーブル
struct YearlyDataTable: View {
    let data: [StatisticsViewModel.MonthlyStatData]
    
    // 月名の配列
    private let monthNames = ["1月", "2月", "3月", "4月", "5月", "6月", "7月", "8月", "9月", "10月", "11月", "12月"]
    
    var body: some View {
        if data.isEmpty {
            Text("データがありません")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding()
        } else {
            // テーブルヘッダー
            HStack {
                Text("月")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 60, alignment: .leading)
                
                Spacer()
                
                Text("アルコール")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 80, alignment: .trailing)
                
                Text("支出")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 80, alignment: .trailing)
                
                Text("回数")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(width: 50, alignment: .trailing)
            }
            .padding(.bottom, 4)
            
            Divider()
            
            // データ行
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(data) { item in
                        HStack {
                            // 月名
                            Text(monthNames[item.day - 1])
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 60, alignment: .leading)
                            
                            Spacer()
                            
                            // アルコール量
                            Text("\(String(format: "%.1f", item.alcoholGrams))g")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 80, alignment: .trailing)
                            
                            // 支出
                            Text("¥\(Int(item.spending))")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 80, alignment: .trailing)
                            
                            // 回数
                            Text("\(item.count)")
                                .font(AppFonts.body)
                                .foregroundColor(AppColors.textPrimary)
                                .frame(width: 50, alignment: .trailing)
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                    }
                }
            }
            .frame(height: 200)
        }
    }
}

struct StatisticsView_Previews: PreviewProvider {
    static var previews: some View {
        let drinkDataManager = DrinkDataManager()
        let userProfileManager = UserProfileManager()
        
        return NavigationView {
            StatisticsView(
                drinkDataManager: drinkDataManager,
                userProfileManager: userProfileManager
            )
        }
    }
}
