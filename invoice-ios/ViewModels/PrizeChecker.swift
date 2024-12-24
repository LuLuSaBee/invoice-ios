//
//  PrizeChecker.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/24.
//

struct PrizeChecker {
    static private let prizeSetArray: [InvoicePrizeType?] = [nil, nil, nil, .sixth, .fifth, .fourth, .third, .second, .first]

    static func findWinningInvoices(invoices: [Invoice], prizeRecord: PrizeDrawRecord) -> [WinningInvoice] {
        invoices.reduce(into: []) { result, invoice in
            if let prizeType = getPrizeType(invoice.numberSuffix, prizeRecord) {
                result.append(WinningInvoice(prize: prizeType, invoice: invoice))
            }
        }
    }

    static private func getPrizeType(_ number: String, _ record: PrizeDrawRecord) -> InvoicePrizeType? {
        if record.specialNumber == number {
            return .special
        } else if record.grandNumber == number {
            return .grand
        } else if record.firstNumbers.contains(number) {
            return .first
        }

        var max = 0
        record.firstNumbers.forEach { firstNumber in
            let similarity = compareSimilarity(firstNumber, number)
            max = similarity > max ? similarity : max
        }

        return prizeSetArray[max]
    }

    static private func compareSimilarity(_ str1: String, _ str2: String) -> Int {
        let reversedStr1 = str1.reversed()
        let reversedStr2 = str2.reversed()

        var similarity = 0

        for (char1, char2) in zip(reversedStr1, reversedStr2) {
            if char1 == char2 {
                similarity += 1
            } else {
                break
            }
        }

        return similarity
    }
}
