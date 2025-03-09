import SwiftUI

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
                // グラフエリア
                VStack(alignment: .leading, spacing: 0) {
                    // グラフタイトルと日付
                    HStack {
                        Text("時間帯別データ")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        Text(formatDate(viewModel.selectedDate))
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                    .padding(.bottom, 8)
                    
                    // グラフ本体
                    ZStack(alignment: .bottom) {
                        // グリッド線
                        VStack(spacing: 0) {
                            ForEach(0..<5) { i in
                                Divider()
                                    .background(Color.gray.opacity(0.2))
                                    .padding(.bottom, 40)
                            }
                        }
                        .frame(height: 200)
                        .padding(.bottom, 20) // X軸ラベル用のスペース
                        
                        // 時間帯バー
                        HStack(alignment: .bottom, spacing: 0) {
                            // 固定幅のサイドスペース
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 20)
                            
                            // バーの表示
                            HStack(alignment: .bottom, spacing: 2) {
                                ForEach(getSortedData()) { hourData in
                                    VStack(spacing: 0) {
                                        // バーの高さ
                                        if getValue(hourData) > 0 {
                                            ZStack(alignment: .top) {
                                                // 値ラベル
                                                Text(getValueLabel(hourData))
                                                    .font(.system(size: 9))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 2)
                                                    .background(getBarColor(hourData).opacity(0.8))
                                                    .cornerRadius(4)
                                                    .offset(y: -20)
                                                    .opacity(getBarHeight(hourData) > 30 ? 1 : 0)
                                                
                                                // バー
                                                Rectangle()
                                                    .fill(getBarColor(hourData))
                                                    .frame(width: getBarWidth(), height: getBarHeight(hourData))
                                            }
                                        }
                                        
                                        // 時間ラベル (3時間ごとに表示)
                                        if hourData.hour % 3 == 0 {
                                            Text("\(hourData.hour)")
                                                .font(.system(size: 10))
                                                .foregroundColor(AppColors.textPrimary)
                                                .frame(height: 20)
                                                .rotationEffect(Angle(degrees: 0)) // 通常表示
                                        } else {
                                            Spacer()
                                                .frame(height: 20)
                                        }
                                    }
                                }
                            }
                        }
                        .frame(height: 220)
                        
                        // 推奨限度量ライン（アルコール表示の場合のみ）
                        if viewModel.selectedDataType == .alcohol {
                            let maxBarHeight: CGFloat = 200
                            let limitLineHeight = getLimitLineHeight(maxHeight: maxBarHeight)
                            
                            ZStack(alignment: .topLeading) {
                                Rectangle()
                                    .fill(Color.clear)
                                    .frame(height: 200)
                                
                                HStack {
                                    // 左側のラベル
                                    Text("\(Int(viewModel.dailyLimit))g")
                                        .font(.system(size: 10))
                                        .foregroundColor(.white)
                                        .padding(.horizontal, 4)
                                        .padding(.vertical, 2)
                                        .background(Color.red.opacity(0.8))
                                        .cornerRadius(4)
                                    
                                    // ライン
                                    Rectangle()
                                        .fill(Color.red.opacity(0.7))
                                        .frame(height: 2)
                                        .padding(.leading, 4)
                                }
                                .offset(y: maxBarHeight - limitLineHeight)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(AppConstants.UI.cornerRadius)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                
                // X軸ラベル
                Text("時間")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    // 時間順にソートされたデータを取得
    private func getSortedData() -> [StatisticsViewModel.DailyStatData] {
        return viewModel.dailyData.sorted(by: { $0.hour < $1.hour })
    }
    
    // バーの幅を計算（全体の幅に応じて調整）
    private func getBarWidth() -> CGFloat {
        // 24時間分表示する場合、画面幅の約80%を24で割る
        let screenWidth = UIScreen.main.bounds.width
        let graphWidth = screenWidth * 0.8
        return (graphWidth / 24) - 4 // 間隔を確保するため少し小さく
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: date)
    }
    
    // 選択されたデータタイプに基づく値を取得
    private func getValue(_ data: StatisticsViewModel.DailyStatData) -> Double {
        switch viewModel.selectedDataType {
        case .alcohol:
            return data.alcoholGrams
        case .spending:
            return data.spending
        case .count:
            return Double(data.count)
        }
    }
    
    // 値ラベルを取得
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
    
    // バーの高さを計算
    private func getBarHeight(_ data: StatisticsViewModel.DailyStatData) -> CGFloat {
        let maxHeight: CGFloat = 180
        
        // データタイプに基づく値を取得
        let value = getValue(data)
        let maxValue: Double
        
        switch viewModel.selectedDataType {
        case .alcohol:
            // 最大値を調整して見やすくする
            let highestValue = viewModel.dailyData.map { $0.alcoholGrams }.max() ?? 0
            maxValue = max(viewModel.dailyLimit * 1.2, highestValue * 1.1)
        case .spending:
            maxValue = viewModel.dailyData.map { $0.spending }.max() ?? 0
        case .count:
            maxValue = Double(viewModel.dailyData.map { $0.count }.max() ?? 0)
        }
        
        // 0除算を防ぐ
        guard maxValue > 0 else { return 0 }
        
        return CGFloat(value / maxValue) * maxHeight
    }
    
    // 推奨限度量ラインの高さを計算
    private func getLimitLineHeight(maxHeight: CGFloat) -> CGFloat {
        guard viewModel.selectedDataType == .alcohol else { return 0 }
        
        let maxValue: Double
        
        // 最大値を調整して見やすくする
        let highestValue = viewModel.dailyData.map { $0.alcoholGrams }.max() ?? 0
        maxValue = max(viewModel.dailyLimit * 1.2, highestValue * 1.1)
        
        // 0除算を防ぐ
        guard maxValue > 0 else { return 0 }
        
        return CGFloat(viewModel.dailyLimit / maxValue) * maxHeight
    }
    
    // バーの色を取得
    private func getBarColor(_ data: StatisticsViewModel.DailyStatData) -> Color {
        switch viewModel.selectedDataType {
        case .alcohol:
            // アルコール量に基づく色分け
            if data.alcoholGrams > viewModel.dailyLimit {
                return AppColors.drinkLevelRisky
            } else if data.alcoholGrams > viewModel.dailyLimit * 0.7 {
                return AppColors.drinkLevelModerate
            } else if data.alcoholGrams > 0 {
                return AppColors.drinkLevelSafe
            } else {
                return Color.gray.opacity(0.2)
            }
        case .spending:
            return data.spending > 0 ? AppColors.secondary : Color.gray.opacity(0.2)
        case .count:
            return data.count > 0 ? AppColors.accent : Color.gray.opacity(0.2)
        }
    }
}
