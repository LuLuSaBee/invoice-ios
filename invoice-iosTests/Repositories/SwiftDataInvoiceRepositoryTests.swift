//
//  SwiftDataInvoiceRepositoryTests.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/24.
//

@testable import invoice_ios
import Testing
import SwiftData

@Suite("Invoice Repository in Swift Data")
struct SwiftDataInvoiceRepositoryTests {
    private var repository: SwiftDataInvoiceRepository!
    private var testData = Invoice(shopName: "", numberPrefix: "AA", numberSuffix: "12345678", amount: 120, year: 2024, month: 12, day: 1)

    init() {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let modelContainer = try! ModelContainer(for: Invoice.self, InvoiceDetail.self, configurations: config)
        self.repository = SwiftDataInvoiceRepository(modelContainer: modelContainer)
    }

    @Test("Add Invoice")
    mutating func addInvoice() async throws {
        await repository.insertInvoice(testData)

        let invoices = try await repository.fetchInvoices()

        #expect(invoices.contains(testData))
    }

    @Test("Update Invoice")
    func updateInvoice() async throws {
        await repository.insertInvoice(testData)
        testData.numberSuffix = "87654321"

        let invoices = try await repository.fetchInvoices()

        #expect(invoices.contains(where: { $0.id == testData.id && $0.numberString == testData.numberString }))
    }

    @Test("Delete Invoice")
    func deleteInvoice() async throws {
        await repository.insertInvoice(testData)

        var invoices = try await repository.fetchInvoices()
        try #require(invoices.contains(testData))

        await repository.deleteInvoice(testData)

        invoices = try await repository.fetchInvoices()
        #expect(!invoices.contains(testData))
    }
}
