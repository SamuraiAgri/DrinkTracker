import Foundation
import UserNotifications
import SwiftUI

class ReminderManager {
    static let shared = ReminderManager()
    
    private init() {
        requestPermission()
    }
    
    // Request notification permissions
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    // Schedule daily reminder
    func scheduleDailyReminder(at time: Date, message: String) {
        // Remove existing reminders first
        cancelAllReminders()
        
        // Get time components
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: time)
        
        // Create trigger
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Create content
        let content = UNMutableNotificationContent()
        content.title = AppConstants.appName
        content.body = message
        content.sound = .default
        content.categoryIdentifier = AppConstants.Notifications.reminderCategory
        
        // Create request
        let request = UNNotificationRequest(
            identifier: "dailyReminder",
            content: content,
            trigger: trigger
        )
        
        // Schedule notification
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    // Get reminder status
    func getReminderStatus(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            DispatchQueue.main.async {
                completion(!requests.filter { $0.identifier == "dailyReminder" }.isEmpty)
            }
        }
    }
    
    // Cancel all reminders
    func cancelAllReminders() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
    
    // Schedule a reminder for today if needed
    func checkAndScheduleTodayReminder(userProfile: UserProfile) {
        if userProfile.notificationsEnabled {
            let now = Date()
            let reminderTime = userProfile.preferredRemindTime
            
            let calendar = Calendar.current
            
            // Check if the reminder time has already passed for today
            var componentsNow = calendar.dateComponents([.hour, .minute], from: now)
            var componentsReminder = calendar.dateComponents([.hour, .minute], from: reminderTime)
            
            if let hourNow = componentsNow.hour, let minuteNow = componentsNow.minute,
               let hourReminder = componentsReminder.hour, let minuteReminder = componentsReminder.minute {
                
                let nowMinutes = hourNow * 60 + minuteNow
                let reminderMinutes = hourReminder * 60 + minuteReminder
                
                // Only schedule if reminder time hasn't passed yet
                if reminderMinutes > nowMinutes {
                    scheduleDailyReminder(at: reminderTime, message: "今日の飲酒記録を忘れずに入力してください。")
                }
            }
        }
    }
}
