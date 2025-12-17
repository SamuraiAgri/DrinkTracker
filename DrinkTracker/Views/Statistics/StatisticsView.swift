import SwiftUI

struct StatisticsView: View {
    @StateObject var viewModel: StatisticsViewModel
    @State private var showingDrinkDetails = false
    @State private var selectedDate: Date = Date()
    @State private var showingRecordsList = false
    @State private var drinkToEdit: DrinkRecord? = nil
    @State private var showingAddDrinkSheet = false
    @State private var dateForNewDrink: Date = Date()
    
    init(drinkDataManager: DrinkDataManager, userProfileManager: UserProfileManager) {
        _viewModel = StateObject(wrappedValue: StatisticsViewModel(
            drinkDataManager: drinkDataManager,
            userProfileManager: userProfileManager
        ))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.UI.standardPadding) {
                // 週間グラフ
                WeeklyAlcoholChartView(data: viewModel.getWeeklyChartData())
                
                // 月間ペース分析
                MonthlyAnalysisView(viewModel: viewModel)
                
                // カレンダー表示
                CalendarView(viewModel: viewModel, onAddDrink: { date in
                    dateForNewDrink = date
                    showingAddDrinkSheet = true
                })
                
                // 飲酒タイプ内訳
                if let stats = viewModel.getStatistics(), !stats.drinkTypeBreakdown.isEmpty {
                    DrinkTypeBreakdownView(breakdown: stats.drinkTypeBreakdown)
                }
                
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
            }
            .padding(.horizontal)
        }
        .navigationTitle("記録")
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
        .sheet(isPresented: $showingAddDrinkSheet, onDismiss: {
            // Sheetが閉じた後にデータを更新
            viewModel.updateData()
        }) {
            // 選択した日付のドリンク追加画面
            DrinkRecordView(
                drinkDataManager: viewModel.drinkDataManager,
                initialDate: dateForNewDrink
            )
        }
    }
}

