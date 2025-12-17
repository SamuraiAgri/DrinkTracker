import SwiftUI

struct SettingsView: View {
    @StateObject var viewModel: SettingsViewModel
    @State private var showingProfileEditor = false
    @State private var showingNotificationSettings = false
    @State private var showingAboutApp = false
    @State private var showingResetAlert = false
    
    init(userProfileManager: UserProfileManager) {
        _viewModel = StateObject(wrappedValue: SettingsViewModel(userProfileManager: userProfileManager))
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.UI.standardPadding) {
                // User profile summary
                UserProfileSummaryView(viewModel: viewModel)
                    .onTapGesture {
                        showingProfileEditor = true
                    }
                
                // Settings sections
                SettingsSectionView(title: "アプリ設定") {
                    // Notification settings
                    Button {
                        showingNotificationSettings = true
                    } label: {
                        SettingsItemView(
                            icon: "bell.fill",
                            title: "通知設定",
                            subtitle: viewModel.notificationsEnabled ? "オン" : "オフ",
                            iconColor: AppColors.primary
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Drinking goal
                    Button {
                        showingProfileEditor = true
                    } label: {
                        SettingsItemView(
                            icon: "target",
                            title: "飲酒目標",
                            subtitle: viewModel.drinkingGoal.rawValue,
                            iconColor: AppColors.secondary
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // Weekly budget
                    Button {
                        showingProfileEditor = true
                    } label: {
                        SettingsItemView(
                            icon: "yensign.circle.fill",
                            title: "週間予算",
                            subtitle: viewModel.weeklyBudget.isEmpty ? "未設定" : "¥\(viewModel.weeklyBudget)",
                            iconColor: AppColors.accent
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 休肝日目標
                    Button {
                        showingProfileEditor = true
                    } label: {
                        SettingsItemView(
                            icon: "moon.fill",
                            title: "週間休肝日目標",
                            subtitle: "\(viewModel.weeklyAlcoholFreeDayGoal)日",
                            iconColor: AppColors.success
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // About section
                SettingsSectionView(title: "情報") {
                    // About app
                    Button {
                        showingAboutApp = true
                    } label: {
                        SettingsItemView(
                            icon: "info.circle.fill",
                            title: "アプリについて",
                            subtitle: "バージョン \(viewModel.appVersion)",
                            iconColor: AppColors.info
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                
                // Reset button
                Button(action: {
                    // 確認アラートを表示
                    showingResetAlert = true
                }) {
                    Text("設定をリセット")
                        .font(AppFonts.button)
                        .foregroundColor(AppColors.error)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(
                            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                                .stroke(AppColors.error, lineWidth: 1)
                        )
                }
                .padding(.top)
                .alert(isPresented: $showingResetAlert) {
                    Alert(
                        title: Text("設定をリセット"),
                        message: Text("すべての設定がデフォルト値にリセットされます。この操作は元に戻せません。"),
                        primaryButton: .destructive(Text("リセット")) {
                            viewModel.resetToDefaults()
                        },
                        secondaryButton: .cancel(Text("キャンセル"))
                    )
                }
            }
            .padding()
        }
        .navigationTitle("設定")
        .sheet(isPresented: $showingProfileEditor) {
            UserProfileView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingNotificationSettings) {
            NotificationSettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingAboutApp) {
            AboutAppView()
        }
    }
}

// User profile summary view
struct UserProfileSummaryView: View {
    @ObservedObject var viewModel: SettingsViewModel
    
    var body: some View {
        HStack {
            ZStack {
                Circle()
                    .fill(AppColors.primary.opacity(0.1))
                    .frame(width: 70, height: 70)
                
                Text(viewModel.displayName.prefix(1).uppercased())
                    .font(AppFonts.title)
                    .foregroundColor(AppColors.primary)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(viewModel.displayName.isEmpty ? "ユーザー名を設定" : viewModel.displayName)
                    .font(AppFonts.title3)
                    .foregroundColor(AppColors.textPrimary)
                
                Text("\(viewModel.age)歳 • \(viewModel.gender.rawValue) • \(Int(viewModel.weight))kg")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                
                if let bmi = viewModel.bmi {
                    Text("BMI: \(String(format: "%.1f", bmi)) (\(viewModel.bmiCategory))")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            .padding(.leading)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.textTertiary)
                .font(.system(size: 14))
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// Settings section view
struct SettingsSectionView<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.smallPadding) {
            Text(title)
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal)
            
            VStack(spacing: 0) {
                content
            }
            .background(AppColors.cardBackground)
            .cornerRadius(AppConstants.UI.cornerRadius)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        }
    }
}

// Settings item view（タップ可能なアイテム）
struct SettingsItemView: View {
    let icon: String
    let title: String
    let subtitle: String
    let iconColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(iconColor)
                .font(.system(size: 20))
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textPrimary)
                
                Text(subtitle)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.textTertiary)
                .font(.system(size: 14))
        }
        .padding()
        .background(AppColors.cardBackground)
        Divider().padding(.leading, 60)
    }
}

// About app view
struct AboutAppView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    Image(systemName: "wineglass.fill")
                        .font(.system(size: 60))
                        .foregroundColor(AppColors.primary)
                        .padding(.top, 40)
                    
                    Text(AppConstants.appName)
                        .font(AppFonts.largeTitle)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("バージョン \(AppConstants.appVersion)")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        Text("このアプリについて")
                            .font(AppFonts.title3)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.top)
                        
                        Text("DrinkTrackerは、あなたの飲酒習慣を記録・分析し、健康的な飲酒習慣の形成と節約をサポートするアプリです。")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.leading)
                        
                        Text("主な機能:")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.top, 5)
                        
                        bulletPoint("飲酒記録の簡単な記録と管理")
                        bulletPoint("統計情報とトレンドの視覚化")
                        bulletPoint("飲酒の健康影響と節約額の計算")
                        bulletPoint("パーソナライズされた健康アドバイス")
                        
                        Divider()
                            .padding(.vertical, 10)
                        
                        Text("体重と身長設定の効果")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                            .padding(.vertical, 5)
                        
                        Text("体重は血中アルコール濃度(BAC)の計算に直接影響します。同じ量のアルコールでも、体重によって血中アルコール濃度が変わるため、より正確な健康アドバイスを提供できます。")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.leading)
                        
                        Text("身長と体重からBMI（体格指数）を計算し、全体的な健康状態の参考値として表示します。")
                            .font(AppFonts.body)
                            .foregroundColor(AppColors.textPrimary)
                            .multilineTextAlignment(.leading)
                            .padding(.top, 5)
                    }
                    .padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(AppConstants.UI.cornerRadius)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
                    .padding(.horizontal)
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("アプリについて")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    private func bulletPoint(_ text: String) -> some View {
        HStack(alignment: .top, spacing: 10) {
            Text("•")
                .font(AppFonts.body)
                .foregroundColor(AppColors.primary)
            
            Text(text)
                .font(AppFonts.body)
                .foregroundColor(AppColors.textPrimary)
                .multilineTextAlignment(.leading)
        }
    }
}
