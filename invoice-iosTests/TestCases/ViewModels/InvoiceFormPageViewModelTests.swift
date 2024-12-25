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
    struct AddModeTests {
    }

    @Suite("Edit Mode")
    struct EditModeTests {
    }
}
