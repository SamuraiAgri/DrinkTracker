import Foundation
import Combine

class UserProfileManager: ObservableObject {
    @Published var userProfile: UserProfile
    
    private let storageKey = AppConstants.StorageKeys.userProfile
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.userProfile = UserProfile()
        // 保存されているプロファイルを読み込むか、デフォルトを作成
        if let savedProfile = loadProfile() {
            self.userProfile = savedProfile
        } else {
            self.userProfile = UserProfile()
        }
        
        // プロファイルの変更を監視して自動保存
        $userProfile
            .debounce(for: 0.5, scheduler: RunLoop.main)
            .sink { [weak self] profile in
                self?.saveProfile(profile)
            }
            .store(in: &cancellables)
    }
    
    // プロファイルを読み込む
    private func loadProfile() -> UserProfile? {
        guard let data = UserDefaults.standard.data(forKey: storageKey) else { return nil }
        
        do {
            let decoder = JSONDecoder()
            return try decoder.decode(UserProfile.self, from: data)
        } catch {
            print("Error loading user profile: \(error)")
            return nil
        }
    }
    
    // プロファイルを保存する
    private func saveProfile(_ profile: UserProfile) {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(profile)
            UserDefaults.standard.set(data, forKey: storageKey)
        } catch {
            print("Error saving user profile: \(error)")
        }
    }
    
    // プロファイルを更新する
    func updateProfile(_ newProfile: UserProfile) {
        userProfile.update(from: newProfile)
    }
    
    // 個別の属性を更新するヘルパーメソッド
    func updateDisplayName(_ name: String) {
        userProfile.displayName = name
        userProfile.lastUpdated = Date()
    }
    
    func updateGender(_ gender: UserProfile.Gender) {
        userProfile.gender = gender
        userProfile.lastUpdated = Date()
    }
    
    func updateBirthDate(_ date: Date) {
        userProfile.birthDate = date
        userProfile.lastUpdated = Date()
    }
    
    func updateWeight(_ weight: Double) {
        userProfile.weight = weight
        userProfile.lastUpdated = Date()
    }
    
    func updateHeight(_ height: Double?) {
        userProfile.height = height
        userProfile.lastUpdated = Date()
    }
    
    func updateDrinkingGoal(_ goal: UserProfile.DrinkingGoal) {
        userProfile.drinkingGoal = goal
        userProfile.lastUpdated = Date()
    }
    
    func updateWeeklyBudget(_ budget: Double?) {
        userProfile.weeklyBudget = budget
        userProfile.lastUpdated = Date()
    }
    
    func updateNotificationsEnabled(_ enabled: Bool) {
        userProfile.notificationsEnabled = enabled
        userProfile.lastUpdated = Date()
    }
    
    func updatePreferredRemindTime(_ time: Date) {
        userProfile.preferredRemindTime = time
        userProfile.lastUpdated = Date()
    }
    
    // オンボーディングが完了したかどうかを確認・設定
    var isOnboardingCompleted: Bool {
        get {
            UserDefaults.standard.bool(forKey: AppConstants.StorageKeys.onboardingComplete)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppConstants.StorageKeys.onboardingComplete)
        }
    }
}
