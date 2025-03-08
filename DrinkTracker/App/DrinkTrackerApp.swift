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

struct ContentView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var drinkDataManager: DrinkDataManager
    @State private var selectedTab: Tab = .home
    @State private var showingAddDrinkSheet = false
    
    enum Tab {
        case home, stats, health, settings
    }
    
    var body: some View {
        ZStack {
            // タブビュー
            TabView(selection: $selectedTab) {
                // ホーム画面
                NavigationView {
                    HomeView(
                        drinkDataManager: drinkDataManager,
                        userProfileManager: userProfileManager
                    )
                }
                .tag(Tab.home)
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("ホーム")
                }
                
                // 統計画面
                NavigationView {
                    StatisticsView(
                        drinkDataManager: drinkDataManager,
                        userProfileManager: userProfileManager
                    )
                }
                .tag(Tab.stats)
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("統計")
                }
                
                // 健康画面
                NavigationView {
                    HealthView(
                        drinkDataManager: drinkDataManager,
                        userProfileManager: userProfileManager
                    )
                }
                .tag(Tab.health)
                .tabItem {
                    Image(systemName: "heart.fill")
                    Text("健康")
                }
                
                // 設定画面
                NavigationView {
                    SettingsView(userProfileManager: userProfileManager)
                }
                .tag(Tab.settings)
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("設定")
                }
            }
            .accentColor(AppColors.primary)
            
            // フローティングアクションボタン
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showingAddDrinkSheet = true
                    }) {
                        Image(systemName: "plus")
                            .font(.system(size: 24))
                            .foregroundColor(.white)
                            .frame(width: 60, height: 60)
                            .background(AppColors.primary)
                            .clipShape(Circle())
                            .shadow(color: Color.black.opacity(0.15), radius: 4, x: 0, y: 2)
                    }
                    .padding()
                    .padding(.bottom, 60) // タブバーの上に表示
                }
            }
        }
        .sheet(isPresented: $showingAddDrinkSheet) {
            DrinkRecordView(drinkDataManager: drinkDataManager)
        }
        .onAppear {
            // 初回起動時またはオンボーディングが未完了の場合
            if !userProfileManager.isOnboardingCompleted {
                userProfileManager.isOnboardingCompleted = true
            }
        }
    }
}
