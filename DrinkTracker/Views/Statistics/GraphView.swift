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
