import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("基本情報")) {
                    TextField("名前", text: $viewModel.displayName)
                    
                    Picker("性別", selection: $viewModel.gender) {
                        ForEach(UserProfile.Gender.allCases, id: \.self) { gender in
                            Text(gender.rawValue).tag(gender)
                        }
                    }
                    
                    DatePicker(
                        "生年月日",
                        selection: $viewModel.birthDate,
                        displayedComponents: .date
                    )
                    .datePickerStyle(WheelDatePickerStyle())
                    
                    Stepper(value: $viewModel.weight, in: 30...200, step: 0.5) {
                        HStack {
                            Text("体重")
                            Spacer()
                            Text("\(String(format: "%.1f", viewModel.weight)) kg")
                                .foregroundColor(AppColors.textSecondary)
                        }
                    }
                    
                    Stepper(value: Binding(
                        get: { viewModel.height ?? 170.0 },
                        set: { viewModel.height = $0 }
                    ), in: 100...220, step: 0.5) {
                        HStack {
                            Text("身長")
                            Spacer()
                            if let height = viewModel.height {
                                Text("\(String(format: "%.1f", height)) cm")
                                    .foregroundColor(AppColors.textSecondary)
                            } else {
                                Text("未設定")
                                    .foregroundColor(AppColors.textTertiary)
                            }
                        }
                    }
                }
                
                Section(header: Text("飲酒目標")) {
                    Picker("目標", selection: $viewModel.drinkingGoal) {
                        ForEach(UserProfile.DrinkingGoal.allCases, id: \.self) { goal in
                            Text(goal.rawValue).tag(goal)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    
                    Text(viewModel.drinkingGoal.description)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.vertical, 8)
                }
                
                Section(header: Text("予算設定")) {
                    HStack {
                        Text("週間予算")
                        Spacer()
                        Text("¥")
                            .foregroundColor(AppColors.textSecondary)
                        TextField("金額を入力", text: $viewModel.weeklyBudget)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                    
                    Text("週間の飲酒支出予算を設定すると、節約目標を立てるのに役立ちます。")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                        .padding(.vertical, 8)
                }
            }
            .navigationTitle("プロフィール設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("保存") {
                        viewModel.saveProfile()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.primary)
                }
            }
        }
    }
}
