import SwiftUI

struct DrinkAmountView: View {
    @ObservedObject var viewModel: DrinkRecordViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.standardPadding) {
            // 選択された飲み物の表示
            HStack {
                DrinkTypeIcon(drinkType: viewModel.selectedDrinkType, size: 40, isSelected: true)
                
                Text(viewModel.selectedDrinkType.rawValue)
                    .font(AppFonts.title2)
                    .foregroundColor(AppColors.textPrimary)
                
                Spacer()
                
                Button(action: {
                    viewModel.previousStep()
                }) {
                    Text("変更")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.bottom, 16)
            
            // 飲酒量の入力セクション
            Group {
                Text("量")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                // 一般的なサイズの選択肢
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.getSizesForDrinkType(), id: \.self) { size in
                            SizeSelectionButton(
                                size: size,
                                isSelected: viewModel.volume == size,
                                action: {
                                    viewModel.volume = size
                                }
                            )
                        }
                    }
                }
                
                // カスタムサイズのスライダー
                VStack(spacing: 4) {
                    HStack {
                        Text("カスタムサイズ")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Spacer()
                        
                        Text("\(Int(viewModel.volume))ml")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Slider(
                        value: $viewModel.volume,
                        in: 50...1000,
                        step: 10
                    )
                    .accentColor(AppColors.primary)
                }
                .padding(.vertical, 8)
            }
            
            // アルコール度数の入力セクション
            Group {
                Text("アルコール度数")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.top, 16)
                
                // 一般的な度数の選択肢
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(viewModel.getPercentagesForDrinkType(), id: \.self) { percentage in
                            PercentageSelectionButton(
                                percentage: percentage,
                                isSelected: viewModel.alcoholPercentage == percentage,
                                action: {
                                    viewModel.alcoholPercentage = percentage
                                }
                            )
                        }
                    }
                }
                
                // カスタム度数のスライダー
                VStack(spacing: 4) {
                    HStack {
                        Text("カスタム度数")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                        
                        Spacer()
                        
                        Text("\(String(format: "%.1f", viewModel.alcoholPercentage))%")
                            .font(AppFonts.bodyBold)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    
                    Slider(
                        value: $viewModel.alcoholPercentage,
                        in: 0...70,
                        step: 0.5
                    )
                    .accentColor(AppColors.primary)
                }
                .padding(.vertical, 8)
            }
            
            // 純アルコール量とカロリーの表示
            SummaryBoxView(viewModel: viewModel)
                .padding(.top, 16)
        }
    }
}

struct SummaryBoxView: View {
    @ObservedObject var viewModel: DrinkRecordViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                InfoItem(
                    title: "純アルコール量",
                    value: "\(String(format: "%.1f", viewModel.pureAlcoholGrams))g",
                    icon: "drop.fill",
                    color: AppColors.primary
                )
                
                InfoItem(
                    title: "標準ドリンク",
                    value: "\(String(format: "%.1f", viewModel.standardDrinks))杯",
                    icon: "wineglass.fill",
                    color: AppColors.secondary
                )
                
                InfoItem(
                    title: "カロリー",
                    value: "\(Int(viewModel.calories))kcal",
                    icon: "flame.fill",
                    color: AppColors.warning
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

struct InfoItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.system(size: 12))
                
                Text(title)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textSecondary)
            }
            
            Text(value)
                .font(AppFonts.title3)
                .foregroundColor(AppColors.textPrimary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
