import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    @State private var selectedDate: Date = Date()
    @State private var showingDayEditor: Bool = false
    
    var body: some View {
        VStack(spacing: AppConstants.UI.smallPadding) {
            // Month selector
            MonthSelectorView(
                currentDate: $selectedDate,
                onDateChanged: { date in
                    viewModel.changeDate(date)
                }
            )
            
            // Days of week header
            DaysOfWeekHeaderView()
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(getDaysInMonth(), id: \.self) { day in
                    CalendarDayView(
                        day: day,
                        selectedDate: $selectedDate,
                        viewModel: viewModel,
                        onDateSelected: { date in
                            viewModel.changeDate(date)
                            selectedDate = date
                            // 日付がタップされたら編集モードを表示
                            showingDayEditor = true
                        }
                    )
                }
            }
            
            // 休肝日・アルコール摂取量の凡例
            HStack(spacing: 16) {
                // 休肝日の凡例
                HStack(spacing: 4) {
                    Text("🌱")
                        .font(.system(size: 14))
                    Text("休肝日")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                // アルコール摂取量の凡例
                Group {
                    alcoholLegendItem(emoji: "😊", text: "安全範囲") // 適量以下
                    alcoholLegendItem(emoji: "😐", text: "適度") // 適量〜限度内
                    alcoholLegendItem(emoji: "😓", text: "注意") // 限度超え
                    alcoholLegendItem(emoji: "🥵", text: "過剰") // 限度の1.5倍超え
                }
            }
            .padding(.top, 8)
            .padding(.horizontal)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onAppear {
            selectedDate = viewModel.selectedDate
        }
        .sheet(isPresented: $showingDayEditor) {
            DayRecordsEditView(
                date: selectedDate,
                records: viewModel.drinkDataManager.getDrinkRecords(for: selectedDate),
                drinkDataManager: viewModel.drinkDataManager
            )
        }
    }
    
    // 凡例アイテム
    private func alcoholLegendItem(emoji: String, text: String) -> some View {
        HStack(spacing: 4) {
            Text(emoji)
                .font(.system(size: 14))
            Text(text)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textSecondary)
        }
    }
    
    // Get all days to display in the current month view
    private func getDaysInMonth() -> [Date] {
        let calendar = Calendar.current
        
        // Get start of the month
        let components = calendar.dateComponents([.year, .month], from: selectedDate)
        guard let startOfMonth = calendar.date(from: components),
              let range = calendar.range(of: .day, in: .month, for: startOfMonth) else {
            return []
        }
        
        // Get the weekday of the first day (0 = Sunday, 6 = Saturday)
        let firstDayWeekday = calendar.component(.weekday, from: startOfMonth) - 1
        
        // Create array with days from previous month to fill the first row
        var days: [Date] = []
        
        // Add days from previous month
        if firstDayWeekday > 0 {
            for day in (0..<firstDayWeekday).reversed() {
                if let date = calendar.date(byAdding: .day, value: -day - 1, to: startOfMonth) {
                    days.append(date)
                }
            }
        }
        
        // Add days from current month
        for day in 1...range.count {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        // Add days from next month to fill the last row
        let remainingDays = 42 - days.count // 6 rows of 7 days
        for day in 0..<remainingDays {
            if let lastDate = days.last,
               let date = calendar.date(byAdding: .day, value: 1, to: lastDate) {
                days.append(date)
            }
        }
        
        return days
    }
}

struct MonthSelectorView: View {
    @Binding var currentDate: Date
    let onDateChanged: (Date) -> Void
    
    private let calendar = Calendar.current
    private let monthFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月"
        return formatter
    }()
    
    var body: some View {
        HStack {
            Button(action: {
                if let newDate = calendar.date(byAdding: .month, value: -1, to: currentDate) {
                    currentDate = newDate
                    onDateChanged(newDate)
                }
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(AppColors.primary)
                    .padding(8)
            }
            
            Spacer()
            
            Text(monthFormatter.string(from: currentDate))
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
            
            Spacer()
            
            Button(action: {
                if let newDate = calendar.date(byAdding: .month, value: 1, to: currentDate) {
                    currentDate = newDate
                    onDateChanged(newDate)
                }
            }) {
                Image(systemName: "chevron.right")
                    .foregroundColor(AppColors.primary)
                    .padding(8)
            }
        }
    }
}

