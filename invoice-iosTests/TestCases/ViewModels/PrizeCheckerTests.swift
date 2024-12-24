//
//  PrizeCheckerTests.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/24.
//

@testable import invoice_ios
import Testing

@Suite("Prize Checker")
struct PrizeCheckerTests {
    private var prizeChecker = PrizeChecker()
    private var prizeRecord = PrizeDrawRecord(period: .init(from: 11, at: 2024), specialNumber: "12345678", grandNumber: "87654321", firstNumbers: ["11111222", "22222222"])

    @Test(
        "Find winning Invoice",
        arguments: zip(
            ["12345678", "87654321", "11111222", "00011222", "00000222", "11111111"],
            [InvoicePrizeType.special, .grand, .first, .fourth, .sixth, nil]
        )
    )
    func findWinningInvoices(numberStr: String, prize: InvoicePrizeType?) {
        let invoice = Invoice(shopName: "", numberPrefix: "AA", numberSuffix: numberStr, amount: 0, year: 2024, month: 11, day: 2024)

        let result = prizeChecker.findWinningInvoices(invoices: [invoice], prizeRecord: prizeRecord)

        #expect(result.first?.prize == prize)
    }
}
