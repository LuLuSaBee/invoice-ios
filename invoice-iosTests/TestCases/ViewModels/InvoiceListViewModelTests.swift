//
//  InvoiceListViewModelTests.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/25.
//

@testable import invoice_ios
import Testing
import Combine
import Foundation

private let mockDataLength = 5

@Suite("Invoice List View Model")
class InvoiceListViewModelTests {
    @Published private var groupOption: InvoiceGroupingOption = .month

    private let period: InvoicePeriod
    private let provider: MockInvoiceProvider
    private var viewModel: InvoiceListViewModel!
    private var cancellables = Set<AnyCancellable>()

    init() {
        self.period = InvoicePeriodProvider().current(at: Date(timeIntervalSince1970: 1735098125)) // 2024/12/25
        self.provider = MockInvoiceProvider()
        self.viewModel = .init(period: period, groupBy: $groupOption, provider: provider)
    }

    @Test("Sync group option")
    func syncGroupOption() {
        groupOption = .day

        #expect(viewModel.groupOption == .day)
    }

    @Test("Check display data", arguments: zip(
        [InvoiceGroupingOption.month, .day],
        [2, 3]
    ))
    func checkDisplayData(groupOption: InvoiceGroupingOption, expect: Int) async {
        let mockData1 = MockInvoiceDataGenerator.get(months: [10], days: [1])
        let mockData2 = MockInvoiceDataGenerator.get(months: [11], days: [1])
        let mockData3 = MockInvoiceDataGenerator.get(months: [12], days: [1])
        let mockData4 = MockInvoiceDataGenerator.get(months: [12], days: [2])

        self.groupOption = groupOption

        let displayData = await withCheckedContinuation { continuation in
            viewModel.$displayData
                .dropFirst()
                .sink { continuation.resume(returning: $0) }
                .store(in: &cancellables)

            provider.invoices.append(contentsOf: [mockData1, mockData2, mockData3, mockData4])
        }

        #expect(displayData.count == expect)
    }
}
