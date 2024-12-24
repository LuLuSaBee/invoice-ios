//
//  PrizeDrawRecord.swift
//  invoice-ios
//
//  Created by 劉聖龍 on 2024/12/23.
//

import Foundation
import SwiftData

@Model
class PrizeDrawRecord {
    #Unique<PrizeDrawRecord>([\.year, \.firstMonth])
    #Index<PrizeDrawRecord>([\.year, \.firstMonth])

    private var year: Int
    private var firstMonth: Int

    private(set) var specialNumber: String
    private(set) var grandNumber: String
    private(set) var firstNumbers: [String]

    var period: InvoicePeriod {
        InvoicePeriod(from: firstMonth, at: year)
    }

    init(period: InvoicePeriod, specialNumber: String = "", grandNumber: String = "", firstNumbers: [String] = []) {
        self.year = period.year
        self.firstMonth = period.firstMonth
        self.specialNumber = specialNumber
        self.grandNumber = grandNumber
        self.firstNumbers = firstNumbers
    }
}
