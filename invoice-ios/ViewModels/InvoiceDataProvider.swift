//
//  InvoiceDataProvider.swift
//  invoice-ios
//
//  Created by 劉聖龍 on 2024/12/22.
//

import Foundation
import Combine
import SwiftData

protocol InvoiceProvider {
    var invoicesPublisher: AnyPublisher<[Invoice], Never> { get }

    func validateUniqueInvoiceNumber(_ id: PersistentIdentifier, prefix: String, suffix: String) -> Bool
    func update(_ invoice: Invoice)
    func insert(_ invoice: Invoice) async
    func delete(_ invoice: Invoice) async
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

    func update(_ invoice: Invoice) {
        self.invoices.removeAll(where: { $0 == invoice })
        self.invoices.append(invoice)
    }

    func insert(_ invoice: Invoice) async {
        self.invoices.append(invoice)
        await repository.insertInvoice(invoice)
    }

    func delete(_ invoice: Invoice) async {
        self.invoices.removeAll(where: { $0 == invoice })
        await repository.deleteInvoice(invoice)
    }
}
