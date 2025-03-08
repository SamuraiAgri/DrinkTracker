import SwiftUI

struct StatisticsView: View {
    @StateObject var viewModel: StatisticsViewModel
    @State private var showingDrinkDetails = false
    @State private var selectedDate: Date = Date()
    @State private var showingRecordsList = false
    @State private var drinkToEdit: DrinkRecord? = nil
    
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
                GraphView(viewModel: viewModel)
                
                // 記録一覧を表示するボタン
                Button(action: {
                    showingRecordsList = true
                }) {
                    HStack {
                        Image(systemName: "list.bullet")
                        Text("記録を編集・削除")
                    }
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.primary)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                            .stroke(AppColors.primary, lineWidth: 1)
                    )
                }
                .padding(.horizontal)
                
                // カレンダー（月表示の場合のみ）
                if viewModel.selectedTimeFrame == .month {
                    CalendarView(viewModel: viewModel)
                }
                
                // 概要統計
                StatisticsSummaryView(viewModel: viewModel)
                
                // 飲酒タイプ内訳
                Group {
                    if let stats = viewModel.getStatistics(), !stats.drinkTypeBreakdown.isEmpty {
                        DrinkTypeBreakdownView(breakdown: stats.drinkTypeBreakdown)
                    }
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
        .sheet(isPresented: $showingRecordsList) {
            RecordsListView(
                drinkDataManager: viewModel.drinkDataManager,
                selectedTimeFrame: viewModel.selectedTimeFrame,
                selectedDate: viewModel.selectedDate
            )
        }
        .sheet(item: $drinkToEdit) { drink in
            DrinkRecordView(drinkDataManager: viewModel.drinkDataManager, existingDrink: drink)
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
