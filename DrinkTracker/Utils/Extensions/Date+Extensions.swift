import Foundation

extension Date {
    // Get start of day
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    // Get end of day
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay) ?? self
    }
    
    // Get start of week
    var startOfWeek: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self)
        return calendar.date(from: components) ?? self
    }
    
    // Get start of month
    var startOfMonth: Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month], from: self)
        return calendar.date(from: components) ?? self
    }
    
    // Format date to string
    func format(_ format: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    // Get relative time string (today, yesterday, etc.)
    var relativeTimeString: String {
        let calendar = Calendar.current
        if calendar.isDateInToday(self) {
            return "今日"
        } else if calendar.isDateInYesterday(self) {
            return "昨日"
        } else if calendar.isDate(self, equalTo: Date(), toGranularity: .weekOfYear) {
            return "今週"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd"
            return formatter.string(from: self)
        }
    }
    
    // Check if date is between two other dates
    func isBetween(_ date1: Date, and date2: Date) -> Bool {
        return (min(date1, date2) ... max(date1, date2)).contains(self)
    }
}
