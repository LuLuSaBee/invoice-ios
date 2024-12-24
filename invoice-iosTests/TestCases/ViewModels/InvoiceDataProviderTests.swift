//
//  InvoiceDataProvider.swift
//  invoice-ios
//
//  Created by 劉聖龍 on 2024/12/24.
//

@testable import invoice_ios
import Testing
import Combine

@Suite("Invoice Data Provider", .serialized)
class InvoiceDataProviderTests {
    private let provider: InvoiceDataProvider
    private let mockRepository: MockInvoiceRepository
    private var cancellables = Set<AnyCancellable>()

    init() {
        let repository = MockInvoiceRepository()
        self.mockRepository = repository
        self.provider = InvoiceDataProvider(repository: repository)
    }

    @Test("Check Initial Data")
    func initialData() async throws {
        let mockDatas = MockInvoiceDataGenerator.get(length: 5)
        mockRepository.invoices = mockDatas

        try await provider.refresh()

        let invoices = await withCheckedContinuation { continuation in
            provider.invoicesPublisher
                .sink { continuation.resume(returning: $0) }
                .store(in: &cancellables)
        }

        #expect(invoices == mockDatas)
    }

    @Test("Insert Invoice")
    func insertInvoice() async {
        let mockData = MockInvoiceDataGenerator.get()

        await provider.insert(mockData)

        let invoices = await withCheckedContinuation { continuation in
            provider.invoicesPublisher
                .first()
                .sink { continuation.resume(returning: $0) }
                .store(in: &cancellables)
        }

        #expect(invoices.first == mockData)
    }

    @Test("Update Invoice")
    func updateInvoice() async {
        let mockData = MockInvoiceDataGenerator.get()
        await provider.insert(mockData)
        mockData.numberPrefix = "UI"
        provider.update(mockData)

        let invoices = await withCheckedContinuation { continuation in
            provider.invoicesPublisher
                .first()
                .sink { continuation.resume(returning: $0) }
                .store(in: &cancellables)
        }

        #expect(invoices.first?.numberString == mockData.numberString)
    }

    @Test("Delete Invoice")
    func deleteInvoice() async throws {
        let mockData1 = MockInvoiceDataGenerator.get()
        let mockData2 = MockInvoiceDataGenerator.get()
        await provider.insert(mockData1)
        await provider.insert(mockData2)

        await provider.delete(mockData1)

        let invoices = await withCheckedContinuation { continuation in
            provider.invoicesPublisher
                .first()
                .sink { continuation.resume(returning: $0) }
                .store(in: &cancellables)
        }

        #expect(
            !invoices.contains(where: { $0.id == mockData1.id }) &&
            invoices.contains(where: { $0.id == mockData2.id })
        )
    }

    @Test("Check Unique Number")
    func checkUniqueNumber() async {
        let mockData1 = MockInvoiceDataGenerator.get()
        let mockData2 = MockInvoiceDataGenerator.get()

        await provider.insert(mockData1)

        #expect(provider.validateUniqueInvoiceNumber(mockData1.id, prefix: mockData1.numberPrefix, suffix: mockData1.numberSuffix))
        #expect(!provider.validateUniqueInvoiceNumber(mockData2.id, prefix: mockData1.numberPrefix, suffix: mockData1.numberSuffix))
    }
}
