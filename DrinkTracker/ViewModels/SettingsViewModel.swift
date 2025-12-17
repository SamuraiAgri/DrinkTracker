import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    // User profile data
    @Published var displayName: String = ""
    @Published var gender: UserProfile.Gender = .notSpecified
    @Published var birthDate: Date = Date()
    @Published var weight: Double = 60.0
    @Published var height: Double? = nil
    @Published var drinkingGoal: UserProfile.DrinkingGoal = .moderate
    @Published var weeklyBudget: String = ""
    @Published var weeklyAlcoholFreeDayGoal: Int = 2
    @Published var notificationsEnabled: Bool = true
    @Published var preferredReminderTime: Date = Date()
    
    // Service
    private let userProfileManager: UserProfileManager
    private let reminderManager = ReminderManager.shared
    
    // App info
    @Published var appVersion: String = AppConstants.appVersion
    
    private var cancellables = Set<AnyCancellable>()
    
    init(userProfileManager: UserProfileManager) {
        self.userProfileManager = userProfileManager
        
        // Load user profile data
        loadProfileData()
        
        // Listen for profile changes
        userProfileManager.$userProfile
            .sink { [weak self] profile in
                self?.updateViewModelFromProfile(profile)
            }
            .store(in: &cancellables)
    }
    
    // Load user profile data
    private func loadProfileData() {
        let profile = userProfileManager.userProfile
        updateViewModelFromProfile(profile)
    }
    
    // Update view model from profile
    private func updateViewModelFromProfile(_ profile: UserProfile) {
        self.displayName = profile.displayName
        self.gender = profile.gender
        self.birthDate = profile.birthDate
        self.weight = profile.weight
        self.height = profile.height
        self.drinkingGoal = profile.drinkingGoal
        self.weeklyBudget = profile.weeklyBudget != nil ? String(format: "%.0f", profile.weeklyBudget!) : ""
        self.weeklyAlcoholFreeDayGoal = profile.weeklyAlcoholFreeDayGoal
        self.notificationsEnabled = profile.notificationsEnabled
        self.preferredReminderTime = profile.preferredRemindTime
    }
    
    // Save profile changes
    func saveProfile() {
        var updatedProfile = userProfileManager.userProfile
        updatedProfile.displayName = displayName
        updatedProfile.gender = gender
        updatedProfile.birthDate = birthDate
        updatedProfile.weight = weight
        updatedProfile.height = height
        updatedProfile.drinkingGoal = drinkingGoal
        updatedProfile.weeklyBudget = Double(weeklyBudget.replacingOccurrences(of: ",", with: ""))
        updatedProfile.weeklyAlcoholFreeDayGoal = weeklyAlcoholFreeDayGoal
        updatedProfile.notificationsEnabled = notificationsEnabled
        updatedProfile.preferredRemindTime = preferredReminderTime
        updatedProfile.lastUpdated = Date()
        
        userProfileManager.updateProfile(updatedProfile)
        
        // Update notifications
        if notificationsEnabled {
            reminderManager.scheduleDailyReminder(
                at: preferredReminderTime,
                message: "今日の飲酒記録を忘れずに入力してください。"
            )
        } else {
            reminderManager.cancelAllReminders()
        }
    }
    
    // Reset profile to defaults
    func resetToDefaults() {
        let defaultProfile = UserProfile()
        userProfileManager.updateProfile(defaultProfile)
    }
    
    // Get age from birthdate
    var age: Int {
        Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
    }
    
    // Calculate BMI if height is available
    var bmi: Double? {
        guard let height = height, height > 0 else { return nil }
        let heightInMeters = height / 100
        return weight / (heightInMeters * heightInMeters)
    }
    
    // Get BMI category
    var bmiCategory: String {
        guard let bmi = bmi else { return "未設定" }
        
        switch bmi {
        case ..<18.5:
            return "低体重"
        case 18.5..<25:
            return "標準"
        case 25..<30:
            return "過体重"
        case 30...:
            return "肥満"
        default:
            return "未設定"
        }
    }
}
