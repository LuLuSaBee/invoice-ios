//
//  InvoicePeriod.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/17.
//

import Foundation

struct InvoicePeriod {
    var year: Int
    var firstMonth: Int
    var secondMonth: Int

    var description: String {
        "\(year) 年 \(firstMonth) ~ \(secondMonth)月"
    }

    init(from firstMonth: Int, at year: Int) {
        self.year = year
        self.firstMonth = firstMonth
        self.secondMonth = firstMonth + 1
    }
}
