import Foundation
import Combine

class HealthViewModel: ObservableObject {
    // Health data
    @Published var weeklyAlcoholGrams: Double = 0
    @Published var currentBAC: Double = 0
    @Published var soberingTime: Double = 0
    @Published var healthRiskLevel: AlcoholCalculator.HealthRiskLevel = .low
    @Published var caloriesFromAlcohol: Double = 0
    @Published var waterRecommendation: Double = 0
    @Published var intoxicationLevel: AlcoholCalculator.IntoxicationLevel = .none
    
    // User profile data
    @Published var gender: UserProfile.Gender = .notSpecified
    @Published var weight: Double = 60.0
    @Published var drinkingGoal: UserProfile.DrinkingGoal = .moderate
    
    // Services
    public let drinkDataManager: DrinkDataManager
    private let userProfileManager: UserProfileManager
    
    private var cancellables = Set<AnyCancellable>()
    
    init(drinkDataManager: DrinkDataManager, userProfileManager: UserProfileManager) {
        self.drinkDataManager = drinkDataManager
        self.userProfileManager = userProfileManager
        
        // Listen for drink data changes
        drinkDataManager.$drinkRecords
            .sink { [weak self] _ in
                self?.updateHealthData()
            }
            .store(in: &cancellables)
        
        // Listen for user profile changes
        userProfileManager.$userProfile
            .sink { [weak self] profile in
                self?.gender = profile.gender
                self?.weight = profile.weight
                self?.drinkingGoal = profile.drinkingGoal
                self?.updateHealthData()
            }
            .store(in: &cancellables)
        
        // Initial data loading
        updateHealthData()
    }
    
    // Update all health data
    func updateHealthData() {
        // Get weekly alcohol consumption
        weeklyAlcoholGrams = drinkDataManager.getWeeklyTotalAlcohol()
        
        // Calculate current BAC
        calculateCurrentBAC()
        
        // Calculate sobering time
        soberingTime = AlcoholCalculator.estimateSoberingTime(alcoholGrams: getTodayRemainingAlcohol())
        
        // Assess health risk level
        healthRiskLevel = AlcoholCalculator.assessHealthRisk(weeklyAlcoholGrams: weeklyAlcoholGrams)
        
        // Calculate calories from alcohol
        caloriesFromAlcohol = AlcoholCalculator.calculateCalories(alcoholGrams: drinkDataManager.getDailyTotalAlcohol())
        
        // Calculate recommended water intake
        waterRecommendation = AlcoholCalculator.recommendedWaterIntake(alcoholGrams: drinkDataManager.getDailyTotalAlcohol())
    }
    
    // Calculate current blood alcohol content
    private func calculateCurrentBAC() {
        let todayDrinks = drinkDataManager.getDrinkRecords(for: Date())
        var totalBAC: Double = 0
        
        for drink in todayDrinks {
            // Calculate hours since this drink
            let hoursSinceDrinking = Date().timeIntervalSince(drink.date) / 3600
            
            // Calculate BAC for this drink
            let drinkBAC = AlcoholCalculator.estimateBAC(
                alcoholGrams: drink.pureAlcoholGrams,
                gender: gender,
                weight: weight,
                hoursSinceDrinking: hoursSinceDrinking
            )
            
            totalBAC += drinkBAC
        }
        
        currentBAC = totalBAC
        intoxicationLevel = AlcoholCalculator.getIntoxicationLevel(bac: currentBAC)
    }
    
    // Calculate remaining alcohol in body
    private func getTodayRemainingAlcohol() -> Double {
        let todayDrinks = drinkDataManager.getDrinkRecords(for: Date())
        var remainingAlcohol: Double = 0
        
        for drink in todayDrinks {
            // Hours since this drink
            let hoursSinceDrinking = Date().timeIntervalSince(drink.date) / 3600
            
            // Calculate metabolized alcohol (approx 7g per hour)
            let metabolizedAmount = min(hoursSinceDrinking * 7.0, drink.pureAlcoholGrams)
            
            // Add remaining alcohol
            remainingAlcohol += max(0, drink.pureAlcoholGrams - metabolizedAmount)
        }
        
        return remainingAlcohol
    }
    
    // Get health advice based on drinking patterns
    var healthAdvice: String {
        return healthRiskLevel.recommendation
    }
    
    // Calculate projected weight reduction from reduced drinking
    func calculateWeightImpact(reducedAlcoholPerWeek: Double, weeks: Int) -> Double {
        // Calories saved per week
        let caloriesSavedPerWeek = reducedAlcoholPerWeek * 7.0
        
        // Total calories saved
        let totalCaloriesSaved = caloriesSavedPerWeek * Double(weeks)
        
        // Estimated weight loss (kg) - 7700 calories per kg of fat
        return totalCaloriesSaved / 7700.0
    }
}
