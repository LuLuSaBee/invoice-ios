//
//  MockInvoiceProvider.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/25.
//

@testable import invoice_ios
import Foundation
import Combine
import SwiftData

class MockInvoiceProvider: InvoiceProvider {
    var invoicesPublisher: AnyPublisher<[Invoice], Never> {
        $invoices.eraseToAnyPublisher()
    }

    @Published var invoices: [Invoice] = []

    init(initiaData: [Invoice] = []) {
        self.invoices = initiaData
    }

    func validateUniqueInvoiceNumber(_ id: PersistentIdentifier, prefix: String, suffix: String) -> Bool {
        self.invoices.first(where: { $0.numberPrefix == prefix && $0.numberSuffix == suffix && $0.id != id }) == nil
    }

    func update(_ invoice: Invoice) {
        if let index = invoices.firstIndex(where: { $0 == invoice }) {
            invoices[index] = invoice
        } else {
            invoices.append(invoice)
        }
    }

    func insert(_ invoice: Invoice) async {
        self.invoices.append(invoice)
    }

    func delete(_ invoice: Invoice) async {
        self.invoices.removeAll(where: { $0 == invoice })
    }
}
