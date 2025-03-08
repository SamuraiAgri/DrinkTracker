// App/DrinkTrackerApp.swift
import SwiftUI

@main
struct DrinkTrackerApp: App {
    // アプリ全体で共有するサービス
    @StateObject public var drinkDataManager = DrinkDataManager()
    @StateObject public var userProfileManager = UserProfileManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(drinkDataManager)
                .environmentObject(userProfileManager)
        }
    }
}
