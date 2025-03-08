import SwiftUI

struct AnimatedProgressBar: View {
    var value: Double
    var maxValue: Double
    var height: CGFloat = 12
    var backgroundColor: Color = Color.gray.opacity(0.2)
    var foregroundColor: Color = AppColors.primary
    var showLabel: Bool = false
    var labelFormat: String = "%.0f%%"
    
    @State private var animatedWidth: CGFloat = 0
    
    private var percentage: Double {
        min(value / maxValue, 1.0) * 100
    }
    
    var body: some View {
        ZStack(alignment: .leading) {
            // Background
            RoundedRectangle(cornerRadius: height / 2)
                .fill(backgroundColor)
                .frame(height: height)
            
            // Progress bar
            RoundedRectangle(cornerRadius: height / 2)
                .fill(foregroundColor)
                .frame(width: animatedWidth, height: height)
            
            // Label
            if showLabel {
                Text(String(format: labelFormat, percentage))
                    .font(AppFonts.caption)
                    .foregroundColor(foregroundColor.contrastingTextColor())
                    .padding(.horizontal, 8)
                    .allowsHitTesting(false)
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                self.animatedWidth = CGFloat(min(self.value / self.maxValue, 1.0)) * UIScreen.main.bounds.width
            }
        }
        .onChange(of: value) { newValue in
            withAnimation(.easeInOut(duration: 0.5)) {
                self.animatedWidth = CGFloat(min(newValue / self.maxValue, 1.0)) * UIScreen.main.bounds.width
            }
        }
    }
}
