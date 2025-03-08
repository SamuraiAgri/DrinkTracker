import SwiftUI

struct GraphView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            Text(getGraphTitle())
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            // グラフの上部に凡例を表示
            if viewModel.selectedDataType == .alcohol {
                HStack(spacing: 12) {
                    legendItem(color: AppColors.drinkLevelSafe, text: "安全範囲")
                    legendItem(color: AppColors.drinkLevelModerate, text: "適度")
                    legendItem(color: AppColors.drinkLevelRisky, text: "リスク")
                    Spacer()
                }
                .padding(.bottom, 4)
            }
            
            // Graph based on timeframe
            switch viewModel.selectedTimeFrame {
            case .day:
                DailyGraphView(viewModel: viewModel)
            case .week:
                WeeklyGraphView(viewModel: viewModel)
            case .month:
                MonthlyGraphView(viewModel: viewModel)
            }
            
            // 推奨限度量ライン（アルコール表示の場合のみ）
            if viewModel.selectedDataType == .alcohol {
                HStack {
                    Text("1日の推奨限度量: \(Int(viewModel.dailyLimit))g")
                        .font(AppFonts.caption)
                        .foregroundColor(.gray)
                    Spacer()
                }
                .padding(.top, 4)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func legendItem(color: Color, text: String) -> some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            Text(text)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
    }
    
    private func getGraphTitle() -> String {
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
        }
        
        return "\(timeFrameText)\(dataTypeText)グラフ"
    }
}

