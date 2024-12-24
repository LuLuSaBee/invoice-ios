//
//  InvoiceListViewModel.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/17.
//

import Foundation
import Combine
import SwiftUI

protocol InvoiceListViewModelProtocol: ObservableObject, Identifiable {
    associatedtype FormViewModel: InvoiceFormPageViewModelProtocol

    var groupOption: InvoiceGroupingOption { get }
    var displayData: [InvoiceSectionData] { get }
    var period: InvoicePeriod { get }

    func makeEditInvoiceFormPageViewModel(invoice: Invoice) -> FormViewModel
    func refresh() async
}

class InvoiceListViewModel: InvoiceListViewModelProtocol {
    @Published var groupOption: InvoiceGroupingOption = .month
    @Published var displayData: [InvoiceSectionData] = []
    @Published private var invoices: [Invoice] = []

    var period: InvoicePeriod

    typealias FormViewModel = InvoiceFormPageViewModel

    private var provider: InvoiceProvider
    private var cancellables = Set<AnyCancellable>()
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter
    }()

    init(period: InvoicePeriod, groupBy groupOption: Published<InvoiceGroupingOption>.Publisher, provider: InvoiceProvider) {
        self.period = period
        self.provider = provider

        groupOption.assign(to: &$groupOption)

        provider.invoicesPublisher
            .map { invoices in
                invoices.filter { invoice in
                    invoice.year == period.year &&
                    (invoice.month == period.firstMonth || invoice.month == period.secondMonth)
                }
            }
            .map { $0.sorted { $0.date > $1.date } }
            .removeDuplicates()
            .assign(to: &$invoices)

        groupOption.combineLatest($invoices)
            .map(groupData)
            .assign(to: &$displayData)
    }

    private func formatDate(_ date: Date, formatter: String) -> String {
        dateFormatter.dateFormat = formatter
        return dateFormatter.string(from: date)
    }

    private func groupData(by groupOption: InvoiceGroupingOption, data: [Invoice]) -> [InvoiceSectionData] {
        var grouped: [String: [Invoice]]
        switch groupOption {
        case .month:
            grouped = Dictionary(grouping: data) { invoice in
                formatDate(invoice.date, formatter: "MMMM")
            }
        case .day:
            grouped = Dictionary(grouping: data) { invoice in
                "\(String(format: "%02d", invoice.month))/\(String(format: "%02d", invoice.day)) \(formatDate(invoice.date, formatter: "EEE"))"
            }
        }

        return grouped.map { (key, invoices) in
            let totalAmount = invoices.reduce(0) { $0 + $1.amount }
            return InvoiceSectionData(title: key, totalAmount: totalAmount, invoices: invoices)
        }
        .sorted { $0.title > $1.title }
    }

    func makeEditInvoiceFormPageViewModel(invoice: Invoice) -> FormViewModel {
        InvoiceFormPageViewModel(mode: .edit(invoice), provider: self.provider)
    }

    func refresh() async {
        do {
            try await self.provider.refresh()
        } catch {
            print("Error refreshing invoices: \(error)")
        }
    }
}
