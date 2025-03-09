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
                // グラフエリア
                VStack(alignment: .leading, spacing: 0) {
                    // グラフタイトルと日付範囲
                    HStack {
                        Text("曜日別データ")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Spacer()
                        
                        // 日付範囲表示
                        Text(getDateRangeText())
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
                        
                        // バーチャート
                        HStack(alignment: .bottom, spacing: 0) {
                            // 固定幅のサイドスペース
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 10)
                            
                            // 各曜日のバー
                            HStack(alignment: .bottom, spacing: 6) {
                                ForEach(getSortedData()) { dayData in
                                    VStack(spacing: 0) {
                                        // バーの高さ
                                        if getValue(dayData) > 0 {
                                            ZStack(alignment: .top) {
                                                // 値ラベル
                                                Text(getValueLabel(dayData))
                                                    .font(.system(size: 9))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 4)
                                                    .padding(.vertical, 2)
                                                    .background(getBarColor(dayData).opacity(0.8))
                                                    .cornerRadius(4)
                                                    .offset(y: -20)
                                                    .opacity(getBarHeight(dayData) > 30 ? 1 : 0)
                                                
                                                // 休肝日の場合は特別表示
                                                if dayData.isAlcoholFreeDay && viewModel.selectedDataType == .alcohol {
                                                    Rectangle()
                                                        .fill(AppColors.success.opacity(0.3))
                                                        .frame(width: 36, height: 180)
                                                        .cornerRadius(6)
                                                        .overlay(
                                                            Image(systemName: "leaf.fill")
                                                                .foregroundColor(AppColors.success)
                                                                .font(.system(size: 16))
                                                                .offset(y: -60)
                                                        )
                                                } else {
                                                    // 通常のバー
                                                    Rectangle()
                                                        .fill(getBarColor(dayData))
                                                        .frame(width: 36, height: getBarHeight(dayData))
                                                        .cornerRadius(6)
                                                }
                                            }
                                        } else {
                                            // 値がゼロの場合でも、休肝日表示
                                            if dayData.isAlcoholFreeDay && viewModel.selectedDataType == .alcohol {
                                                ZStack {
                                                    Rectangle()
                                                        .fill(AppColors.success.opacity(0.3))
                                                        .frame(width: 36, height: 30)
                                                        .cornerRadius(6)
                                                    
                                                    Image(systemName: "leaf.fill")
                                                        .foregroundColor(AppColors.success)
                                                        .font(.system(size: 14))
                                                }
                                            } else {
                                                // ゼロ値の表示（最小の高さ）
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.1))
                                                    .frame(width: 36, height: 5)
                                                    .cornerRadius(2.5)
                                            }
                                        }
                                        
                                        // 曜日ラベル
                                        Text(dayData.dayName)
                                            .font(.system(size: 13))
                                            .fontWeight(isToday(dayData.date) ? .bold : .regular)
                                            .foregroundColor(
                                                isToday(dayData.date) ? AppColors.primary :
                                                (calendar.component(.weekday, from: dayData.date) == 1 ? AppColors.error : AppColors.textPrimary)
                                            )
                                            .frame(width: 36, height: 20)
                                    }
                                }
                            }
                            
                            // 右側のスペース
                            Rectangle()
                                .fill(Color.clear)
                                .frame(width: 10)
                        }
                        .frame(height: 220)
                        
                        // 推奨限度量ライン（アルコール表示の場合のみ）
                        if viewModel.selectedDataType == .alcohol {
                            let maxBarHeight: CGFloat = 180
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
                Text("曜日")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    private var calendar: Calendar {
        return Calendar.current
    }
    
    // 日付範囲のテキストを取得
    private func getDateRangeText() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "M/d"
        
        let endDate = viewModel.selectedDate
        if let startDate = calendar.date(byAdding: .day, value: -6, to: endDate) {
            return "\(dateFormatter.string(from: startDate))〜\(dateFormatter.string(from: endDate))"
        }
        
        return "週間データ"
    }
    
    // 今日かどうかを判定
    private func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
    
    // 日付順にソートされたデータを取得
    private func getSortedData() -> [StatisticsViewModel.WeeklyStatData] {
        return viewModel.weeklyData.sorted(by: { $0.date < $1.date })
    }
    
    // 選択されたデータタイプに基づく値を取得
    private func getValue(_ data: StatisticsViewModel.WeeklyStatData) -> Double {
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
    
    // バーの高さを計算
    private func getBarHeight(_ data: StatisticsViewModel.WeeklyStatData) -> CGFloat {
        let maxHeight: CGFloat = 180
        
        // データタイプに基づく値を取得
        let value = getValue(data)
        let maxValue: Double
        
        switch viewModel.selectedDataType {
        case .alcohol:
            // 最大値を調整して見やすくする
            let highestValue = viewModel.weeklyData.map { $0.alcoholGrams }.max() ?? 0
            maxValue = max(viewModel.dailyLimit * 1.2, highestValue * 1.1)
        case .spending:
            maxValue = viewModel.weeklyData.map { $0.spending }.max() ?? 0
        case .count:
            maxValue = Double(viewModel.weeklyData.map { $0.count }.max() ?? 0)
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
        let highestValue = viewModel.weeklyData.map { $0.alcoholGrams }.max() ?? 0
        maxValue = max(viewModel.dailyLimit * 1.2, highestValue * 1.1)
        
        // 0除算を防ぐ
        guard maxValue > 0 else { return 0 }
        
        return CGFloat(viewModel.dailyLimit / maxValue) * maxHeight
    }
    
    // バーの色を取得
    private func getBarColor(_ data: StatisticsViewModel.WeeklyStatData) -> Color {
        if data.isAlcoholFreeDay && viewModel.selectedDataType == .alcohol {
            return AppColors.success // 休肝日は緑色
        }
        
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
                // グラフエリア
                VStack(alignment: .leading, spacing: 0) {
                    // グラフタイトルと月表示
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
                    
                    // スクロール可能なグラフ表示
                    ScrollView(.horizontal, showsIndicators: true) {
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
                            
                            // バーチャート
                            HStack(alignment: .bottom, spacing: 2) {
                                // 各日のバー
                                ForEach(getSortedData()) { dayData in
                                    VStack(spacing: 0) {
                                        // バーの高さ
                                        if getValue(dayData) > 0 {
                                            ZStack(alignment: .top) {
                                                // 値ラベル
                                                Text(getValueLabel(dayData))
                                                    .font(.system(size: 9))
                                                    .foregroundColor(.white)
                                                    .padding(.horizontal, 3)
                                                    .padding(.vertical, 2)
                                                    .background(getBarColor(dayData).opacity(0.8))
                                                    .cornerRadius(4)
                                                    .offset(y: -20)
                                                    .opacity(getBarHeight(dayData) > 30 ? 1 : 0)
                                                
                                                // 休肝日の場合は特別表示
                                                if dayData.isAlcoholFreeDay && viewModel.selectedDataType == .alcohol {
                                                    Rectangle()
                                                        .fill(AppColors.success.opacity(0.3))
                                                        .frame(width: 20, height: 180)
                                                        .cornerRadius(4)
                                                        .overlay(
                                                            Image(systemName: "leaf.fill")
                                                                .foregroundColor(AppColors.success)
                                                                .font(.system(size: 10))
                                                                .offset(y: -60)
                                                        )
                                                } else {
                                                    // 通常のバー
                                                    Rectangle()
                                                        .fill(getBarColor(dayData))
                                                        .frame(width: 20, height: getBarHeight(dayData))
                                                        .cornerRadius(4)
                                                }
                                            }
                                        } else {
                                            // 値がゼロの場合でも、休肝日表示
                                            if dayData.isAlcoholFreeDay && viewModel.selectedDataType == .alcohol {
                                                ZStack {
                                                    Rectangle()
                                                        .fill(AppColors.success.opacity(0.3))
                                                        .frame(width: 20, height: 30)
                                                        .cornerRadius(4)
                                                    
                                                    Image(systemName: "leaf.fill")
                                                        .foregroundColor(AppColors.success)
                                                        .font(.system(size: 10))
                                                }
                                            } else {
                                                // ゼロ値の表示（最小の高さ）
                                                Rectangle()
                                                    .fill(Color.gray.opacity(0.1))
                                                    .frame(width: 20, height: 5)
                                                    .cornerRadius(2.5)
                                            }
                                        }
                                        
                                        // 日付ラベル（5日ごとに表示）
                                        if dayData.day % 5 == 0 || dayData.day == 1 {
                                            Text("\(dayData.day)")
                                                .font(.system(size: 10))
                                                .fontWeight(isToday(dayData.date) ? .bold : .regular)
                                                .foregroundColor(
                                                    isToday(dayData.date) ? AppColors.primary :
                                                        (isWeekend(dayData.date) ? AppColors.error : AppColors.textPrimary)
                                                )
                                                .frame(height: 20)
                                        } else {
                                            // 日付ラベルがない場合でも、スペースを確保
                                            Rectangle()
                                                .fill(Color.clear)
                                                .frame(width: 20, height: 20)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 10)
                            .frame(height: 220)
                            
                            // 推奨限度量ライン（アルコール表示の場合のみ）
                            if viewModel.selectedDataType == .alcohol {
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
                                    .offset(y: 180 - getLimitLineHeight(maxHeight: 180))
                                }
                            }
                        }
                        // グラフの幅を十分に確保（日数×バー幅）
                        .frame(width: max(UIScreen.main.bounds.width - 40, CGFloat(viewModel.monthlyData.count * 24)))
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(AppConstants.UI.cornerRadius)
                .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
                
                // X軸ラベル
                Text("日付")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
        }
    }
    
    private var calendar: Calendar {
        return Calendar.current
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日"
        return formatter.string(from: date)
    }
    
    // 今日かどうかを判定
    private func isToday(_ date: Date) -> Bool {
        return calendar.isDateInToday(date)
    }
    
    // 週末かどうかを判定
    private func isWeekend(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7 // 1:日曜日、7:土曜日
    }
    
    // 日付順にソートされたデータを取得
    private func getSortedData() -> [StatisticsViewModel.MonthlyStatData] {
        return viewModel.monthlyData.sorted(by: { $0.day < $1.day })
    }
    
    // 選択されたデータタイプに基づく値を取得
    private func getValue(_ data: StatisticsViewModel.MonthlyStatData) -> Double {
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
    
    // バーの高さを計算
    private func getBarHeight(_ data: StatisticsViewModel.MonthlyStatData) -> CGFloat {
        let maxHeight: CGFloat = 180
        
        // データタイプに基づく値を取得
        let value = getValue(data)
        let maxValue: Double
        
        switch viewModel.selectedDataType {
        case .alcohol:
            // 最大値を調整して見やすくする
            let highestValue = viewModel.monthlyData.map { $0.alcoholGrams }.max() ?? 0
            maxValue = max(viewModel.dailyLimit * 1.2, highestValue * 1.1)
        case .spending:
            maxValue = viewModel.monthlyData.map { $0.spending }.max() ?? 0
        case .count:
            maxValue = Double(viewModel.monthlyData.map { $0.count }.max() ?? 0)
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
        let highestValue = viewModel.monthlyData.map { $0.alcoholGrams }.max() ?? 0
        maxValue = max(viewModel.dailyLimit * 1.2, highestValue * 1.1)
        
        // 0除算を防ぐ
        guard maxValue > 0 else { return 0 }
        
        return CGFloat(viewModel.dailyLimit / maxValue) * maxHeight
    }
    
    // バーの色を取得
    private func getBarColor(_ data: StatisticsViewModel.MonthlyStatData) -> Color {
        if data.isAlcoholFreeDay && viewModel.selectedDataType == .alcohol {
            return AppColors.success // 休肝日は緑色
        }
        
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
