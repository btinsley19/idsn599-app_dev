//
//  ex5_polishedApp.swift
//  ex5_polished
//
//  Created by Brian Tinsley on 9/25/25.
//

import SwiftUI
import SwiftData

@main
struct ex5_polishedApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        // Add the model container for the DailyEntry model
        .modelContainer(for: [DailyEntry.self, PromptEntry.self])
    }
}
