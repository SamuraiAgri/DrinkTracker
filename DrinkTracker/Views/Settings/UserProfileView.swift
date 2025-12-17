import SwiftUI

struct UserProfileView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    // 入力用の文字列
    @State private var weightString: String = ""
    @State private var heightString: String = ""
    
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
                    
                    // 体重入力 - TextFieldとStepperを併用
                    HStack {
                        Text("体重")
                        
                        Spacer()
                        
                        TextField("体重", text: $weightString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: weightString) { newValue in
                                if let weight = Double(newValue) {
                                    viewModel.weight = weight
                                }
                            }
                        
                        Text("kg")
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.leading, 4)
                        
                        Stepper("", value: $viewModel.weight, in: 30...200, step: 0.5)
                            .labelsHidden()
                            .onChange(of: viewModel.weight) { newValue in
                                weightString = String(format: "%.1f", newValue)
                            }
                    }
                    
                    // 身長入力 - TextFieldとStepperを併用
                    HStack {
                        Text("身長")
                        
                        Spacer()
                        
                        TextField("身長", text: $heightString)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                            .onChange(of: heightString) { newValue in
                                if let height = Double(newValue) {
                                    viewModel.height = height
                                }
                            }
                        
                        Text("cm")
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.leading, 4)
                        
                        Stepper("", value: Binding(
                            get: { viewModel.height ?? 170.0 },
                            set: { viewModel.height = $0 }
                        ), in: 100...220, step: 0.5)
                        .labelsHidden()
                        .onChange(of: viewModel.height) { newValue in
                            if let height = newValue {
                                heightString = String(format: "%.1f", height)
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
                
                Section(header: Text("休肝日目標")) {
                    Stepper(value: $viewModel.weeklyAlcoholFreeDayGoal, in: 0...7) {
                        HStack {
                            Text("週間休肝日目標")
                            Spacer()
                            Text("\(viewModel.weeklyAlcoholFreeDayGoal)日")
                                .foregroundColor(AppColors.primary)
                                .font(AppFonts.bodyBold)
                        }
                    }
                    
                    Text("週に\(viewModel.weeklyAlcoholFreeDayGoal)日以上の休肝日を設けることを目標にします。健康のために週2日以上の休肝日をおすすめします。")
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
                        // テキストフィールドから直接入力された値を反映
                        if let weight = Double(weightString) {
                            viewModel.weight = weight
                        }
                        if let height = Double(heightString) {
                            viewModel.height = height
                        }
                        
                        viewModel.saveProfile()
                        presentationMode.wrappedValue.dismiss()
                    }
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.primary)
                }
            }
            .onAppear {
                // 初期値をセット
                weightString = String(format: "%.1f", viewModel.weight)
                if let height = viewModel.height {
                    heightString = String(format: "%.1f", height)
                } else {
                    heightString = ""
                }
            }
        }
    }
}
