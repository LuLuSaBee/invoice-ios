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
    private var firstNumber1: String = ""
    private var firstNumber2: String = ""
    private var firstNumber3: String = ""

    var period: InvoicePeriod {
        InvoicePeriod(from: firstMonth, at: year)
    }

    var firstNumbers: [String] {
        [firstNumber1, firstNumber2, firstNumber3]
    }

    init(period: InvoicePeriod, specialNumber: String = "", grandNumber: String = "", firstNumbers: [String] = []) {
        self.year = period.year
        self.firstMonth = period.firstMonth
        self.specialNumber = specialNumber
        self.grandNumber = grandNumber

        // WORKAROUND
        // Error: CoreData: Could not materialize Objective-C class named "Array" from declared attribute value type "Array<String>"
        if firstNumbers.indices.contains(0) {
            self.firstNumber1 = firstNumbers[0]
        }
        if firstNumbers.indices.contains(1) {
            self.firstNumber2 = firstNumbers[1]
        }
        if firstNumbers.indices.contains(2) {
            self.firstNumber3 = firstNumbers[2]
        }
    }
}
