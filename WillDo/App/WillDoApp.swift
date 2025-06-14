//
//  WillDoApp.swift
//  WillDo
//
//  Created by 高野　泰生 on 2025/05/31.
//

import SwiftUI
import SwiftData

@main
struct WillDoApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            WillDo.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    @StateObject var dataService = DataService()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataService)
        }
        .modelContainer(sharedModelContainer)
    }
}
