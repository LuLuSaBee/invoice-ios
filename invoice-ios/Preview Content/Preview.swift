//
//  Preview.swift
//  invoice-ios
//
//  Created by 劉聖龍 on 2024/12/16.
//

import SwiftData

struct Preview {
    let modelContainer: ModelContainer
    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            modelContainer = try ModelContainer(for: Invoice.self, configurations: config)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
    }

    func addExamples(_ examples: [Invoice]) {
        Task { @MainActor in
            examples.forEach { example in
                modelContainer.mainContext.insert(example)
            }
        }

    }
}
