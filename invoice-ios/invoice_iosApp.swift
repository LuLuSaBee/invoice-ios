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

        let container: ModelContainer
        do {
            container = try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }

        let context = container.mainContext
        let existingInvoices = try? context.fetch(FetchDescriptor<Invoice>())
        if existingInvoices?.isEmpty ?? true {
            Invoice.sampleData.forEach { context.insert($0) }
            do {
                try context.save()
            } catch {
                fatalError("Could not save sample data: \(error)")
            }
        }

        return container
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