struct DailyGraphView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        if viewModel.dailyData.isEmpty {
            Text("データがありません")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
        } else {
            VStack(spacing: 16) {
                // 限度量ラインと共にグラフを表示
                ZStack(alignment: .bottom) {
                    // Bar chart
                    HStack(alignment: .bottom, spacing: 6) {
                        ForEach(viewModel.dailyData) { data in
                            VStack(spacing: 4) {
                                // Value label
                                Text(getValueLabel(data))
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                    .opacity(getBarHeight(data) > 20 ? 1 : 0)
                                
                                // Bar
                                Rectangle()
                                    .fill(getBarColor(data))
                                    .frame(width: 14, height: getBarHeight(data))
                                    .cornerRadius(7)
                                
                                // Hour label
                                Text("\(data.hour)")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 200)
                    
                    // 推奨限度量ライン（アルコール表示の場合のみ）
                    if viewModel.selectedDataType == .alcohol {
                        GeometryReader { geometry in
                            let maxBarHeight: CGFloat = 150
                            let limitLineHeight = getLimitLineHeight(maxHeight: maxBarHeight)
                            
                            Rectangle()
                                .fill(Color.red.opacity(0.5))
                                .frame(height: 2)
                                .offset(y: maxBarHeight - limitLineHeight)
                                .overlay(
                                    Text("\(Int(viewModel.dailyLimit))g")
                                        .font(.system(size: 10))
                                        .foregroundColor(.red)
                                        .offset(x: -20, y: maxBarHeight - limitLineHeight - 12)
                                )
                        }
                        .frame(height: 200)
                    }
                }
                
                // X-axis label
                Text("時間")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    private func getValueLabel(_ data: StatisticsViewModel.DailyStatData) -> String {
        switch viewModel.selectedDataType {
        case .alcohol:
            return data.alcoholGrams > 0 ? "\(Int(data.alcoholGrams))g" : ""
        case .spending:
            return data.spending > 0 ? "¥\(Int(data.spending))" : ""
        case .count:
            return data.count > 0 ? "\(data.count)" : ""
        }
    }
    
    private func getBarHeight(_ data: StatisticsViewModel.DailyStatData) -> CGFloat {
        let maxHeight: CGFloat = 150
        
        // Get value based on data type
        let value: Double
        let maxValue: Double
        
        switch viewModel.selectedDataType {
        case .alcohol:
            value = data.alcoholGrams
            // 最大値を調整して見やすくする
            let highestValue = viewModel.dailyData.map { $0.alcoholGrams }.max() ?? 0
            maxValue = max(viewModel.dailyLimit * 1.2, highestValue * 1.1)
        case .spending:
            value = data.spending
            maxValue = viewModel.dailyData.map { $0.spending }.max() ?? 0
        case .count:
            value = Double(data.count)
            maxValue = Double(viewModel.dailyData.map { $0.count }.max() ?? 0)
        }
        
        // Avoid division by zero
        guard maxValue > 0 else { return 0 }
        
        return CGFloat(value / maxValue) * maxHeight
    }
    
    private func getLimitLineHeight(maxHeight: CGFloat) -> CGFloat {
        let maxValue: Double
        
        switch viewModel.selectedDataType {
        case .alcohol:
            // 最大値を調整して見やすくする
            let highestValue = viewModel.dailyData.map { $0.alcoholGrams }.max() ?? 0
            maxValue = max(viewModel.dailyLimit * 1.2, highestValue * 1.1)
        case .spending, .count:
            return 0 // 他のタイプでは表示しない
        }
        
        // Avoid division by zero
        guard maxValue > 0 else { return 0 }
        
        return CGFloat(viewModel.dailyLimit / maxValue) * maxHeight
    }
    
    private func getBarColor(_ data: StatisticsViewModel.DailyStatData) -> Color {
        switch viewModel.selectedDataType {
        case .alcohol:
            // Coloring based on alcohol amount
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

struct WeeklyGraphView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    private let dayNames = ["日", "月", "火", "水", "木", "金", "土"]
    
    var body: some View {
        if viewModel.weeklyData.isEmpty {
            Text("データがありません")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
        } else {
            VStack(spacing: 16) {
                // 限度量ラインと共にグラフを表示
                ZStack(alignment: .bottom) {
                    // Bar chart
                    HStack(alignment: .bottom, spacing: 8) {
                        ForEach(viewModel.weeklyData) { data in
                            VStack(spacing: 4) {
                                // Value label
                                Text(getValueLabel(data))
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                    .opacity(getBarHeight(data) > 20 ? 1 : 0)
                                
                                // Bar
                                ZStack(alignment: .bottom) {
                                    // Rest day indicator
                                    if data.isAlcoholFreeDay && viewModel.selectedDataType == .alcohol {
                                        Rectangle()
                                            .fill(AppColors.success.opacity(0.3))
                                            .frame(width: 20, height: 150)
                                            .cornerRadius(6)
                                            .overlay(
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(AppColors.success)
                                                    .font(.system(size: 16))
                                                    .offset(y: -60)
                                            )
                                    }
                                    
                                    Rectangle()
                                        .fill(getBarColor(data))
                                        .frame(width: 20, height: getBarHeight(data))
                                        .cornerRadius(6)
                                }
                                
                                // Day label
                                Text(data.dayName)
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textSecondary)
                            }
                            .frame(maxWidth: .infinity)
                        }
                    }
                    .frame(height: 200)
                    
                    // 推奨限度量ライン（アルコール表示の場合のみ）
                    if viewModel.selectedDataType == .alcohol {
                        GeometryReader { geometry in
                            let maxBarHeight: CGFloat = 150
                            let limitLineHeight = getLimitLineHeight(maxHeight: maxBarHeight)
                            
                            Rectangle()
                                .fill(Color.red.opacity(0.5))
                                .frame(height: 2)
                                .offset(y: maxBarHeight - limitLineHeight)
                                .overlay(
                                    Text("\(Int(viewModel.dailyLimit))g")
                                        .font(.system(size: 10))
                                        .foregroundColor(.red)
                                        .offset(x: -20, y: maxBarHeight - limitLineHeight - 12)
                                )
                        }
                        .frame(height: 200)
                    }
                }
                
                // X-axis label
                Text("曜日")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    private func getValueLabel(_ data: StatisticsViewModel.WeeklyStatData) -> String {
        switch viewModel.selectedDataType {
        case .alcohol:
            return data.alcoholGrams > 0 ? "\(Int(data.alcoholGrams))g" : ""
        case .spending:
            return data.spending > 0 ? "¥\(Int(data.spending))" : ""
        case .count:
            return data.count > 0 ? "\(data.count)" : ""
        }
    }
    
    private func getBarHeight(_ data: StatisticsViewModel.WeeklyStatData) -> CGFloat {
        let maxHeight: CGFloat = 150
        
        // Get value based on data type
        let value: Double
        let maxValue: Double
        
        switch viewModel.selectedDataType {
        case .alcohol:
            value = data.alcoholGrams
            // 最大値を調整して見やすくする
            let highestValue = viewModel.weeklyData.map { $0.alcoholGrams }.max() ?? 0
            maxValue = max(viewModel.dailyLimit * 1.2, highestValue * 1.1)
        case .spending:
            value = data.spending
            maxValue = viewModel.weeklyData.map { $0.spending }.max() ?? 0
        case .count:
            value = Double(data.count)
            maxValue = Double(viewModel.weeklyData.map { $0.count }.max() ?? 0)
        }
        
        // Avoid division by zero
        guard maxValue > 0 else { return 0 }
        
        return CGFloat(value / maxValue) * maxHeight
    }
    
    private func getLimitLineHeight(maxHeight: CGFloat) -> CGFloat {
        let maxValue: Double
        
        switch viewModel.selectedDataType {
        case .alcohol:
            // 最大値を調整して見やすくする
            let highestValue = viewModel.weeklyData.map { $0.alcoholGrams }.max() ?? 0
            maxValue = max(viewModel.dailyLimit * 1.2, highestValue * 1.1)
        case .spending, .count:
            return 0 // 他のタイプでは表示しない
        }
        
        // Avoid division by zero
        guard maxValue > 0 else { return 0 }
        
        return CGFloat(viewModel.dailyLimit / maxValue) * maxHeight
    }
    
    private func getBarColor(_ data: StatisticsViewModel.WeeklyStatData) -> Color {
        if data.isAlcoholFreeDay && viewModel.selectedDataType == .alcohol {
            return Color.clear // Rest day just shows background
        }
        
        switch viewModel.selectedDataType {
        case .alcohol:
            // Coloring based on alcohol amount
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

struct MonthlyGraphView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        if viewModel.monthlyData.isEmpty {
            Text("データがありません")
                .font(AppFonts.body)
                .foregroundColor(AppColors.textSecondary)
                .frame(height: 200)
                .frame(maxWidth: .infinity)
        } else {
            VStack(spacing: 16) {
                // 限度量ラインと共にグラフを表示
                ZStack(alignment: .bottom) {
                    // Scrollable bar chart
                    ScrollView(.horizontal, showsIndicators: true) {
                        HStack(alignment: .bottom, spacing: 4) {
                            ForEach(viewModel.monthlyData) { data in
                                VStack(spacing: 4) {
                                    // Value label
                                    Text(getValueLabel(data))
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                        .opacity(getBarHeight(data) > 20 ? 1 : 0)
                                    
                                    // Bar
                                    ZStack(alignment: .bottom) {
                                        // Rest day indicator
                                        if data.isAlcoholFreeDay && viewModel.selectedDataType == .alcohol {
                                            Rectangle()
                                                .fill(AppColors.success.opacity(0.3))
                                                .frame(width: 14, height: 150)
                                                .cornerRadius(5)
                                        }
                                        
                                        Rectangle()
                                            .fill(getBarColor(data))
                                            .frame(width: 14, height: getBarHeight(data))
                                            .cornerRadius(5)
                                    }
                                    
                                    // Day label
                                    Text("\(data.day)")
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                        }
                        .frame(height: 180)
                        .padding(.horizontal, 10)
                    }
                    
                    // 推奨限度量ライン（アルコール表示の場合のみ）
                    if viewModel.selectedDataType == .alcohol {
                        GeometryReader { geometry in
                            let maxBarHeight: CGFloat = 150
                            let limitLineHeight = getLimitLineHeight(maxHeight: maxBarHeight)
                            
                            Rectangle()
                                .fill(Color.red.opacity(0.5))
                                .frame(height: 2)
                                .offset(y: maxBarHeight - limitLineHeight)
                        }
                        .frame(height: 180)
                    }
                }
                
                // X-axis label
                Text("日付")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    private func getValueLabel(_ data: StatisticsViewModel.MonthlyStatData) -> String {
        switch viewModel.selectedDataType {
        case .alcohol:
            return data.alcoholGrams > 0 ? "\(Int(data.alcoholGrams))g" : ""
        case .spending:
            return data.spending > 0 ? "¥\(Int(data.spending))" : ""
        case .count:
            return data.count > 0 ? "\(data.count)" : ""
        }
    }
    
    private func getBarHeight(_ data: StatisticsViewModel.MonthlyStatData) -> CGFloat {
        let maxHeight: CGFloat = 150
        
        // Get value based on data type
        let value: Double
        let maxValue: Double
        
        switch viewModel.selectedDataType {
        case .alcohol:
            value = data.alcoholGrams
            // 最大値を調整して見やすくする
            let highestValue = viewModel.monthlyData.map { $0.alcoholGrams }.max() ?? 0
            maxValue = max(viewModel.dailyLimit * 1.2, highestValue * 1.1)
        case .spending:
            value = data.spending
            maxValue = viewModel.monthlyData.map { $0.spending }.max() ?? 0
        case .count:
            value = Double(data.count)
            maxValue = Double(viewModel.monthlyData.map { $0.count }.max() ?? 0)
        }
        
        // Avoid division by zero
        guard maxValue > 0 else { return 0 }
        
        return CGFloat(value / maxValue) * maxHeight
    }
    
    private func getLimitLineHeight(maxHeight: CGFloat) -> CGFloat {
        let maxValue: Double
        
        switch viewModel.selectedDataType {
        case .alcohol:
            // 最大値を調整して見やすくする
            let highestValue = viewModel.monthlyData.map { $0.alcoholGrams }.max() ?? 0
            maxValue = max(viewModel.dailyLimit * 1.2, highestValue * 1.1)
        case .spending, .count:
            return 0 // 他のタイプでは表示しない
        }
        
        // Avoid division by zero
        guard maxValue > 0 else { return 0 }
        
        return CGFloat(viewModel.dailyLimit / maxValue) * maxHeight
    }
    
    private func getBarColor(_ data: StatisticsViewModel.MonthlyStatData) -> Color {
        if data.isAlcoholFreeDay && viewModel.selectedDataType == .alcohol {
            return Color.clear // Rest day just shows background
        }
        
        switch viewModel.selectedDataType {
        case .alcohol:
            // Coloring based on alcohol amount
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
