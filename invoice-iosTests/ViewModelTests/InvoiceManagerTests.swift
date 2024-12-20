//
//  InvoiceManagerTests.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/19.
//

@preconcurrency import Combine
import SwiftData
import Testing
@testable import invoice_ios

@MainActor
class InvoiceManagerTests {
    private var invoiceManager: InvoiceManager
    private var cancellables = Set<AnyCancellable>()

    private let invoice = Invoice(shopName: "Test", numberPrefix: "AD", numberSuffix: "12345678", amount: 500, year: 2024, month: 12, day: 31)

    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        do {
            let container = try ModelContainer(for: Invoice.self, InvoiceDetail.self, configurations: config)
            self.invoiceManager = InvoiceManager(container: container)

            let context = container.mainContext
            context.insert(invoice)
            try context.save()
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    @Test("Add Invoice")
    func addInvoice() async throws{
        let invoice = self.invoice
        invoice.numberSuffix = "00000001"

        invoiceManager.getInvoicePublisher(byMonth: invoice.month, year: invoice.year)
            .sink { invoices in
                #expect(invoices.contains(where: { $0.id == invoice.id }))
            }
            .store(in: &cancellables)

        try await invoiceManager.addInvoice(invoice)
    }

    @Test("Update Invoice")
    func updateInvoice() async throws {
        var invoices: [Invoice] = []
        let invoice = self.invoice
        invoice.shopName = "Test Update"

        invoiceManager.getInvoicePublisher(byMonth: invoice.month, year: invoice.year)
            .sink { invoices = $0 }
            .store(in: &cancellables)

        try await invoiceManager.updateInvoice(invoice, newDetails: invoice.details)

        #expect(invoices.contains(where: { $0.id == invoice.id && $0.shopName == "Test Update"}))

        let details = [InvoiceDetail(name: "Detail 1", invoice: invoice), InvoiceDetail(name: "Detail 2", invoice: invoice)]
        try await invoiceManager.updateInvoice(invoice, newDetails: details)

        #expect(invoices.contains(where: {
            $0.id == invoice.id &&
            $0.details.contains(details[0]) &&
            $0.details.contains(details[1])
        }))
    }

    @Test("Delete Invoice")
    func deleteInvoice() async throws {
        var invoices: [Invoice] = []

        invoiceManager.getInvoicePublisher(byMonth: invoice.month, year: invoice.year)
            .sink { invoices = $0 }
            .store(in: &cancellables)

        #expect(invoices.contains(where: { $0.id == self.invoice.id }))

        try await invoiceManager.deleteInvoice(invoice)

        #expect(invoices.isEmpty)
    }
}
