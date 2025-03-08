import SwiftUI

struct DrinkTypeIcon: View {
    let drinkType: DrinkType
    let size: CGFloat
    var isSelected: Bool = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isSelected ? drinkType.color : Color.gray.opacity(0.1))
                .frame(width: size, height: size)
            
            getIconForType()
                .font(.system(size: size * 0.4))
                .foregroundColor(isSelected ? .white : drinkType.color)
        }
    }
    
    private func getIconForType() -> Image {
        switch drinkType {
        case .beer:
            return Image(systemName: "mug.fill")
        case .wine:
            return Image(systemName: "wineglass.fill")
        case .spirits:
            return Image(systemName: "cup.and.saucer.fill")
        case .sake:
            return Image(systemName: "takeoutbag.and.cup.and.straw.fill")
        case .cocktail:
            return Image(systemName: "waterbottle.fill")
        case .other:
            return Image(systemName: "drop.fill")
        }
    }
}
