// DrinkTracker/Views/Components/DrinkTypeIcon.swift
import SwiftUI

struct DrinkTypeIcon: View {
    let drinkType: DrinkType
    let size: CGFloat
    var isSelected: Bool = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? drinkType.color : Color.gray.opacity(0.1))
                .frame(width: size, height: size)
            
            AppIcons.forDrinkType(drinkType)
                .font(.system(size: size * 0.4))
                .foregroundColor(isSelected ? .white : drinkType.color)
        }
    }
}
