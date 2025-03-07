//
//  DrinkTrackerApp.swift
//  DrinkTracker
//
//  Created by iwamoto rinka on 2025/03/07.
//

import SwiftUI

@main
struct DrinkTrackerApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
