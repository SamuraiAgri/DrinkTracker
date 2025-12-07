// DrinkTracker/Views/ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userProfileManager: UserProfileManager
    @EnvironmentObject var drinkDataManager: DrinkDataManager
    @EnvironmentObject var drinkPresetManager: DrinkPresetManager
    @State private var selectedTab: Tab = .home
    @State private var showingAddDrinkSheet = false
    @State private var showToast = false
    @State private var toastMessage = ""
    
    enum Tab {
        case home, stats, health, settings
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // メインコンテンツ
            Group {
                switch selectedTab {
                case .home:
                    NavigationView {
                        HomeView(
                            drinkDataManager: drinkDataManager,
                            userProfileManager: userProfileManager
                        )
                        .environmentObject(drinkPresetManager)
                    }
                    
                case .stats:
                    NavigationView {
                        StatisticsView(
                            drinkDataManager: drinkDataManager,
                            userProfileManager: userProfileManager
                        )
                    }
                    
                case .health:
                    NavigationView {
                        HealthView(
                            drinkDataManager: drinkDataManager,
                            userProfileManager: userProfileManager
                        )
                    }
                    
                case .settings:
                    NavigationView {
                        SettingsView(userProfileManager: userProfileManager)
                    }
                }
            }
            
            // カスタムタブバー
            CustomTabBarView(
                selectedTab: $selectedTab,
                showingAddDrinkSheet: $showingAddDrinkSheet
            )
        }
        .edgesIgnoringSafeArea(.bottom)
        .sheet(isPresented: $showingAddDrinkSheet) {
            let viewModel = DrinkRecordViewModel(drinkDataManager: drinkDataManager)
            DrinkRecordView(drinkDataManager: drinkDataManager)
                .onDisappear {
                    if !viewModel.savedSuccessMessage.isEmpty {
                        toastMessage = viewModel.savedSuccessMessage
                        withAnimation {
                            showToast = true
                        }
                    }
                }
        }
        .toast(isShowing: $showToast, message: toastMessage, icon: "checkmark.circle.fill", backgroundColor: AppColors.primary)
        .onAppear {
            // 初回起動時またはオンボーディングが未完了の場合
            if !userProfileManager.isOnboardingCompleted {
                userProfileManager.isOnboardingCompleted = true
            }
        }
    }
}
