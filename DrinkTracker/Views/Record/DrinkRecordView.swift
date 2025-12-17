
import SwiftUI

struct DrinkRecordView: View {
    @StateObject var viewModel: DrinkRecordViewModel
    @Environment(\.presentationMode) var presentationMode
    
    init(drinkDataManager: DrinkDataManager, existingDrink: DrinkRecord? = nil, initialDate: Date? = nil) {
        _viewModel = StateObject(wrappedValue: DrinkRecordViewModel(
            drinkDataManager: drinkDataManager,
            existingDrink: existingDrink,
            initialDate: initialDate
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

// ボトムナビゲーションビュー
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
