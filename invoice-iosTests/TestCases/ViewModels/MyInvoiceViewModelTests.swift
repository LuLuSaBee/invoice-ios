//
//  MyInvoiceViewModelTests.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/25.
//

@testable import invoice_ios
import Testing
import Combine

@Suite("My Invoice View Model Test")
class MyInvoiceViewModelTests {
    private var viewModel: MyInvoiceViewModel!
    private var cancellables = Set<AnyCancellable>()

    init() {
        let provider = MockInvoiceProvider()
        viewModel = MyInvoiceViewModel(provider: provider)
    }

    @Test("Tap Grouping Option", arguments: zip(
        [InvoiceGroupingOption.month, .day],
        [InvoiceGroupingOption.day, .month]
    ))
    func tapGroupingOption(old: InvoiceGroupingOption, new: InvoiceGroupingOption) async {
        viewModel.groupingOption = old

        let newOption = await withCheckedContinuation { continuation in
            viewModel.$groupingOption
                .dropFirst()
                .sink { continuation.resume(returning: $0) }
                .store(in: &cancellables)

            viewModel.tapGroupingOption()
        }

        #expect(newOption == new)
    }

    @Test("Load More List View Model")
    func loadMore() async {
        let count = viewModel.displayListViewModels.count

        let newCount = await withCheckedContinuation { continuation in
            viewModel.$displayListViewModels
                .dropFirst()
                .sink { continuation.resume(returning: $0.count) }
                .store(in: &cancellables)

            viewModel.loadMore()
        }

        #expect(newCount > count)
    }
}
