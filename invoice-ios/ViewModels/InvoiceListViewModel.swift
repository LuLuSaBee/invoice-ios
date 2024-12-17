//
//  InvoiceListViewModel.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/17.
//

import Foundation
import Combine

protocol InvoiceListViewModelProtocol: ObservableObject {
    var period: InvoicePeriod { get }
    var invoices: [Invoice] { get }
}

class InvoiceListViewModel: InvoiceListViewModelProtocol {
    @Published var invoices: [Invoice] = []

    var period: InvoicePeriod

    private var service: InvoiceServiceable
    private var cancellables = Set<AnyCancellable>()

    deinit {
        cancellables.removeAll()
    }

    init(period: InvoicePeriod, service: InvoiceServiceable) {
        self.period = period
        self.service = service

        self.listenPublisher()
    }

    private func listenPublisher() {
        Task { @MainActor in
            let firstMonthPublisher = self.service.getInvoicePublisher(byMonth: self.period.firstMonth, year: self.period.year)
            let secondMonthPublisher = self.service.getInvoicePublisher(byMonth: self.period.secondMonth, year: self.period.year)

            secondMonthPublisher
                .zip(firstMonthPublisher, +)
                .sink {[weak self] invoices in
                    guard let self = self else { return }
                    self.invoices = invoices
                }
                .store(in: &cancellables)
        }
    }
}
