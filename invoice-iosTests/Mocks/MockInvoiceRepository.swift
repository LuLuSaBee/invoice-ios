//
//  MockInvoiceRepository.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/24.
//

@testable import invoice_ios

class MockInvoiceRepository: InvoiceRepository {
    private var invoices: [Invoice]

    init(initialData invoices: [Invoice] = []) {
        self.invoices = invoices
    }

    func fetchInvoices() async throws -> [Invoice] {
        invoices
    }

    func insertInvoice(_ invoice: Invoice) async {
        invoices.append(invoice)
    }

    func deleteInvoice(_ invoice: Invoice) async {
        invoices.removeAll(where: { $0 == invoice })
    }
}
