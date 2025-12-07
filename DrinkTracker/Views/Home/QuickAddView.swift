import SwiftUI
import UIKit

struct QuickAddView: View {
    @ObservedObject var viewModel: HomeViewModel
    @ObservedObject var presetManager: DrinkPresetManager
    @State private var showingAddDrinkSheet = false
    @State private var showingTimePickerSheet = false
    @State private var showingPresetManagement = false
    @State private var selectedPreset: DrinkPreset? = nil
    @State private var selectedTime: Date = Date()
    @State private var showToast = false
    @State private var toastMessage = ""
    
    var body: some View {
        VStack(spacing: AppConstants.UI.smallPadding) {
            HStack {
                Text("クイック追加")
                    .font(AppFonts.title3)
                
                Spacer()
                
                Button(action: {
                    showingPresetManagement = true
                }) {
                    HStack {
                        Image(systemName: "gear")
                            .font(.system(size: 14))
                        Text("管理")
                            .font(AppFonts.caption)
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            // プリセット表示
            if !presetManager.drinkPresets.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        // プリセットボタン
                        ForEach(presetManager.drinkPresets) { preset in
                            PresetQuickAddButton(
                                preset: preset,
                                action: {
                                    // 長押しで時間選択、通常タップで即座に記録
                                    addDrinkFromPreset(preset, time: Date())
                                },
                                onLongPress: {
                                    selectedPreset = preset
                                    selectedTime = Date()
                                    showingTimePickerSheet = true
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
                            let defaultPreset = DrinkPreset(
                                name: "ビール",
                                drinkType: .beer,
                                volume: 350.0,
                                alcoholPercentage: 5.0
                            )
                            addDrinkFromPreset(defaultPreset, time: Date())
                        }
                    )
                    
                    // ワインクイック追加
                    QuickAddButton(
                        drinkType: .wine,
                        action: {
                            let defaultPreset = DrinkPreset(
                                name: "ワイン",
                                drinkType: .wine,
                                volume: 150.0,
                                alcoholPercentage: 12.0
                            )
                            addDrinkFromPreset(defaultPreset, time: Date())
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
        .sheet(isPresented: $showingTimePickerSheet) {
            TimePickerSheet(
                preset: selectedPreset,
                selectedTime: $selectedTime,
                onConfirm: { time in
                    if let preset = selectedPreset {
                        addPresetWithTime(preset, time)
                    }
                    showingTimePickerSheet = false
                },
                onCancel: {
                    showingTimePickerSheet = false
                }
            )
        }
        .sheet(isPresented: $showingPresetManagement) {
            PresetManagementView(presetManager: presetManager)
        }
        .toast(isShowing: $showToast, message: toastMessage, icon: "checkmark.circle.fill", backgroundColor: AppColors.primary)
    }
    
    // プリセットから飲み物を追加（時間指定あり）
    private func addPresetWithTime(_ preset: DrinkPreset, _ time: Date) {
        // プリセットの情報を使用して新しいレコードを作成
        let drinkRecord = preset.toDrinkRecord(date: time)
        
        viewModel.drinkDataManager.addDrink(drinkRecord)
        viewModel.updateDisplayData()
    }
    
    // プリセットから即座に飲み物を追加
    private func addDrinkFromPreset(_ preset: DrinkPreset, time: Date) {
        let drinkRecord = preset.toDrinkRecord(date: time)
        viewModel.drinkDataManager.addDrink(drinkRecord)
        viewModel.updateDisplayData()
        
        // ハプティックフィードバック
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        // トーストメッセージを表示
        let dailyTotal = viewModel.drinkDataManager.getDailyTotalAlcohol()
        let percentage = (dailyTotal / viewModel.recommendedDailyLimit) * 100
        
        if percentage < 50 {
            toastMessage = "記録しました！今日: \(String(format: "%.1f", dailyTotal))g（推奨量の\(Int(percentage))%）"
        } else if percentage < 75 {
            toastMessage = "記録しました！今日: \(String(format: "%.1f", dailyTotal))g（適度な量です）"
        } else if percentage < 100 {
            toastMessage = "記録しました！今日: \(String(format: "%.1f", dailyTotal))g（上限に近づいています）"
        } else {
            toastMessage = "記録しました！今日: \(String(format: "%.1f", dailyTotal))g（推奨量を超えています）"
        }
        
        withAnimation {
            showToast = true
        }
    }
}

// 時間選択シート
struct TimePickerSheet: View {
    let preset: DrinkPreset?
    @Binding var selectedTime: Date
    let onConfirm: (Date) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                if let preset = preset {
                    // プリセット情報表示
                    VStack(spacing: 16) {
                        HStack {
                            ZStack {
                                Circle()
                                    .fill(preset.drinkType.color.opacity(0.2))
                                    .frame(width: 50, height: 50)
                                
                                AppIcons.forDrinkType(preset.drinkType)
                                    .font(.system(size: 24))
                                    .foregroundColor(preset.drinkType.color)
                            }
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(preset.name)
                                    .font(AppFonts.title3)
                                
                                Text("\(Int(preset.volume))ml • \(String(format: "%.1f", preset.alcoholPercentage))%")
                                    .font(AppFonts.body)
                                    .foregroundColor(AppColors.textSecondary)
                                
                                if let price = preset.price {
                                    Text("¥\(Int(price))")
                                        .font(AppFonts.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                            .padding(.leading, 12)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        Divider()
                    }
                }
                
                Text("飲酒時間を選択")
                    .font(AppFonts.body)
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.top, 20)
                
                DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()
                
                Button(action: {
                    onConfirm(selectedTime)
                }) {
                    Text("記録する")
                        .font(AppFonts.button)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.primary)
                        .cornerRadius(AppConstants.UI.cornerRadius)
                        .padding(.horizontal)
                }
                .padding(.bottom)
            }
            .navigationBarItems(
                leading: Button("キャンセル") {
                    onCancel()
                }
            )
        }
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
                ZStack {
                    Circle()
                        .fill(Color.gray.opacity(0.1))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 28))
                        .foregroundColor(AppColors.primary)
                }
                
                Text("カスタム")
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(width: 80, height: 100)
            .padding(.vertical, 8)
        }
    }
}

// プリセットクイック追加ボタン
struct PresetQuickAddButton: View {
    let preset: DrinkPreset
    let action: () -> Void
    let onLongPress: (() -> Void)?
    
    init(preset: DrinkPreset, action: @escaping () -> Void, onLongPress: (() -> Void)? = nil) {
        self.preset = preset
        self.action = action
        self.onLongPress = onLongPress
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // アイコン部分
            ZStack {
                Circle()
                    .fill(preset.drinkType.color.opacity(0.2))
                    .frame(width: 60, height: 60)
                
                AppIcons.forDrinkType(preset.drinkType)
                    .font(.system(size: 24))
                    .foregroundColor(preset.drinkType.color)
            }
            
            // 名前
            Text(preset.name)
                .font(AppFonts.caption)
                .foregroundColor(AppColors.textPrimary)
                .lineLimit(1)
                .frame(width: 80)
        }
        .frame(width: 80, height: 100)
        .padding(.vertical, 8)
        .contentShape(Rectangle())
        .onTapGesture {
            action()
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            if let onLongPress = onLongPress {
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                onLongPress()
            }
        }
    }
}

struct QuickAddButton: View {
    let drinkType: DrinkType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(drinkType.color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    AppIcons.forDrinkType(drinkType)
                        .font(.system(size: 24))
                        .foregroundColor(drinkType.color)
                }
                
                Text(drinkType.shortName)
                    .font(AppFonts.caption)
                    .foregroundColor(AppColors.textPrimary)
            }
            .frame(width: 80, height: 100)
            .padding(.vertical, 8)
        }
    }
}
