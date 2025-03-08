import SwiftUI

struct CalendarView: View {
    @ObservedObject var viewModel: StatisticsViewModel
    @State private var selectedDate: Date = Date()
    
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
                        }
                    )
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .onAppear {
            selectedDate = viewModel.selectedDate
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
            VStack(spacing: 2) {
                // Day number
                Text("\(calendar.component(.day, from: day))")
                    .font(isToday ? AppFonts.bodyBold : AppFonts.body)
                    .foregroundColor(
                        isSelectedDay ? .white :
                            isCurrentMonth ? AppColors.textPrimary : AppColors.textTertiary
                    )
                
                // Indicator for days with records
                if hasDrinkRecord() {
                    Circle()
                        .fill(AppColors.primary)
                        .frame(width: 6, height: 6)
                } else {
                    Circle()
                        .fill(Color.clear)
                        .frame(width: 6, height: 6)
                }
            }
            .frame(height: 36)
            .frame(maxWidth: .infinity)
            .background(
                Circle()
                    .fill(isSelectedDay ? AppColors.primary : Color.clear)
                    .frame(width: 36, height: 36)
            )
            .overlay(
                Circle()
                    .stroke(isToday ? AppColors.primary : Color.clear, lineWidth: 1)
                    .frame(width: 36, height: 36)
            )
        }
    }
    
    private func hasDrinkRecord() -> Bool {
        // Check if there's a drink record for this day
        let records = viewModel.drinkDataManager.getDrinkRecords(for: day)
        return !records.isEmpty
    }
}
