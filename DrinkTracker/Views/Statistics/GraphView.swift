import SwiftUI

struct GraphView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            Text(getGraphTitle())
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            // Graph based on timeframe
            switch viewModel.selectedTimeFrame {
            case .day:
                DailyGraphView(viewModel: viewModel)
            case .week:
                WeeklyGraphView(viewModel: viewModel)
            case .month:
                MonthlyGraphView(viewModel: viewModel)
            case .year:
                YearlyGraphView(viewModel: viewModel)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
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
        case .year:
            timeFrameText = "年間"
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
                // Bar chart
                HStack(alignment: .bottom, spacing: 2) {
                    ForEach(viewModel.dailyData) { data in
                        VStack(spacing: 4) {
                            // Value label
                            Text(getValueLabel(data))
                                .font(AppFonts.caption2)
                                .foregroundColor(AppColors.textTertiary)
                                .rotationEffect(.degrees(-90))
                                .offset(y: -8)
                                .frame(height: 20)
                                .opacity(getBarHeight(data) > 20 ? 1 : 0)
                            
                            // Bar
                            Rectangle()
                                .fill(getBarColor(data))
                                .frame(width: 12, height: getBarHeight(data))
                                .cornerRadius(6)
                            
                            // Hour label
                            Text("\(data.hour)")
                                .font(AppFonts.caption2)
                                .foregroundColor(AppColors.textTertiary)
                        }
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: 200)
                .padding(.top, 20) // For value labels
                
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
            maxValue = max(viewModel.dailyLimit * 1.5, viewModel.dailyData.map { $0.alcoholGrams }.max() ?? 0)
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
    
    private func getBarColor(_ data: StatisticsViewModel.DailyStatData) -> Color {
        switch viewModel.selectedDataType {
        case .alcohol:
            // Coloring based on alcohol amount
            if data.alcoholGrams > viewModel.dailyLimit {
