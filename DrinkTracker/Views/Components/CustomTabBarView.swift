import SwiftUI

// カスタムタブバーのビュー
struct CustomTabBarView: View {
    @Binding var selectedTab: ContentView.Tab
    @Binding var showingAddDrinkSheet: Bool
    
    var body: some View {
        HStack(spacing: 0) {
            // ホームタブ
            TabBarButton(
                icon: "house.fill",
                title: "ホーム",
                isSelected: selectedTab == .home
            ) {
                selectedTab = .home
            }
            
            // 統計タブ
            TabBarButton(
                icon: "chart.bar.fill",
                title: "記録",
                isSelected: selectedTab == .stats
            ) {
                selectedTab = .stats
            }
            
            // 中央の追加ボタン
            AddButton {
                showingAddDrinkSheet = true
            }
            
            // 健康タブ
            TabBarButton(
                icon: "heart.fill",
                title: "健康",
                isSelected: selectedTab == .health
            ) {
                selectedTab = .health
            }
            
            // 設定タブ
            TabBarButton(
                icon: "gearshape.fill",
                title: "設定",
                isSelected: selectedTab == .settings
            ) {
                selectedTab = .settings
            }
        }
        .frame(height: 80)
        .background(
            Color(UIColor.systemBackground)
                .shadow(color: Color.black.opacity(0.1), radius: 10, x: 0, y: -5)
        )
        .edgesIgnoringSafeArea(.bottom)
    }
}

// タブバーボタン
struct TabBarButton: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 22))
                    .foregroundColor(isSelected ? AppColors.primary : Color.gray)
                
                Text(title)
                    .font(.system(size: 11))
                    .foregroundColor(isSelected ? AppColors.primary : Color.gray)
            }
            .frame(maxWidth: .infinity)
            .contentShape(Rectangle())
        }
    }
}

// 中央の追加ボタン
struct AddButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Circle()
                    .fill(AppColors.primary)
                    .frame(width: 56, height: 56)
                    .shadow(color: AppColors.primary.opacity(0.3), radius: 8, x: 0, y: 4)
                
                Image(systemName: "plus")
                    .font(.system(size: 24, weight: .semibold))
                    .foregroundColor(.white)
            }
            .offset(y: -10)
        }
        .frame(maxWidth: .infinity)
    }
}

// プレビュー
struct CustomTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            CustomTabBarView(
                selectedTab: .constant(.home),
                showingAddDrinkSheet: .constant(false)
            )
        }
        .background(Color.gray.opacity(0.1))
    }
}
