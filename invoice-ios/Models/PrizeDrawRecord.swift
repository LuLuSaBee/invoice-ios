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
    #Unique<PrizeDrawRecord>([\.period])
    #Index<PrizeDrawRecord>([\.period])

    private(set) var period: InvoicePeriod
    private(set) var specialNumber: String
    private(set) var grandNumber: String
    private(set) var firstNumbers: [String]

    init(period: InvoicePeriod, specialNumber: String = "", grandNumber: String = "", firstNumbers: [String] = []) {
        self.period = period
        self.specialNumber = specialNumber
        self.grandNumber = grandNumber
        self.firstNumbers = firstNumbers
    }
}
