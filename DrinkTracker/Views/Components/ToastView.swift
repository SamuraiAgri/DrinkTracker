import SwiftUI

// トーストメッセージを表示するビュー
struct ToastView: View {
    let message: String
    let icon: String
    let backgroundColor: Color
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(.white)
            
            Text(message)
                .font(AppFonts.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.2), radius: 10, x: 0, y: 5)
        .padding(.horizontal)
    }
}

// トースト表示用のビューモディファイア
struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let message: String
    let icon: String
    let backgroundColor: Color
    let duration: Double
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            if isShowing {
                VStack {
                    ToastView(
                        message: message,
                        icon: icon,
                        backgroundColor: backgroundColor
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
                            withAnimation {
                                isShowing = false
                            }
                        }
                    }
                    
                    Spacer()
                }
                .padding(.top, 50)
                .zIndex(999)
            }
        }
    }
}

// View拡張でトースト表示を簡単に
extension View {
    func toast(
        isShowing: Binding<Bool>,
        message: String,
        icon: String = "checkmark.circle.fill",
        backgroundColor: Color = AppColors.success,
        duration: Double = 3.0
    ) -> some View {
        modifier(ToastModifier(
            isShowing: isShowing,
            message: message,
            icon: icon,
            backgroundColor: backgroundColor,
            duration: duration
        ))
    }
}

// プレビュー
struct ToastView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ToastView(
                message: "記録しました！今日のアルコール摂取量: 14.0g",
                icon: "checkmark.circle.fill",
                backgroundColor: AppColors.success
            )
            
            Spacer()
        }
        .padding(.top, 50)
    }
}
