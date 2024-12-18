//
//  InvoiceFormViewModel.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/18.
//

import Foundation
import SwiftData
import Combine

protocol InvoiceFormViewModelProtocol: ObservableObject {
    associatedtype Mode

    var shouldMoveFocusSubject: PassthroughSubject<Void, Never> { get }
    var shopNameField: TextFieldViewModel<String> { get }
    var dateField: TextFieldViewModel<Date> { get }
    var numberPrefixField: TextFieldViewModel<String> { get }
    var numberSuffixField: TextFieldViewModel<String> { get }
    var amountField: TextFieldViewModel<Int> { get }
    var details: [InvoiceDetail] { get }
    var isLoading: Bool { get }

    func save() -> Void
}

class InvoiceFormViewModel: InvoiceFormViewModelProtocol {
    @Published var shopNameField: TextFieldViewModel<String>
    @Published var dateField: TextFieldViewModel<Date>
    @Published var numberPrefixField: TextFieldViewModel<String>
    @Published var numberSuffixField: TextFieldViewModel<String>
    @Published var amountField: TextFieldViewModel<Int>
    @Published var details: [InvoiceDetail] = []
    @Published var isLoading: Bool = false

    var shouldMoveFocusSubject = PassthroughSubject<Void, Never>()

    private let mode: Mode
    private let invoice: Invoice
    private let service: InvoiceServiceable
    private var cancellables = Set<AnyCancellable>()

    enum Mode {
        case add
        case edit(Invoice)
    }

    init(mode: Mode, service: InvoiceServiceable) {
        self.service = service
        self.mode = mode

        self.shopNameField = .init(initialValue: "")
        self.dateField = .init(initialValue: Date())

        self.amountField = .init(initialValue: 0) { amount in
            guard amount >= 0 else {
                return "金額不能為負數"
            }
            return nil
        }

        self.numberPrefixField = .init(initialValue: "") { str in
            if str.isEmpty { return nil }
            let isValid = str.count == 2 && str.range(of: "^[a-zA-Z]+$", options: .regularExpression) != nil
            return isValid ? nil : "只接受兩個字母"
        }

        self.numberSuffixField = .init(initialValue: "") { str in
            if str.isEmpty { return nil }
            let isValid = str.count == 8 && str.range(of: "^[0-9]+$", options: .regularExpression) != nil
            return isValid ? nil : "只接受八個數字"
        }

        if case let .edit(invoice) = mode,
           let date = DateComponents(year: invoice.year, month: invoice.month, day: invoice.day).date {
            self.invoice = invoice
            self.shopNameField.value = invoice.shopName
            self.dateField.value = date
            self.numberPrefixField.value = invoice.numberPrefix
            self.numberSuffixField.value = invoice.numberSuffix
            self.amountField.value = invoice.amount
            self.details = invoice.details
        } else {
            self.invoice = .init(
                shopName: "",
                numberPrefix: "",
                numberSuffix: "",
                amount: 0,
                year: Calendar.current.component(.year, from: Date()),
                month: Calendar.current.component(.month, from: Date()),
                day: Calendar.current.component(.day, from: Date())
            )
        }
    }

    func save() {
        self.isLoading = true

        self.invoice.shopName = self.shopNameField.value
        self.invoice.numberPrefix = self.numberPrefixField.value
        self.invoice.numberSuffix = self.numberSuffixField.value
        self.invoice.amount = self.amountField.value
        self.invoice.year = Calendar.current.component(.year, from: self.dateField.value)
        self.invoice.month = Calendar.current.component(.month, from: self.dateField.value)
        self.invoice.day = Calendar.current.component(.day, from: self.dateField.value)

        Task { @MainActor [weak self] in
            guard let self = self else { return }
            switch self.mode {
            case .add: self.service.addInvoice(self.invoice)
            case .edit: self.service.updateInvoice(self.invoice)
            }

            self.isLoading = false
        }
    }
}
