//
//  InvoiceDataProvider.swift
//  invoice-ios
//
//  Created by 劉聖龍 on 2024/12/22.
//

import Combine
import SwiftData

protocol InvoiceProvider {
    var invoicesPublisher: AnyPublisher<[Invoice], Never> { get }

    func validateUniqueInvoiceNumber(_ id: PersistentIdentifier, prefix: String, suffix: String) -> Bool
    func insert(_ invoice: Invoice)
    func update(_ invoice: Invoice)
    func delete(_ invoice: Invoice)
}

final class InvoiceDataProvider: InvoiceProvider {
    var invoicesPublisher: AnyPublisher<[Invoice], Never> {
        $invoices.eraseToAnyPublisher()
    }

    @Published private var invoices: [Invoice] = []

    private let repository: InvoiceRepository

    init(repository: InvoiceRepository) {
        self.repository = repository

        Task {
            do {
                try await self.refresh()
            } catch {
                print("Failed to fetch invoices: \(error)")
            }
        }
    }

    private func refresh() async throws {
        self.invoices = try await repository.fetchInvoices()
    }

    func validateUniqueInvoiceNumber(_ id: PersistentIdentifier, prefix: String, suffix: String) -> Bool {
        self.invoices.first(where: { $0.numberPrefix == prefix && $0.numberSuffix == suffix && $0.id != id }) == nil
    }

    func insert(_ invoice: Invoice) {
        self.invoices.append(invoice)
        Task {
            await repository.insertInvoice(invoice)
        }
    }

    func update(_ invoice: Invoice) {
        self.invoices.removeAll(where: { $0 == invoice })
        self.invoices.append(invoice)
    }

    func delete(_ invoice: Invoice) {
        self.invoices.removeAll(where: { $0 == invoice })
        Task {
            await repository.deleteInvoice(invoice)
        }
    }
}