// 月間ペース分析ビュー
struct MonthlyAnalysisView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            Text("今月の飲酒状況")
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            // 月間摂取量サマリー
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("月間アルコール摂取量")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    if let stats = viewModel.getStatistics() {
                        Text("\(Int(stats.totalAlcohol))g")
                            .font(AppFonts.stats)
                            .foregroundColor(AppColors.textPrimary)
                        
                        // 月間推奨量との比較
                        let monthlyLimit = viewModel.dailyLimit * 30
                        let percentage = (stats.totalAlcohol / monthlyLimit) * 100
                        
                        Text("推奨月間摂取量の\(Int(percentage))%")
                            .font(AppFonts.caption)
                            .foregroundColor(getColorForPercentage(percentage))
                    } else {
                        Text("0g")
                            .font(AppFonts.stats)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("データなし")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("休肝日")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    if let stats = viewModel.getStatistics() {
                        Text("\(stats.alcoholFreeDays)日")
                            .font(AppFonts.stats)
                            .foregroundColor(AppColors.textPrimary)
                        
                        // 推奨休肝日との比較
                        let recommendedDays = getDaysInMonth() / 3 // 月間の1/3を休肝日と推奨
                        if stats.alcoholFreeDays >= recommendedDays {
                            Text("良好な休肝ペース")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.success)
                        } else {
                            Text("推奨は月\(Int(recommendedDays))日以上")
                                .font(AppFonts.caption)
                                .foregroundColor(AppColors.warning)
                        }
                    } else {
                        Text("0日")
                            .font(AppFonts.stats)
                            .foregroundColor(AppColors.textPrimary)
                        
                        Text("データなし")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textTertiary)
                    }
                }
            }
            .padding(.vertical, 8)
            
            // 月間ペース分析
            if let stats = viewModel.getStatistics() {
                VStack(alignment: .leading, spacing: 8) {
                    Text("分析")
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    // 月間の予測とアドバイス
                    let monthlyAnalysis = getMonthlyAnalysis(stats: stats)
                    Text(monthlyAnalysis.message)
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textPrimary)
                    
                    if !monthlyAnalysis.advice.isEmpty {
                        HStack {
                            Rectangle()
                                .fill(monthlyAnalysis.color)
                                .frame(width: 4)
                                .cornerRadius(2)
                            
                            Text(monthlyAnalysis.advice)
                                .font(AppFonts.bodyItalic)
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .padding(.vertical, 4)
                        .padding(.horizontal, 8)
                        .background(monthlyAnalysis.color.opacity(0.1))
                        .cornerRadius(AppConstants.UI.smallCornerRadius)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
    
    private func getDaysInMonth() -> Int {
        let calendar = Calendar.current
        if let range = calendar.range(of: .day, in: .month, for: viewModel.selectedDate) {
            return range.count
        }
        return 30 // 月の日数がわからない場合のデフォルト値
    }
    
    private func getColorForPercentage(_ percentage: Double) -> Color {
        if percentage <= 70 {
            return AppColors.drinkLevelSafe
        } else if percentage <= 100 {
            return AppColors.drinkLevelModerate
        } else if percentage <= 150 {
            return AppColors.drinkLevelRisky
        } else {
            return AppColors.drinkLevelHigh
        }
    }
    
    private func getMonthlyAnalysis(stats: StatisticsViewModel.Statistics) -> (message: String, advice: String, color: Color) {
        let daysInMonth = getDaysInMonth()
        let elapsedDays = min(Calendar.current.component(.day, from: Date()), daysInMonth)
        let remainingDays = daysInMonth - elapsedDays
        
        // 月の経過割合
        let monthProgress = Double(elapsedDays) / Double(daysInMonth)
        
        // 現在の摂取量と推定最終摂取量
        let currentAmount = stats.totalAlcohol
        let projectedAmount = remainingDays > 0 ? currentAmount * (1 + (1 - monthProgress) / monthProgress) : currentAmount
        
        // 月間推奨摂取量
        let monthlyLimit = viewModel.dailyLimit * Double(daysInMonth)
        
        // 休肝日分析
        let currentAlcoholFreeDays = stats.alcoholFreeDays
        let projectedAlcoholFreeDays = remainingDays > 0 ?
            Int(Double(currentAlcoholFreeDays) * (1 + (1 - monthProgress) / monthProgress)) : currentAlcoholFreeDays
        let recommendedAlcoholFreeDays = daysInMonth / 3
        
        // メッセージ構築
        var message = "このペースでは月末時点で約\(Int(projectedAmount))gのアルコールを摂取する見込みです"
        if projectedAmount > monthlyLimit {
            let excessPercentage = Int((projectedAmount / monthlyLimit - 1) * 100)
            message += "（推奨量より\(excessPercentage)%超過）。"
        } else {
            let remainingPercentage = Int((1 - projectedAmount / monthlyLimit) * 100)
            message += "（推奨量より\(remainingPercentage)%余裕あり）。"
        }
        
        message += " 休肝日は月間\(projectedAlcoholFreeDays)日になる見込みです。"
        
        // アドバイス
        var advice = ""
        var color: Color
        
        if projectedAmount > monthlyLimit * 1.5 {
            advice = "摂取量が推奨値を大幅に超えています。週に3〜4日の休肝日を設けることをお勧めします。"
            color = AppColors.drinkLevelHigh
        } else if projectedAmount > monthlyLimit {
            advice = "摂取量が推奨値を超えています。残り\(remainingDays)日の間に\(recommendedAlcoholFreeDays - currentAlcoholFreeDays)日以上の休肝日を設けることをお勧めします。"
            color = AppColors.drinkLevelRisky
        } else if projectedAlcoholFreeDays < recommendedAlcoholFreeDays {
            advice = "アルコール摂取量は良好ですが、健康のために月\(recommendedAlcoholFreeDays)日以上の休肝日を設けることをお勧めします。"
            color = AppColors.drinkLevelModerate
        } else {
            advice = "良好な飲酒習慣です。このペースを維持しましょう。"
            color = AppColors.drinkLevelSafe
        }
        
        return (message, advice, color)
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

// 記録一覧を表示するビュー
struct RecordsListView: View {
    let drinkDataManager: DrinkDataManager
    let selectedTimeFrame: StatisticsViewModel.TimeFrame
    let selectedDate: Date
    @State private var drinkToEdit: DrinkRecord? = nil
    @Environment(\.presentationMode) var presentationMode
    @State private var recordsByDate: [Date: [DrinkRecord]] = [:]
    
    private var records: [DrinkRecord] {
        return drinkDataManager.getMonthlyRecords(containing: selectedDate)
    }
    
    private var timeFrameText: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月"
        return dateFormatter.string(from: selectedDate)
    }
    
    var body: some View {
        NavigationView {
            List {
                if records.isEmpty {
                    Text("この期間の記録はありません")
                        .foregroundColor(AppColors.textSecondary)
                        .padding()
                } else {
                    // 期間表示セクション
                    Section(header: Text("表示期間: \(timeFrameText)")) {
                        // 日付でグループ化
                        ForEach(recordsByDate.keys.sorted(by: >), id: \.self) { date in
                            if let dateRecords = recordsByDate[date] {
                                Section(header: Text(formatDateHeader(date))) {
                                    ForEach(dateRecords) { drink in
                                        DrinkListItemView(drink: drink)
                                            .contentShape(Rectangle())
                                            .onTapGesture {
                                                drinkToEdit = drink
                                            }
                                            .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                                Button(role: .destructive) {
                                                    drinkDataManager.deleteDrinkRecord(drink.id)
                                                    // 削除後にデータを再グループ化
                                                    groupRecordsByDate()
                                                } label: {
                                                    Label("削除", systemImage: "trash")
                                                }
                                            }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("記録の管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
        .sheet(item: $drinkToEdit) { drink in
            DrinkRecordView(drinkDataManager: drinkDataManager, existingDrink: drink)
        }
        .onAppear {
            groupRecordsByDate()
        }
    }
    
    private func groupRecordsByDate() {
        // レコードを日付でグループ化
        let calendar = Calendar.current
        recordsByDate = Dictionary(grouping: records) { record in
            calendar.startOfDay(for: record.date)
        }
    }
    
    private func formatDateHeader(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy年M月d日 (E)"
        return dateFormatter.string(from: date)
    }
}
