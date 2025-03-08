// DrinkTracker/Utils/Constants/AppIcons.swift
import SwiftUI

struct AppIcons {
    // System icons with consistent styling
    struct System {
        static let home = Image(systemName: "house.fill")
        static let stats = Image(systemName: "chart.bar.fill")
        static let health = Image(systemName: "heart.fill")
        static let settings = Image(systemName: "gearshape.fill")
        static let add = Image(systemName: "plus")
        static let calendar = Image(systemName: "calendar")
        static let clock = Image(systemName: "clock")
        static let location = Image(systemName: "location")
        static let person = Image(systemName: "person.fill")
        static let edit = Image(systemName: "pencil")
        static let delete = Image(systemName: "trash")
        static let info = Image(systemName: "info.circle")
        static let alert = Image(systemName: "exclamationmark.triangle")
        static let success = Image(systemName: "checkmark.circle")
        static let back = Image(systemName: "chevron.left")
        static let forward = Image(systemName: "chevron.right")
        static let drink = Image(systemName: "wineglass")
        static let money = Image(systemName: "yensign.circle")
        static let notification = Image(systemName: "bell")
    }
    
    // Drink type icons - DrinkIconNames に名前変更
    struct DrinkIconNames {
        static let beer = "beer"
        static let wine = "wine"
        static let spirits = "spirits"
        static let sake = "sake"
        static let cocktail = "cocktail"
        static let other = "other"
    }
    
    // Helper to get drink icon by type
    static func forDrinkType(_ type: DrinkType) -> Image {
        switch type {
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