struct DaysOfWeekHeaderView: View {
    private let daysOfWeek = ["日", "月", "火", "水", "木", "金", "土"]
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(daysOfWeek, id: \.self) { day in
                Text(day)
                    .font(AppFonts.caption)
                    .fontWeight(.bold)
                    .foregroundColor(day == "日" ? AppColors.error : AppColors.textSecondary)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 8)
    }
}

struct CalendarDayView: View {
    let day: Date
    @Binding var selectedDate: Date
    @ObservedObject var viewModel: StatisticsViewModel
    let onDateSelected: (Date) -> Void
    
    private let calendar = Calendar.current
    
    var isSelectedDay: Bool {
        calendar.isDate(day, inSameDayAs: selectedDate)
    }
    
    var isCurrentMonth: Bool {
        calendar.component(.month, from: day) == calendar.component(.month, from: selectedDate)
    }
    
    var isToday: Bool {
        calendar.isDateInToday(day)
    }
    
    var body: some View {
        Button(action: {
            selectedDate = day
            onDateSelected(day)
        }) {
            VStack(spacing: 1) {
                // 日付表示
                ZStack {
                    // 選択状態や今日を示す円
                    Circle()
                        .stroke(isToday ? AppColors.primary : Color.clear, lineWidth: 1)
                        .background(Circle().fill(isSelectedDay ? AppColors.primary : Color.clear))
                        .frame(width: 28, height: 28)
                    
                    Text("\(calendar.component(.day, from: day))")
                        .font(isToday ? AppFonts.caption.bold() : AppFonts.caption)
                        .foregroundColor(
                            isSelectedDay ? .white :
                                isCurrentMonth ?
                                    (isWeekend(day) ? AppColors.error : AppColors.textPrimary) :
                                    AppColors.textTertiary
                        )
                }
                
                // アルコール情報表示（現在の月の日付のみ）
                if isCurrentMonth {
                    let dayRecords = viewModel.drinkDataManager.getDrinkRecords(for: day)
                    
                    // 飲酒記録がある場合
                    if !dayRecords.isEmpty {
                        let totalAlcohol = dayRecords.reduce(0) { $0 + $1.pureAlcoholGrams }
                        
                        // 絵文字を表示
                        Text(getAlcoholEmoji(totalAlcohol))
                            .font(.system(size: 16))
                            .padding(.top, 2)
                            .overlay(
                                isSelectedDay ? nil :
                                    ZStack {
                                        Text("\(Int(totalAlcohol))g")
                                            .font(.system(size: 8))
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 2)
                                            .background(
                                                Capsule()
                                                    .fill(getColorForAmount(totalAlcohol))
                                            )
                                    }
                                    .offset(y: 10)
                            )
                    }
                    // 飲酒記録がない場合（休肝日）
                    else if viewModel.drinkDataManager.isAlcoholFreeDay(day) {
                        Text("🌱")
                            .font(.system(size: 14))
                            .padding(.top, 2)
                    }
                }
            }
            .frame(height: 56) // セルの高さを固定
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle()) // タップ領域を拡大
            .background(isSelectedDay ? Color.clear : (isCurrentMonth ? Color.white : Color.gray.opacity(0.05)))
            .cornerRadius(8)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // アルコール量に応じた絵文字を取得
    private func getAlcoholEmoji(_ amount: Double) -> String {
        let limit = viewModel.dailyLimit
        
        if amount == 0 {
            return "🌱" // 休肝日
        } else if amount <= limit * 0.5 {
            return "😊" // 安全範囲
        } else if amount <= limit * 0.8 {
            return "🙂" // やや適量
        } else if amount <= limit {
            return "😐" // 適量上限
        } else if amount <= limit * 1.5 {
            return "😓" // 注意
        } else if amount <= limit * 2.0 {
            return "🥵" // 過剰
        } else {
            return "🤢" // 危険
        }
    }
    
