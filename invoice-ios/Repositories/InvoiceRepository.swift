//
//  InvoiceRepository.swift
//  invoice-ios
//
//  Created by 劉聖龍 on 2024/12/21.
//

import Foundation
import SwiftData

protocol InvoiceRepository {
    func fetchInvoices() async throws -> [Invoice]
    func insertInvoice(_ invoice: Invoice) async
    func deleteInvoice(_ invoice: Invoice) async
}

actor SwiftDataInvoiceRepository: InvoiceRepository, Sendable, ModelActor {
    nonisolated let modelExecutor: any SwiftData.ModelExecutor
    nonisolated let modelContainer: SwiftData.ModelContainer
    private var context: ModelContext { modelExecutor.modelContext }

    init(modelContainer: SwiftData.ModelContainer) {
        let modelContext = ModelContext(modelContainer)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
        self.modelContainer = modelContainer
        modelContext.autosaveEnabled = true
    }

    func fetchInvoices() async throws -> [Invoice] {
        let fetchDescriptor = FetchDescriptor<Invoice>(
            sortBy: [SortDescriptor(\.day, order: .reverse)]
        )

        return try context.fetch(fetchDescriptor)
    }

    func insertInvoice(_ invoice: Invoice) async {
        context.insert(invoice)
    }

    func deleteInvoice(_ invoice: Invoice) async {
        context.delete(invoice)
    }
}
