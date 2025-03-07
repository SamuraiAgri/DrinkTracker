import SwiftUI

struct DrinkRecordView: View {
    @StateObject var viewModel: DrinkRecordViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(drinkDataManager: DrinkDataManager, existingDrink: DrinkRecord? = nil) {
        _viewModel = StateObject(wrappedValue: DrinkRecordViewModel(
            drinkDataManager: drinkDataManager,
            existingDrink: existingDrink
        ))
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // 進行状況インジケーター
                StepProgressView(currentStep: viewModel.currentStep)
                    .padding(.horizontal)
                    .padding(.top)
                
                // コンテンツエリア
                ScrollView {
                    VStack(spacing: AppConstants.UI.standardPadding) {
                        switch viewModel.currentStep {
                        case .drinkType:
                            DrinkTypeSelectionView(viewModel: viewModel)
                        case .amount:
                            DrinkAmountView(viewModel: viewModel)
                        case .details:
                            DrinkDetailsView(viewModel: viewModel)
                        }
                    }
                    .padding()
                }
                
                // ナビゲーションボタン
                BottomNavigationView(
                    isFirstStep: viewModel.currentStep == .drinkType,
                    isLastStep: viewModel.currentStep == .details,
                    onBack: viewModel.previousStep,
                    onNext: viewModel.nextStep
                )
            }
            .navigationTitle(getNavigationTitle())
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onChange(of: viewModel.shouldDismiss) { shouldDismiss in
                if shouldDismiss {
                    presentationMode.wrappedValue.dismiss()
                }
            }
        }
    }
    
    private func getNavigationTitle() -> String {
        if viewModel.isEditMode {
            return "飲酒記録を編集"
        }
        
        switch viewModel.currentStep {
        case .drinkType:
            return "飲み物の種類を選択"
        case .amount:
            return "飲酒量を入力"
        case .details:
            return "詳細情報"
        }
    }
}

// ステップ進行状況インジケーター
struct StepProgressView: View {
    let currentStep: DrinkRecordViewModel.RecordStep
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<3) { index in
                let isActive = getStepIndex(currentStep) >= index
                
                Capsule()
                    .fill(isActive ? AppColors.primary : Color.gray.opacity(0.3))
                    .frame(height: 4)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(maxWidth: .infinity)
    }
    
    private func getStepIndex(_ step: DrinkRecordViewModel.RecordStep) -> Int {
        switch step {
        case .drinkType:
            return 0
        case .amount:
            return 1
        case .details:
            return 2
        }
    }
}

// 飲み物の種類選択ビュー
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

// 飲み物の種類ボタン
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
                    
                    Image(systemName: "wineglass")
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

// お気に入りプリセットボタン
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

// 飲酒量入力ビュー
struct DrinkAmountView: View {
    @ObservedObject var viewModel: DrinkRecordViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.standardPadding) {
            // 選択された飲み物の表示
            HStack {
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
            .padding(.bottom, 8)
            
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
            AlcoholInfoView(viewModel: viewModel)
                .padding(.top, 16)
        }
    }
}

// サイズ選択ボタン
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

// アルコール度数選択ボタン
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

// アルコール情報表示ビュー
struct AlcoholInfoView: View {
    @ObservedObject var viewModel: DrinkRecordViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("純アルコール量")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("\(String(format: "%.1f", viewModel.pureAlcoholGrams))g")
                        .font(AppFonts.title3)
                        .foregroundColor(AppColors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("標準ドリンク")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("\(String(format: "%.1f", viewModel.standardDrinks))杯")
                        .font(AppFonts.title3)
                        .foregroundColor(AppColors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("カロリー")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    Text("\(Int(viewModel.calories))kcal")
                        .font(AppFonts.title3)
                        .foregroundColor(AppColors.textPrimary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                .fill(Color.gray.opacity(0.1))
        )
    }
}

// 詳細情報入力ビュー
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

// 下部ナビゲーションボタン
struct BottomNavigationView: View {
    let isFirstStep: Bool
    let isLastStep: Bool
    let onBack: () -> Void
    let onNext: () -> Void
    
    var body: some View {
        HStack {
            // 戻るボタン（最初のステップでは非表示）
            if !isFirstStep {
                Button(action: onBack) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("戻る")
                    }
                    .foregroundColor(AppColors.primary)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                            .stroke(AppColors.primary, lineWidth: 1)
                    )
                }
                .padding(.trailing, 8)
            }
            
            // 次へ/保存ボタン
            Button(action: onNext) {
                Text(isLastStep ? "保存" : "次へ")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                            .fill(AppColors.primary)
                    )
            }
        }
        .padding()
        .background(Color.white)
    }
}

struct DrinkRecordView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkRecordView(drinkDataManager: DrinkDataManager())
    }
}
