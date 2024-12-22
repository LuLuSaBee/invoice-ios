//
//  InvoicePeriodProvider.swift
//  invoice-ios
//
//  Created by 劉聖龍 on 2024/12/22.
//

import Foundation

struct InvoicePeriodProvider {
    static func current() -> InvoicePeriod {
        let now = Date.now
        let year = Calendar.current.component(.year, from: now)
        let currentMonth = Calendar.current.component(.month, from: now)
        let startMonth = currentMonth % 2 == 0 ? currentMonth - 1 : currentMonth
        return InvoicePeriod(from: startMonth, at: year)
    }

    static func last(by period: InvoicePeriod) -> InvoicePeriod {
        if period.firstMonth == 1 {
            return InvoicePeriod(from: 11, at: period.year - 1)
        } else {
            return InvoicePeriod(from: period.firstMonth - 2, at: period.year)
        }
    }

    static func next(by period: InvoicePeriod) -> InvoicePeriod {
        if period.firstMonth == 11 {
            return InvoicePeriod(from: 1, at: period.year + 1)
        } else {
            return InvoicePeriod(from: period.firstMonth + 2, at: period.year)
        }
    }
}
