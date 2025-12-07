import SwiftUI

// 折りたたみ可能なセクションビュー
struct CollapsibleSection<Content: View>: View {
    let title: String
    let icon: String?
    @Binding var isExpanded: Bool
    let content: Content
    
    init(
        title: String,
        icon: String? = nil,
        isExpanded: Binding<Bool> = .constant(true),
        @ViewBuilder content: () -> Content
    ) {
        self.title = title
        self.icon = icon
        self._isExpanded = isExpanded
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // ヘッダー
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    if let icon = icon {
                        Image(systemName: icon)
                            .font(.system(size: 16))
                            .foregroundColor(AppColors.primary)
                    }
                    
                    Text(title)
                        .font(AppFonts.title3)
                        .foregroundColor(AppColors.textPrimary)
                    
                    Spacer()
                    
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.system(size: 14))
                        .foregroundColor(AppColors.textSecondary)
                        .rotationEffect(.degrees(isExpanded ? 0 : 0))
                }
                .padding()
                .background(AppColors.cardBackground)
            }
            
            // コンテンツ
            if isExpanded {
                content
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(AppColors.cardBackground)
        .cornerRadius(AppConstants.UI.cornerRadius)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

// プレビュー
struct CollapsibleSection_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            CollapsibleSection(
                title: "週間サマリー",
                icon: "chart.bar.fill",
                isExpanded: .constant(true)
            ) {
                VStack {
                    Text("コンテンツがここに表示されます")
                        .padding()
                }
            }
            
            CollapsibleSection(
                title: "最近の記録",
                icon: "clock.fill",
                isExpanded: .constant(false)
            ) {
                VStack {
                    Text("折りたたまれています")
                        .padding()
                }
            }
        }
        .padding()
    }
}
