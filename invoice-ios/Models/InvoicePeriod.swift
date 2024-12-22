//
//  InvoicePeriod.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/17.
//

import Foundation

struct InvoicePeriod: Hashable {
    private(set) var year: Int
    private(set) var firstMonth: Int
    private(set) var secondMonth: Int

    var description: String {
        "\(year) 年 \(firstMonth) ~ \(secondMonth)月"
    }

    init(from firstMonth: Int, at year: Int) {
        self.year = year
        self.firstMonth = firstMonth
        self.secondMonth = firstMonth + 1
    }
}
