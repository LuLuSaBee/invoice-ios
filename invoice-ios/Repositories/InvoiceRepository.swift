//
//  InvoiceRepository.swift
//  invoice-ios
//
//  Created by 劉聖龍 on 2024/12/21.
//

import SwiftData

protocol InvoiceRepository {
    func fetchInvoice(_ descriptor: FetchDescriptor<Invoice>) async throws -> [Invoice]
    func insertInvoice(_ invoice: Invoice) async throws
    func deleteInvoice(_ invoice: Invoice) async throws
}

@ModelActor
actor StandardInvoiceRepository: InvoiceRepository {
    private var context: ModelContext { modelExecutor.modelContext }

    func fetchInvoice(_ descriptor: FetchDescriptor<Invoice>) async throws -> [Invoice] {
        try context.fetch(descriptor)
    }

    func insertInvoice(_ invoice: Invoice) async throws {
        context.insert(invoice)
        try context.save()
    }

    func deleteInvoice(_ invoice: Invoice) async throws {
        context.delete(invoice)
        try context.save()
    }
}
