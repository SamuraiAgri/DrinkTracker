// App/DrinkTrackerApp.swift
import SwiftUI
import GoogleMobileAds

@main
struct DrinkTrackerApp: App {
    // アプリ全体で共有するサービス
    @StateObject public var drinkDataManager = DrinkDataManager()
    @StateObject public var userProfileManager = UserProfileManager()
    @StateObject public var drinkPresetManager = DrinkPresetManager()
    
    init() {
        print("🚀 App: Initializing DrinkTracker...")
        // AdMobを初期化
        AdMobManager.shared.initialize()
        print("🚀 App: AdMob initialization requested")
        
        // インタースティシャル広告を事前読み込み
        _ = InterstitialAdManager.shared
        print("🚀 App: Interstitial ad manager initialized")
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(drinkDataManager)
                .environmentObject(userProfileManager)
                .environmentObject(drinkPresetManager)
        }
    }
}
