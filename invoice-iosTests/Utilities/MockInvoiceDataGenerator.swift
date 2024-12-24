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

    static private func generate(length: Int) -> [Invoice] {
        var result: [Invoice] = []
        for _ in 0..<length {
            let randomIndex = Int.random(in: 0..<letters.count)
            let numberPrefix = String(letters[randomIndex / 26]) + String(letters[randomIndex % 26])
            let randomNumber = Int.random(in: 10000000...99999999)
            result.append(.init(shopName: "", numberPrefix: numberPrefix, numberSuffix: String(randomNumber), amount: 0, year: 2024, month: 12, day: 01))
        }
        return result
    }

    static func get() -> Invoice {
        generate(length: 1).first!
    }

    static func get(length: Int) -> [Invoice] {
        return generate(length: length)
    }
}
