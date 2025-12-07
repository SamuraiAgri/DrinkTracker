import SwiftUI
import Charts

// 週間アルコール摂取量グラフ
struct WeeklyAlcoholChartView: View {
    let data: [DailyAlcoholData]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("週間アルコール摂取量")
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            if #available(iOS 16.0, *) {
                Chart(data) { item in
                    BarMark(
                        x: .value("曜日", item.dayLabel),
                        y: .value("摂取量", item.alcoholGrams)
                    )
                    .foregroundStyle(getColor(for: item.alcoholGrams))
                    .cornerRadius(4)
                }
                .frame(height: 200)
                .chartYAxis {
                    AxisMarks(position: .leading)
                }
            } else {
                // iOS 16未満用のフォールバック
                SimpleBarChartView(data: data)
            }
            
            // 凡例
            HStack(spacing: 16) {
                LegendItem(color: AppColors.success, label: "安全範囲")
                LegendItem(color: AppColors.warning, label: "適度")
                LegendItem(color: AppColors.error, label: "超過")
            }
            .font(AppFonts.caption)
            .padding(.top, 8)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func getColor(for amount: Double) -> Color {
        if amount <= AppConstants.Drinking.lowRiskLimit {
            return AppColors.success
        } else if amount <= AppConstants.Drinking.moderateRiskLimit {
            return AppColors.warning
        } else {
            return AppColors.error
        }
    }
}

// 簡易バーチャートビュー（iOS 16未満用）
struct SimpleBarChartView: View {
    let data: [DailyAlcoholData]
    
    var maxValue: Double {
        data.map { $0.alcoholGrams }.max() ?? 100
    }
    
    var body: some View {
        HStack(alignment: .bottom, spacing: 12) {
            ForEach(data) { item in
                VStack(spacing: 4) {
                    Spacer()
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(getColor(for: item.alcoholGrams))
                        .frame(width: 40, height: max(CGFloat(item.alcoholGrams / maxValue) * 150, 2))
                    
                    Text(item.dayLabel)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
        }
        .frame(height: 200)
        .padding(.horizontal)
    }
    
    private func getColor(for amount: Double) -> Color {
        if amount <= AppConstants.Drinking.lowRiskLimit {
            return AppColors.success
        } else if amount <= AppConstants.Drinking.moderateRiskLimit {
            return AppColors.warning
        } else {
            return AppColors.error
        }
    }
}

// 凡例アイテム
struct LegendItem: View {
    let color: Color
    let label: String
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(color)
                .frame(width: 10, height: 10)
            
            Text(label)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}

// 日別アルコールデータモデル
struct DailyAlcoholData: Identifiable {
    let id = UUID()
    let date: Date
    let dayLabel: String
    let alcoholGrams: Double
}

// プレビュー
struct WeeklyAlcoholChartView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleData = [
            DailyAlcoholData(date: Date(), dayLabel: "月", alcoholGrams: 15.0),
            DailyAlcoholData(date: Date(), dayLabel: "火", alcoholGrams: 25.0),
            DailyAlcoholData(date: Date(), dayLabel: "水", alcoholGrams: 0.0),
            DailyAlcoholData(date: Date(), dayLabel: "木", alcoholGrams: 18.0),
            DailyAlcoholData(date: Date(), dayLabel: "金", alcoholGrams: 35.0),
            DailyAlcoholData(date: Date(), dayLabel: "土", alcoholGrams: 30.0),
            DailyAlcoholData(date: Date(), dayLabel: "日", alcoholGrams: 10.0)
        ]
        
        WeeklyAlcoholChartView(data: sampleData)
            .padding()
    }
}
