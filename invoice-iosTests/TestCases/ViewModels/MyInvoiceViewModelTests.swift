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
        var optionPublisher = viewModel.$groupingOption.values.makeAsyncIterator()

        viewModel.tapGroupingOption()
        let newOption = await optionPublisher.next()

        #expect(newOption == new)
    }

    @Test("Load More List View Model")
    func loadMore() async throws {
        let count = viewModel.displayListViewModels.count
        var displayPublisher = viewModel.$displayListViewModels.values.makeAsyncIterator()

        viewModel.loadMore()
        let newCount = try #require(await displayPublisher.next()?.count)

        #expect(newCount > count)
    }
}
