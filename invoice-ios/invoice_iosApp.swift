//
//  invoice_iosApp.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/13.
//

import SwiftUI
import SwiftData

@main
struct invoice_iosApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Invoice.self,
            InvoiceDetail.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
