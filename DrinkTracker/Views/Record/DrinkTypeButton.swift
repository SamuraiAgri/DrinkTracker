// DrinkTracker/Views/Record/DrinkTypeButton.swift
import SwiftUI

struct DrinkTypeButton: View {
    let drinkType: DrinkType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                // アイコン
                ZStack {
                    Circle()
                        .fill(isSelected ? drinkType.color : Color.gray.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    AppIcons.forDrinkType(drinkType)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : drinkType.color)
                }
                
                // テキスト
                Text(drinkType.rawValue)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(isSelected ? AppColors.primary : AppColors.textPrimary)
                
                // 説明
                Text(drinkType.description)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(12)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
