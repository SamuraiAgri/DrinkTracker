import SwiftUI

struct DrinkTypeSelectionView: View {
    @ObservedObject var viewModel: DrinkRecordViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.standardPadding) {
            Text("飲み物の種類を選択してください")
                .font(AppFonts.title3)
                .padding(.bottom, 8)
            
            // 飲み物の種類グリッド
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
                ForEach(DrinkType.allCases) { drinkType in
                    DrinkTypeButton(
                        drinkType: drinkType,
                        isSelected: viewModel.selectedDrinkType == drinkType,
                        action: {
                            viewModel.selectedDrinkType = drinkType
                        }
                    )
                }
            }
            
            // お気に入りプリセット
            if !viewModel.favoritePresets.isEmpty {
                Text("お気に入り")
                    .font(AppFonts.title3)
                    .padding(.top, 24)
                    .padding(.bottom, 8)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.favoritePresets) { preset in
                            FavoritePresetButton(
                                preset: preset,
                                action: {
                                    viewModel.selectPreset(preset)
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}
