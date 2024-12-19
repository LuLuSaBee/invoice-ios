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
    func testAddInvoice() {
        var invoices: [Invoice] = []
        let invoice = self.invoice
        invoice.numberSuffix = "00000001"

        invoiceManager.getInvoicePublisher(byMonth: invoice.month, year: invoice.year)
            .sink { invoices = $0 }
            .store(in: &cancellables)

        invoiceManager.addInvoice(invoice)

        #expect(invoices.contains(where: { $0.id == invoice.id }))
    }

    @Test("Update Invoice")
    func testUpdateInvoice() {
        var invoices: [Invoice] = []

        let invoice = self.invoice
        invoice.shopName = "Test Update"

        invoiceManager.getInvoicePublisher(byMonth: invoice.month, year: invoice.year)
            .sink { invoices = $0 }
            .store(in: &cancellables)

        invoiceManager.updateInvoice(invoice, newDetails: invoice.details)

        #expect(
            invoices.contains(where: { $0.id == invoice.id && $0.shopName == "Test Update"}),
            "Update invoice shopName success."
        )

        let details = [InvoiceDetail(name: "Detail 1", invoice: invoice), InvoiceDetail(name: "Detail 2", invoice: invoice)]
        invoiceManager.updateInvoice(invoice, newDetails: details)

        print(invoices)

        #expect(invoices.contains(where: { $0.id == invoice.id && $0.details.contains(details)}))
    }

    @Test("Delete Invoice")
    func testDeleteInvoice() {
        var invoices: [Invoice] = []

        invoiceManager.getInvoicePublisher(byMonth: 12, year: 2024)
            .sink { invoices = $0 }
            .store(in: &cancellables)

        #expect(invoices.contains(where: { $0.id == self.invoice.id }))

        invoiceManager.deleteInvoice(invoice)

        #expect(invoices.isEmpty)
    }
}
