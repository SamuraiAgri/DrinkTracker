// DrinkTracker/Views/Record/SizeSelectionButton.swift
import SwiftUI

struct SizeSelectionButton: View {
    let size: Double
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(Int(size))ml")
                .font(AppFonts.body)
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                        .fill(isSelected ? AppColors.primary : Color.gray.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct PercentageSelectionButton: View {
    let percentage: Double
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text("\(String(format: "%.1f", percentage))%")
                .font(AppFonts.body)
                .foregroundColor(isSelected ? .white : AppColors.textPrimary)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                        .fill(isSelected ? AppColors.primary : Color.gray.opacity(0.1))
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct FavoritePresetButton: View {
    let preset: DrinkRecord
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(preset.drinkType.rawValue)
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(AppColors.warning)
                        .font(.system(size: 12))
                }
                
                Text("\(Int(preset.volume))ml (\(String(format: "%.1f", preset.alcoholPercentage))%)")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
                
                if let location = preset.location, !location.isEmpty {
                    Text(location)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textTertiary)
                        .lineLimit(1)
                }
            }
            .padding(12)
            .frame(width: 160)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                    .fill(Color.white)
                    .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
