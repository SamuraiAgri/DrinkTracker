import SwiftUI

struct NotificationSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("通知設定")) {
                    Toggle("通知を有効にする", isOn: $viewModel.notificationsEnabled)
                        .toggleStyle(SwitchToggleStyle(tint: AppColors.primary))
                    
                    if viewModel.notificationsEnabled {
                        DatePicker(
                            "リマインダー時間",
                            selection: $viewModel.preferredReminderTime,
                            displayedComponents: .hourAndMinute
                        )
                    }
                }
                
                Section(header: Text("デフォルト設定"), footer: Text("記録のリマインダーは設定した時間に毎日届きます。")) {
                    Button("デフォルト時間に設定 (20:00)") {
                        viewModel.preferredReminderTime = UserProfile.defaultReminderTime()
                    }
                    .foregroundColor(AppColors.primary)
                }
            }
            .navigationTitle("通知設定")
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
