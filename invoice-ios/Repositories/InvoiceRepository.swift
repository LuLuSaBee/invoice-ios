//
//  InvoiceRepository.swift
//  invoice-ios
//
//  Created by 劉聖龍 on 2024/12/21.
//

import Foundation
import SwiftData

protocol InvoiceRepository {
    func fetchInvoices(forYear year: Int, month: Int) async throws -> [Invoice]
    func insertInvoice(_ invoice: Invoice) async
    func deleteInvoice(_ invoice: Invoice) async
}

@ModelActor
actor SwiftDataInvoiceRepository: InvoiceRepository, Sendable {
    private var context: ModelContext { modelExecutor.modelContext }

    init(config: ModelConfiguration) {
        let container = try! ModelContainer(for: Invoice.self, InvoiceDetail.self, configurations: config)
        let modelContext = ModelContext(container)
        self.modelExecutor = DefaultSerialModelExecutor(modelContext: modelContext)
        self.modelContainer = container
    }

    func fetchInvoices(forYear year: Int, month: Int) async throws -> [Invoice] {
        let fetchDescriptor = FetchDescriptor<Invoice>(
            predicate: #Predicate { $0.year == year && $0.month == month },
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
