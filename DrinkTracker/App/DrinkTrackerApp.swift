// App/DrinkTrackerApp.swift
import SwiftUI

@main
struct DrinkTrackerApp: App {
    // アプリ全体で共有するサービス
    @StateObject private var drinkDataManager = DrinkDataManager()
    @StateObject private var userProfileManager = UserProfileManager()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(drinkDataManager)
                .environmentObject(userProfileManager)
        }
    }
}
