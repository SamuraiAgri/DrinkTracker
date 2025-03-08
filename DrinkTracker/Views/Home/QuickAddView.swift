import SwiftUI

struct QuickAddView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var showingAddDrinkSheet = false
    
    var body: some View {
        VStack(spacing: AppConstants.UI.smallPadding) {
            Text("クイック追加")
                .font(AppFonts.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(spacing: 12) {
                // ビールクイック追加
                QuickAddButton(
                    drinkType: .beer,
                    action: {
                        addQuickDrink(.beer)
                    }
                )
                
                // ワインクイック追加
                QuickAddButton(
                    drinkType: .wine,
                    action: {
                        addQuickDrink(.wine)
                    }
                )
                
                // カスタム追加
                Button(action: {
                    showingAddDrinkSheet = true
                }) {
                    VStack(spacing: 8) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(AppColors.primary)
                        
                        Text("カスタム")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                            .fill(Color.gray.opacity(0.1))
                    )
                }
            }
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
        .sheet(isPresented: $showingAddDrinkSheet) {
            DrinkRecordView(drinkDataManager: viewModel.drinkDataManager)
        }
    }
    
    private func addQuickDrink(_ drinkType: DrinkType) {
        let newDrink = DrinkRecord(
            date: Date(),
            drinkType: drinkType,
            volume: drinkType.defaultSize,
            alcoholPercentage: drinkType.defaultPercentage
        )
        
        viewModel.addDrink(newDrink)
    }
}

struct QuickAddButton: View {
    let drinkType: DrinkType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                DrinkTypeIcon(drinkType: drinkType, size: 40, isSelected: true)
                
                Text(drinkType.shortName)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                    .fill(drinkType.color.opacity(0.1))
            )
        }
    }
}
