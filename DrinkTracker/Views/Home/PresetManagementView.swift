import SwiftUI

struct PresetManagementView: View {
    @ObservedObject var presetManager: DrinkPresetManager
    @State private var showingAddPresetSheet = false
    @State private var editingPreset: DrinkPreset? = nil
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("登録済みプリセット")) {
                    if presetManager.drinkPresets.isEmpty {
                        Text("登録されているプリセットはありません")
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.vertical, 10)
                    } else {
                        ForEach(presetManager.drinkPresets) { preset in
                            PresetListItemView(preset: preset)
                                .contentShape(Rectangle())
                                .onTapGesture {
                                    editingPreset = preset
                                }
                        }
                        .onDelete(perform: deletePresets)
                    }
                }
                
                Section {
                    Button(action: {
                        showingAddPresetSheet = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                                .foregroundColor(AppColors.primary)
                            Text("新しいプリセットを追加")
                                .foregroundColor(AppColors.primary)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("ドリンクプリセット")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAddPresetSheet) {
                PresetEditorView(
                    presetManager: presetManager,
                    mode: .add
                )
            }
            .sheet(item: $editingPreset) { preset in
                PresetEditorView(
                    presetManager: presetManager,
                    mode: .edit(preset)
                )
            }
        }
    }
    
    private func deletePresets(at offsets: IndexSet) {
        offsets.forEach { index in
            let preset = presetManager.drinkPresets[index]
            presetManager.deletePreset(preset.id)
        }
    }
}

// プリセットリストアイテム
struct PresetListItemView: View {
    let preset: DrinkPreset
    
    var body: some View {
        HStack(spacing: 12) {
            // アイコン
            ZStack {
                Circle()
                    .fill(preset.drinkType.color.opacity(0.2))
                    .frame(width: 40, height: 40)
                
                AppIcons.forDrinkType(preset.drinkType)
                    .font(.system(size: 18))
                    .foregroundColor(preset.drinkType.color)
            }
            
            // 情報
            VStack(alignment: .leading, spacing: 4) {
                Text(preset.name)
                    .font(AppFonts.bodyBold)
                    .foregroundColor(AppColors.textPrimary)
                
                HStack {
                    Text("\(Int(preset.volume))ml • \(String(format: "%.1f", preset.alcoholPercentage))%")
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textSecondary)
                    
                    if let price = preset.price {
                        Text("• ¥\(Int(price))")
                            .font(AppFonts.caption)
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                
                if let location = preset.location, !location.isEmpty {
                    Text(location)
                        .font(AppFonts.caption)
                        .foregroundColor(AppColors.textTertiary)
                }
            }
            
            Spacer()
            
            // 編集インジケーター
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.textTertiary)
                .font(.system(size: 14))
        }
        .padding(.vertical, 4)
    }
}

// プリセット編集モード
enum PresetEditMode {
    case add
    case edit(DrinkPreset)
}

// プリセット作成/編集画面
struct PresetEditorView: View {
    @ObservedObject var presetManager: DrinkPresetManager
    let mode: PresetEditMode
    
    @State private var name: String = ""
    @State private var selectedDrinkType: DrinkType = .beer
    @State private var volume: Double = 350.0
    @State private var alcoholPercentage: Double = 5.0
    @State private var price: String = ""
    @State private var location: String = ""
    @State private var note: String = ""
    
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("プリセット情報")) {
                    TextField("プリセット名（例：いつものビール）", text: $name)
                    
                    Picker("種類", selection: $selectedDrinkType) {
                        ForEach(DrinkType.allCases) { type in
                            HStack {
                                Circle()
                                    .fill(type.color)
                                    .frame(width: 10, height: 10)
                                Text(type.rawValue)
                            }.tag(type)
                        }
                    }
                    
                    // 容量
                    HStack {
                        Text("容量")
                        Spacer()
                        TextField("容量", value: $volume, formatter: NumberFormatter())
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("ml")
                    }
                    
                    // アルコール度数
                    HStack {
                        Text("度数")
                        Spacer()
                        TextField("度数", value: $alcoholPercentage, formatter: NumberFormatter())
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                        Text("%")
                    }
                    
                    // 価格
                    HStack {
                        Text("価格")
                        Spacer()
                        Text("¥")
                        TextField("価格", text: $price)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                    }
                }
                
                Section(header: Text("追加情報（任意）")) {
                    TextField("場所（例：○○居酒屋）", text: $location)
                    
                    TextField("メモ", text: $note)
                        .lineLimit(3)
                }
                
                // これをテンプレートとしてレコードを作成するセクション
                Section(footer: Text("このプリセットはクイック追加画面に表示され、すばやく記録できます。")) {
                    Button(action: savePreset) {
                        Text(isEditMode ? "更新" : "保存")
                            .foregroundColor(AppColors.primary)
                            .frame(maxWidth: .infinity, alignment: .center)
                    }
                }
            }
            .navigationTitle(isEditMode ? "プリセットを編集" : "プリセットを追加")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                setupInitialValues()
            }
        }
    }
    
    // 編集モードかどうか
    private var isEditMode: Bool {
        switch mode {
        case .add:
            return false
        case .edit:
            return true
        }
    }
    
    // 初期値の設定
    private func setupInitialValues() {
        switch mode {
        case .add:
            break
        case .edit(let preset):
            name = preset.name
            selectedDrinkType = preset.drinkType
            volume = preset.volume
            alcoholPercentage = preset.alcoholPercentage
            price = preset.price != nil ? String(format: "%.0f", preset.price!) : ""
            location = preset.location ?? ""
            note = preset.note ?? ""
        }
    }
    
    // プリセットの保存
    private func savePreset() {
        // 価格を数値に変換
        let priceValue = Double(price.replacingOccurrences(of: ",", with: ""))
        
        let preset = DrinkPreset(
            id: getPresetId(),
            name: name,
            drinkType: selectedDrinkType,
            volume: volume,
            alcoholPercentage: alcoholPercentage,
            price: priceValue,
            location: location.isEmpty ? nil : location,
            note: note.isEmpty ? nil : note
        )
        
        if isEditMode {
            presetManager.updatePreset(preset)
        } else {
            presetManager.addPreset(preset)
        }
        
        presentationMode.wrappedValue.dismiss()
    }
    
    // 編集時は既存のID、追加時は新しいIDを取得
    private func getPresetId() -> UUID {
        switch mode {
        case .add:
            return UUID()
        case .edit(let preset):
            return preset.id
        }
    }
}
