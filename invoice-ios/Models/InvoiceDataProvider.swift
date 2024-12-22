//
//  InvoiceDataProvider.swift
//  invoice-ios
//
//  Created by 劉聖龍 on 2024/12/22.
//

import Combine

enum InvoiceProviderError: Error {
    case duplicateInvoice
}

protocol InvoiceProvider {
    var invoicesPublisher: AnyPublisher<[Invoice], Never> { get }

    func refresh() async throws
    func insert(_ invoice: Invoice) throws
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

    func refresh() async throws {
        self.invoices = try await repository.fetchInvoices()
    }

    func insert(_ invoice: Invoice) throws {
        if let _ = self.invoices.first(where: { $0.numberString == invoice.numberString }) {
            throw InvoiceProviderError.duplicateInvoice
        }

        self.invoices.append(invoice)
        Task {
            await repository.insertInvoice(invoice)
        }
    }

    func delete(_ invoice: Invoice) {
        self.invoices.removeAll(where: { $0 == invoice })
        Task {
            await repository.deleteInvoice(invoice)
        }
    }
}
