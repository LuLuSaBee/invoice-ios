//
//  InvoiceFormPageViewModelTests.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/25.
//

@testable import invoice_ios
import Testing
import Combine

@Suite("Invoice Form Page View Model")
class InvoiceFormPageViewModelTests {
    private let mockInvoice = MockInvoiceDataGenerator.get(months: [12])
    private let mockProvider: InvoiceProvider
    private var viewModel: InvoiceFormPageViewModel!
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.mockProvider = MockInvoiceProvider(initiaData: [mockInvoice])
        self.viewModel = .init(mode: .add, provider: mockProvider)
    }

    @Test("Auto Move Focus")
    func autoMoveFocus() async throws {
        await confirmation(expectedCount: 2) { moveFocus in
            await withCheckedContinuation { continuation in
                viewModel.shouldMoveFocusSubject
                    .map { _ in moveFocus() }
                    .dropFirst()
                    .sink { _ in continuation.resume() }
                    .store(in: &cancellables)

                viewModel.numberPrefixField.value = "AA"
                viewModel.numberSuffixField.value = "12345678"
            }
        }
    }

    @Test("Add Detail")
    func addDetail() async throws {
        var detailPublisher = viewModel.$details.values.makeAsyncIterator()

        let newDetail = viewModel.addDetail()
        let details = try #require(await detailPublisher.next())

        #expect(details.contains(newDetail))
    }

    @Test("Delete Detail")
    func deleteDetail() async throws {
        let mockDatail = InvoiceDetail(name: "", invoice: mockInvoice)
        var detailPublisher = viewModel.$details.values.makeAsyncIterator()
        viewModel.details = [mockDatail]

        viewModel.deleteDetail(at: mockDatail)
        let details = try #require(await detailPublisher.next())

        #expect(details.isEmpty)
    }

    @Test("Save With NonUnique Invoice Number")
    func saveWithNonUniqueNumber() async {
        viewModel.numberPrefixField.value = mockInvoice.numberPrefix
        viewModel.numberSuffixField.value = mockInvoice.numberSuffix

        let result = await viewModel.save()

        #expect(result == false)
    }

    @Suite("Add Mode")
    class AddModeTests {
        private let mockProvider: MockInvoiceProvider
        private var viewModel: InvoiceFormPageViewModel!

        init() {
            self.mockProvider = MockInvoiceProvider()
            self.viewModel = .init(mode: .add, provider: mockProvider)
        }

        @Test("Insert Invoice")
        func save() async throws {
            viewModel.numberPrefixField.value = "AA"
            viewModel.numberSuffixField.value = "12345678"

            try #require(await viewModel.save())

            let result = mockProvider.invoices.first(where: { $0.numberString == "AA-12345678" }) != nil

            #expect(result)
        }
    }

    @Suite("Edit Mode")
    class EditModeTests {
        private let mockInvoice = MockInvoiceDataGenerator.get(months: [12])
        private var mockProvider: MockInvoiceProvider!
        private var viewModel: InvoiceFormPageViewModel!
        private var cancellables = Set<AnyCancellable>()

        init() {
            let details = [
                InvoiceDetail(name: "Test Detail1", invoice: mockInvoice),
                InvoiceDetail(name: "Test Detail2", invoice: mockInvoice),
            ]
            mockInvoice.details = details
            self.mockProvider = MockInvoiceProvider(initiaData: [mockInvoice])
            self.viewModel = .init(mode: .edit(mockInvoice), provider: mockProvider)
        }

        @Test("Update Invoice")
        func save() async throws {
            viewModel.details[0].name = ""
            viewModel.amountField.value = 999

            try #require(await viewModel.save())

            let inDBInvoice = try #require(mockProvider.invoices.first(where: { $0 == self.mockInvoice }))

            #expect(inDBInvoice.amount == 999)
            #expect(inDBInvoice.details.count == 1)
        }

        @Test("Delete Invoice")
        func delete() async {
            await viewModel.delete()

            #expect(mockProvider.invoices.isEmpty)
        }
    }
}
