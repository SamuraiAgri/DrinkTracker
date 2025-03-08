// DrinkTracker/Views/Components/CustomTabBar.swift
import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let items: [TabItem]
    
    // For floating button offset
    @State private var middleButtonOffset: CGSize = .zero
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: -2)
                .frame(height: 60 + (UIApplication.shared.connectedScenes
                    .filter { $0.activationState == .foregroundActive }
                    .first(where: { $0 is UIWindowScene })
                    .flatMap({ $0 as? UIWindowScene })?.windows
                    .first(where: \.isKeyWindow)?.safeAreaInsets.bottom ?? 0))
                .padding(.horizontal)
            
            // Tab items
            HStack {
                Spacer()
                
                ForEach(0..<items.count, id: \.self) { index in
                    TabBarButton(
                        item: items[index],
                        isSelected: selectedTab == index,
                        action: {
                            withAnimation(.easeInOut) {
                                selectedTab = index
                            }
                        }
                    )
                    
                    Spacer()
                }
            }
            .padding(.bottom, UIApplication.shared.connectedScenes
                .filter { $0.activationState == .foregroundActive }
                .first(where: { $0 is UIWindowScene })
                .flatMap({ $0 as? UIWindowScene })?.windows
                .first(where: \.isKeyWindow)?.safeAreaInsets.bottom ?? 0)
        }
    }
    
    struct TabBarButton: View {
        let item: TabItem
        let isSelected: Bool
        let action: () -> Void
        
        var body: some View {
            Button(action: action) {
                VStack(spacing: 4) {
                    item.icon
                        .font(.system(size: 22))
                        .foregroundColor(isSelected ? AppColors.primary : AppColors.textSecondary)
                    
                    Text(item.title)
                        .font(AppFonts.caption)
                        .foregroundColor(isSelected ? AppColors.primary : AppColors.textSecondary)
                }
                .frame(height: 50)
            }
        }
    }
}

struct TabItem {
    let icon: Image
    let title: String
}
