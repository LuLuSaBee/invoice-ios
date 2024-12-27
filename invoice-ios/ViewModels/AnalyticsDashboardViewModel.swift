//
//  AnalyticsDashboardViewModel.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/26.
//

import Foundation
import Combine

protocol AnalyticsDashboardViewModelProtocol: ObservableObject {
    var duration: DashboardDuration { get set }
    var chartData: [ChartData] { get }
    var maxData: ChartData? { get }
}

class AnalyticsDashboardViewModel: AnalyticsDashboardViewModelProtocol {
    @Published var duration: DashboardDuration = .week
    @Published var chartData: [ChartData] = []
    @Published var maxData: ChartData?

    private let startAt: Date
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter
    }()

    init(from: Date = .now, invoiceProvider: InvoiceProvider) {
        self.startAt = from

        $duration
            .removeDuplicates()
            .combineLatest(invoiceProvider.invoicesPublisher)
            .receive(on: DispatchQueue.main)
            .map { [weak self] duration, invoices in
                guard let self = self else { return [] }
                return self.calculateChartData(duration: duration, invoices: invoices)
            }
            .assign(to: &$chartData)

        $chartData
            .map { $0.max(by: { $0.amount < $1.amount }) }
            .assign(to: &$maxData)
    }

    private func calculateChartData(duration: DashboardDuration, invoices: [Invoice]) -> [ChartData] {
        let calendar = Calendar.current
        let dates: [Date]
        let groupingKey: (Invoice) -> Date
        let getName: (Date) -> String

        switch duration {
        case .week:
            dates = (0..<7).map {
                calendar.startOfDay(for: calendar.date(byAdding: .day, value: -$0, to: startAt)!)
            }.reversed()
            groupingKey = { calendar.startOfDay(for: $0.date) }
            getName = { self.formatDate($0, formatter: "MM/dd") }

        case .month:
            dates = (0..<4).map {
                calendar.dateInterval(of: .weekOfYear, for: calendar.date(byAdding: .weekOfYear, value: -$0, to: startAt)!)!.start
            }.reversed()
            groupingKey = { calendar.dateInterval(of: .weekOfYear, for: $0.date)?.start ?? calendar.startOfDay(for: $0.date) }
            getName = { startOfWeek in
                let endOfWeek = calendar.date(byAdding: .day, value: -1, to: calendar.dateInterval(of: .weekOfYear, for: startOfWeek)?.end ?? startOfWeek)!
                let startString = self.formatDate(startOfWeek, formatter: "MM/dd")
                let endString = self.formatDate(endOfWeek, formatter: "MM/dd")

                return "\(startString) - \(endString)"
            }

        case .year:
            dates = (0..<12).map {
                calendar.dateInterval(of: .month, for: calendar.date(byAdding: .month, value: -$0, to: startAt)!)!.start
            }.reversed()
            groupingKey = { calendar.dateInterval(of: .month, for: $0.date)?.start ?? calendar.startOfDay(for: $0.date) }
            getName = { self.formatDate($0, formatter: "MMM") }
        }

        let filteredInvoices = invoices.filter { invoice in
            let invoiceDate = groupingKey(invoice)
            return dates.contains(invoiceDate)
        }

        let groupedInvoices = Dictionary(grouping: filteredInvoices, by: groupingKey)

        return dates.map { date in
            let totalAmount = groupedInvoices[date]?.reduce(0) { $0 + $1.amount } ?? 0
            return ChartData(name: getName(date), amount: totalAmount)
        }
    }

    private func formatDate(_ date: Date, formatter: String) -> String {
        dateFormatter.dateFormat = formatter
        return dateFormatter.string(from: date)
    }
}
