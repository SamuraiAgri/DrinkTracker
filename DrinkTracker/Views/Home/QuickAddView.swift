import SwiftUI

struct QuickAddView: View {
    @ObservedObject var viewModel: HomeViewModel
    @State private var showingAddDrinkSheet = false
    
    // お気に入りのドリンクを取得
    private var favoriteRecords: [DrinkRecord] {
        return viewModel.drinkDataManager.drinkRecords.filter { $0.isFavorite }
    }
    
    var body: some View {
        VStack(spacing: AppConstants.UI.smallPadding) {
            Text("クイック追加")
                .font(AppFonts.title3)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            // お気に入りがあればそれを、なければデフォルトのビールとワインを表示
            if !favoriteRecords.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // お気に入りのドリンクを表示
                        ForEach(favoriteRecords.prefix(2)) { favorite in
                            FavoriteQuickAddButton(
                                drinkRecord: favorite,
                                action: {
                                    addFavoriteDrink(favorite)
                                }
                            )
                        }
                        
                        // カスタム追加ボタン
                        CustomAddButton(showingAddDrinkSheet: $showingAddDrinkSheet)
                    }
                    .padding(.bottom, 4)
                }
            } else {
                // デフォルトのクイック追加ボタン
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
                    CustomAddButton(showingAddDrinkSheet: $showingAddDrinkSheet)
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
    
    // 通常のクイックドリンク追加
    private func addQuickDrink(_ drinkType: DrinkType) {
        let newDrink = DrinkRecord(
            date: Date(),
            drinkType: drinkType,
            volume: drinkType.defaultSize,
            alcoholPercentage: drinkType.defaultPercentage
        )
        
        viewModel.addDrink(newDrink)
    }
    
    // お気に入りのドリンクを追加
    private func addFavoriteDrink(_ favorite: DrinkRecord) {
        // お気に入りの情報を使用して新しいレコードを作成（日付は現在日時）
        let newDrink = DrinkRecord(
            date: Date(),
            drinkType: favorite.drinkType,
            volume: favorite.volume,
            alcoholPercentage: favorite.alcoholPercentage,
            price: favorite.price,
            location: favorite.location,
            note: favorite.note,
            isFavorite: false // 新しい記録はお気に入りとしてマークしない
        )
        
        viewModel.addDrink(newDrink)
    }
}

// カスタム追加ボタン
struct CustomAddButton: View {
    @Binding var showingAddDrinkSheet: Bool
    
    var body: some View {
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

// お気に入りクイック追加ボタン
struct FavoriteQuickAddButton: View {
    let drinkRecord: DrinkRecord
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                DrinkTypeIcon(drinkType: drinkRecord.drinkType, size: 40, isSelected: true)
                
                VStack(spacing: 2) {
                    Text(drinkRecord.drinkType.shortName)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("\(Int(drinkRecord.volume))ml (\(String(format: "%.1f", drinkRecord.alcoholPercentage))%)")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                    .fill(drinkRecord.drinkType.color.opacity(0.1))
            )
        }
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