    // アルコール量に応じた色を取得
    private func getColorForAmount(_ amount: Double) -> Color {
        let limit = viewModel.dailyLimit
        
        if amount <= limit * 0.5 {
            return AppColors.drinkLevelSafe
        } else if amount <= limit {
            return AppColors.drinkLevelModerate
        } else if amount <= limit * 1.5 {
            return AppColors.drinkLevelRisky
        } else {
            return AppColors.drinkLevelHigh
        }
    }
    
    // 週末かどうかを判定
    private func isWeekend(_ date: Date) -> Bool {
        let weekday = calendar.component(.weekday, from: date)
        return weekday == 1 || weekday == 7 // 1:日曜日、7:土曜日
    }
}

// 日付別の記録編集ビュー
struct DayRecordsEditView: View {
    let date: Date
    let records: [DrinkRecord]
    let drinkDataManager: DrinkDataManager
    @State private var drinkToEdit: DrinkRecord? = nil
    @State private var showingNewDrinkSheet: Bool = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                // 日付ヘッダー
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(formatDate(date))
                            .font(AppFonts.title3)
                        
                        let totalAlcohol = records.reduce(0) { $0 + $1.pureAlcoholGrams }
                        if totalAlcohol > 0 {
                            HStack {
                                Text("総アルコール量:")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                Text("\(Int(totalAlcohol))g")
                                    .font(AppFonts.bodyBold)
                                    .foregroundColor(getColorForAmount(totalAlcohol))
                            }
                        } else {
                            HStack {
                                Text("🌱")
                                Text("休肝日")
                                    .font(AppFonts.caption)
                                    .foregroundColor(AppColors.success)
                            }
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding(.vertical, 8)
                .background(Color.white)
                
                // 記録リスト
                if records.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "wineglass")
                            .font(.system(size: 48))
                            .foregroundColor(AppColors.textTertiary)
                            .padding(.top, 40)
                        
                        Text("この日の記録はありません")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Text("「追加」ボタンをタップして記録を追加できます")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textTertiary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 20)
                } else {
                    List {
                        ForEach(records.sorted(by: { $0.date > $1.date })) { drink in
                            Button(action: {
                                drinkToEdit = drink
                            }) {
                                EnhancedDrinkListItemView(drink: drink)
                            }
                            .buttonStyle(PlainButtonStyle())
                            .contextMenu {
                                Button(action: {
                                    drinkToEdit = drink
                                }) {
                                    Label("編集", systemImage: "pencil")
                                }
                                
                                Button(role: .destructive, action: {
                                    drinkDataManager.deleteDrinkRecord(drink.id)
                                }) {
                                    Label("削除", systemImage: "trash")
                                }
                            }
                        }
                        .onDelete(perform: deleteRecord)
                    }
                    .listStyle(InsetGroupedListStyle())
                }
                
                // 新規追加ボタン
                Button(action: {
                    // 新規ドリンク追加時の日付を現在の表示日にセット
                    showingNewDrinkSheet = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.white)
                        Text("記録を追加")
                            .foregroundColor(.white)
                            .font(AppFonts.button)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(AppColors.primary)
                    .cornerRadius(AppConstants.UI.cornerRadius)
                    .padding()
                }
            }
            .navigationTitle("記録の管理")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完了") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.primary)
                }
            }
        }
        .sheet(item: $drinkToEdit) { drink in
            DrinkRecordView(drinkDataManager: drinkDataManager, existingDrink: drink)
        }
        .sheet(isPresented: $showingNewDrinkSheet) {
            let newDrink = DrinkRecord(
                date: date,
                drinkType: .beer,
                volume: 350.0
            )
            DrinkRecordView(drinkDataManager: drinkDataManager, existingDrink: newDrink)
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年M月d日 (E)"
        return formatter.string(from: date)
    }
    
    private func deleteRecord(at offsets: IndexSet) {
        let sortedRecords = records.sorted(by: { $0.date > $1.date })
        offsets.forEach { index in
            drinkDataManager.deleteDrinkRecord(sortedRecords[index].id)
        }
    }
    
    // アルコール量に応じた色を取得
    private func getColorForAmount(_ amount: Double) -> Color {
        if amount == 0 {
            return AppColors.success
        } else if amount <= 20 {
            return AppColors.drinkLevelSafe
        } else if amount <= 40 {
            return AppColors.drinkLevelModerate
        } else {
            return AppColors.drinkLevelRisky
        }
    }
}

