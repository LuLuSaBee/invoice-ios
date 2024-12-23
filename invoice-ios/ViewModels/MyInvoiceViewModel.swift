//
//  MyInvoiceViewModel.swift
//  invoice-ios
//
//  Created by 劉聖龍 on 2024/12/22.
//

import Foundation
import Combine
import SwiftUI

protocol MyInvoiceViewModelProtocol: ObservableObject {
    associatedtype ListViewModel: InvoiceListViewModelProtocol
    associatedtype FormViewModel: InvoiceFormPageViewModelProtocol

    var navigationPath: NavigationPath { get set }
    var groupingOption: InvoiceGroupingOption { get }
    var displayListViewModels: [ListViewModel] { get set }
    var currentList: ListViewModel.ID? { get set }

    func loadMore()
    func tapGroupingOption()
    func makeAddInvoiceFormPageViewModel() -> FormViewModel
}

class MyInvoiceViewModel: MyInvoiceViewModelProtocol {
    @Published var navigationPath: NavigationPath = .init()
    @Published var groupingOption: InvoiceGroupingOption = .month
    @Published var displayListViewModels: [InvoiceListViewModel] = []
    @Published var currentList: InvoiceListViewModel.ID? = nil

    typealias ListViewModel = InvoiceListViewModel
    typealias FormViewModel = InvoiceFormPageViewModel

    private let provider: InvoiceProvider
    private var cancellables = Set<AnyCancellable>()

    init(provider: InvoiceProvider) {
        self.provider = provider
        self.expandDisplayLists(from: InvoicePeriodProvider.current())
        self.currentList = displayListViewModels.first!.id
    }

    private func expandDisplayLists(from start: InvoicePeriod) {
        let previous = InvoicePeriodProvider.previous(by: start)
        let earlier = InvoicePeriodProvider.previous(by: previous)

        self.displayListViewModels.append(contentsOf: [
            .init(period: start, groupBy: $groupingOption, provider: provider, path: navigationPath),
            .init(period: previous, groupBy: $groupingOption, provider: provider, path: navigationPath),
            .init(period: earlier, groupBy: $groupingOption, provider: provider, path: navigationPath),
        ])
    }

    func loadMore() {
        guard let current = displayListViewModels.last?.period else { return }
        let start = InvoicePeriodProvider.previous(by: current)
        self.expandDisplayLists(from: start)
    }

    func tapGroupingOption() {
        switch groupingOption {
        case .day: groupingOption = .month
        case .month: groupingOption = .day
        }
    }

    func makeAddInvoiceFormPageViewModel() -> FormViewModel {
        InvoiceFormPageViewModel(mode: .add, provider: provider)
    }
}
