//
//  Invoice.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/13.
//

import Foundation
import SwiftData

enum InvoiceType: String, Codable {
    case manual
    case scan
}

@Model
class Invoice {
    #Unique<Invoice>([\.year, \.month, \.numberPrefix, \.numberSuffix])
    #Index<Invoice>([\.year, \.month, \.day], [\.shopName], [\.numberPrefix, \.numberSuffix])

    private(set) var type: InvoiceType

    var shopName: String
    var year: Int
    var month: Int
    var day: Int
    var numberPrefix: String
    var numberSuffix: String
    var amount: Int

    @Relationship(deleteRule: .cascade) var details: [InvoiceDetail]

    var date: Date {
        var component = DateComponents()
        component.year = year
        component.month = month
        component.day = day
        return Calendar.current.date(from: component) ?? Date()
    }

    var numberString: String {
        "\(numberPrefix)-\(numberSuffix)"
    }

    init(type: InvoiceType = .manual, shopName: String, numberPrefix: String, numberSuffix: String, amount: Int,
         year: Int, month: Int, day: Int, details: [InvoiceDetail] = []) {
        self.type = type
        self.shopName = shopName
        self.year = year
        self.month = month
        self.day = day
        self.numberPrefix = numberPrefix
        self.numberSuffix = numberSuffix
        self.amount = amount
        self.details = details
    }
}

@Model
class InvoiceDetail {
    #Index<InvoiceDetail>([\.name])

    var name: String

    @Relationship(inverse: \Invoice.details) var invoice: Invoice

    init(name: String, invoice: Invoice) {
        self.name = name
        self.invoice = invoice
    }
}
