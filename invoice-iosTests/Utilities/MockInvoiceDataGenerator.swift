//
//  MockInvoiceDataGenerator.swift
//  invoice-ios
//
//  Created by 劉聖龍 on 2024/12/24.
//

@testable import invoice_ios
import Foundation

struct MockInvoiceDataGenerator {
    static private let letters = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ")

    static private func generate(length: Int, months: [Int], days: [Int]) -> [Invoice] {
        var result: [Invoice] = []
        for _ in 0..<length {
            let randomIndex = Int.random(in: 0..<letters.count)
            let numberPrefix = String(letters[randomIndex / 26]) + String(letters[randomIndex % 26])
            let randomNumber = Int.random(in: 10000000...99999999)

            let randomMonth = months.randomElement() ?? 12
            let randomDay = days.randomElement() ?? 1

            result.append(
                .init(
                    shopName: "",
                    numberPrefix: numberPrefix,
                    numberSuffix: String(randomNumber),
                    amount: Int.random(in: 1...1000),
                    year: 2024,
                    month: randomMonth,
                    day: randomDay
                )
            )
        }
        return result
    }

    static func get(months: [Int] = [12], days: [Int] = Array(1...28)) -> Invoice {
        generate(length: 1, months: months, days: days).first!
    }

    static func get(length: Int, months: [Int] = [12], days: [Int] = Array(1...28)) -> [Invoice] {
        return generate(length: length, months: months, days: days)
    }
}