// 強化版ドリンクリストアイテムビュー（より詳細な情報表示）
struct EnhancedDrinkListItemView: View {
    let drink: DrinkRecord
    
    var body: some View {
        HStack(spacing: 12) {
            // アイコンとタイプ
            VStack(spacing: 4) {
                DrinkTypeIcon(drinkType: drink.drinkType, size: 40, isSelected: true)
                
                Text(drink.drinkType.shortName)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .lineLimit(1)
            }
            .frame(width: 50)
            
            // 飲み物情報
            VStack(alignment: .leading, spacing: 4) {
                Text("\(Int(drink.volume))ml • \(String(format: "%.1f", drink.alcoholPercentage))%")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                // 場所と時間
                HStack {
                    // 時間
                    Text(formatTime(drink.date))
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textTertiary)
                    
                    if let location = drink.location, !location.isEmpty {
                        Text("•")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textTertiary)
                        
                        Text(location)
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                            .lineLimit(1)
                    }
                }
                
                // メモ（あれば表示）
                if let note = drink.note, !note.isEmpty {
                    Text(note)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textTertiary)
                        .lineLimit(1)
                        .padding(.top, 2)
                }
            }
            
            Spacer()
            
            // アルコール量と価格
            VStack(alignment: .trailing, spacing: 4) {
                HStack(spacing: 2) {
                    Text("\(String(format: "%.1f", drink.pureAlcoholGrams))g")
                        .font(AppFonts.body)
                        .foregroundColor(getColorForAmount(drink.pureAlcoholGrams))
                    
                    Text(getAlcoholEmoji(drink.pureAlcoholGrams))
                        .font(.system(size: 16))
                }
                
                if let price = drink.price {
                    Text("¥\(Int(price))")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.secondary)
                }
                
                Text("\(String(format: "%.1f", drink.standardDrinks))杯")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textTertiary)
            }
            
            // 編集インジケーター
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.textTertiary)
                .font(.system(size: 14))
        }
        .padding(.vertical, 8)
    }
    
    private func formatTime(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: date)
    }
    
    // アルコール量に応じた絵文字を取得
    private func getAlcoholEmoji(_ amount: Double) -> String {
        let limit: Double = 20.0 // 一般的な推奨限度量
        
        if amount == 0 {
            return "🌱" // 休肝日
        } else if amount <= limit * 0.5 {
            return "😊" // 安全範囲
        } else if amount <= limit * 0.8 {
            return "🙂" // やや適量
        } else if amount <= limit {
            return "😐" // 適量上限
        } else if amount <= limit * 1.5 {
            return "😓" // 注意
        } else if amount <= limit * 2.0 {
            return "🥵" // 過剰
        } else {
            return "🤢" // 危険
        }
    }
    
    // アルコール量に応じた色を取得
    private func getColorForAmount(_ amount: Double) -> Color {
        let limit: Double = 20.0 // 一般的な推奨限度量
        
        if amount <= limit * 0.5 {
            return AppColors.drinkLevelSafe
        } else if amount <= limit {
            return AppColors.drinkLevelModerate
        } else if amount <= limit * 1.5 {
            return AppColors.drinkLevelRisky
        } else {
            return AppColors.drinkLevelHigh
        }
    }
}
