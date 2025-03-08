// DrinkTracker/Views/Record/DrinkDetailsView.swift
import SwiftUI

struct DrinkDetailsView: View {
    @ObservedObject var viewModel: DrinkRecordViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.standardPadding) {
            // 選択内容サマリー
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(viewModel.selectedDrinkType.rawValue)
                        .font(AppFonts.title3)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Text("\(Int(viewModel.volume))ml (\(String(format: "%.1f", viewModel.alcoholPercentage))%)")
                        .font(AppFonts.body)
                        .foregroundColor(AppColors.textSecondary)
                }
                
                Spacer()
                
                Button(action: {
                    viewModel.previousStep()
                }) {
                    Text("変更")
                        .font(AppFonts.subheadline)
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(.bottom, 8)
            
            // 価格入力
            Group {
                Text("価格（任意）")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                TextField("金額を入力", text: $viewModel.price)
                    .keyboardType(.numberPad)
                    .font(AppFonts.body)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                            .fill(Color.gray.opacity(0.1))
                    )
            }
            
            // 日時選択
            Group {
                Text("日時")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.top, 8)
                
                DatePicker(
                    "",
                    selection: $viewModel.date,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(CompactDatePickerStyle())
                .labelsHidden()
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                        .fill(Color.gray.opacity(0.1))
                )
            }
            
            // 場所入力
            Group {
                Text("場所（任意）")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.top, 8)
                
                TextField("バー、レストラン、自宅など", text: $viewModel.location)
                    .font(AppFonts.body)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                            .fill(Color.gray.opacity(0.1))
                    )
            }
            
            // メモ入力
            Group {
                Text("メモ（任意）")
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.top, 8)
                
                TextField("記録しておきたいことなど", text: $viewModel.note)
                    .font(AppFonts.body)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.UI.smallCornerRadius)
                            .fill(Color.gray.opacity(0.1))
                    )
            }
            
            // お気に入り設定
            Toggle(isOn: $viewModel.isFavorite) {
                HStack {
                    Text("お気に入りに追加")
                        .font(AppFonts.bodyBold)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Image(systemName: "star.fill")
                        .foregroundColor(AppColors.warning)
                        .font(.system(size: 16))
                }
            }
            .padding(.top, 8)
            .toggleStyle(SwitchToggleStyle(tint: AppColors.primary))
        }
    }
}
