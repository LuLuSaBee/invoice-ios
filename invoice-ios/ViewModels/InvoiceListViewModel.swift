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
    var winningInvoices: [WinningInvoice]? { get }
    var period: InvoicePeriod { get }
    var dayToDraw: Int { get }
    var totalInvoiceCount: Int { get }

    func drawPrizeNumber(special: String, grand: String, firsts: [String])
    func makeEditInvoiceFormPageViewModel(invoice: Invoice) -> FormViewModel
}

class InvoiceListViewModel: InvoiceListViewModelProtocol {
    @Published var groupOption: InvoiceGroupingOption = .month
    @Published var displayData: [InvoiceSectionData] = []
    @Published var winningInvoices: [WinningInvoice]? = nil
    @Published private var invoices: [Invoice] = []

    var period: InvoicePeriod
    var dayToDraw: Int

    var totalInvoiceCount: Int { invoices.count }

    typealias FormViewModel = InvoiceFormPageViewModel

    private var provider: InvoiceProvider
    private var prizeProvider: PrizeDrawRecordProvider
    private var cancellables = Set<AnyCancellable>()
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter
    }()

    init(period: InvoicePeriod, groupBy groupOption: Published<InvoiceGroupingOption>.Publisher,
         provider: InvoiceProvider, prizeProvider: PrizeDrawRecordProvider,
         prizeChecker: PrizeChecker = .init(), periodProvider: InvoicePeriodProvider = .init()) {
        self.period = period
        self.provider = provider
        self.prizeProvider = prizeProvider

        let calendar = Calendar.current
        let currentPeriod = periodProvider.current()
        let nextPeriod = periodProvider.next(from: currentPeriod)
        let today = calendar.startOfDay(for: Date())
        var components = DateComponents()
        components.year = nextPeriod.year
        components.month = nextPeriod.firstMonth
        components.day = 25
        if period == currentPeriod,
           let drawDate = calendar.date(from: components),
           let howManyDays = calendar.dateComponents([.day], from: today, to: drawDate).day {
            self.dayToDraw = howManyDays
        } else {
            self.dayToDraw = 0

            let prizePublihser = prizeProvider.recordPublisher
                .receive(on: DispatchQueue.main)
                .compactMap {[weak self] records in
                    return records.filter { $0.period == self?.period }.first
                }
                .removeDuplicates()

            prizePublihser
                .combineLatest($invoices)
                .map { record, invoices in
                    let result = prizeChecker.findWinningInvoices(invoices: invoices, prizeRecord: record)
                    return result.sorted(by: { $0.prizeType < $1.prizeType })
                }
                .assign(to: &$winningInvoices)
        }

        groupOption.assign(to: &$groupOption)

        provider.invoicesPublisher
            .receive(on: DispatchQueue.main)
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

    func drawPrizeNumber(special: String, grand: String, firsts: [String]) {
        let record = PrizeDrawRecord(period: self.period, specialNumber: special, grandNumber: grand, firstNumbers: firsts)
        self.prizeProvider.insertRecord(record)
    }

    func makeEditInvoiceFormPageViewModel(invoice: Invoice) -> FormViewModel {
        InvoiceFormPageViewModel(mode: .edit(invoice), provider: self.provider)
    }
}
