//
//  Untitled.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/25.
//

@testable import invoice_ios
import Testing
import Foundation

@Suite("Invoice Period Provider")
struct InvoicePeriodProviderTest {
    private let provider = InvoicePeriodProvider()

    private func dateFrom(year: Int, month: Int) -> Date {
        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = 3

        return Calendar.current.date(from: components)!
    }

    @Test("Get Current Period")
    func getCurrent() {
        let date = dateFrom(year: 2024, month: 12)

        let current = provider.current(at: date)

        #expect(current.year == 2024)
        #expect(current.firstMonth == 11)
        #expect(current.secondMonth == 12)
    }

    @Test("Get Next Period", arguments: zip([[2024, 10], [2024, 11]], [[2024, 11, 12], [2025, 01, 02]]))
    func getNext(testCase: [Int], expect: [Int]) {
        let date = dateFrom(year: testCase[0], month: testCase[1])
        let current = provider.current(at: date)

        let next = provider.next(from: current)

        #expect(next.year == expect[0])
        #expect(next.firstMonth == expect[1])
        #expect(next.secondMonth == expect[2])
    }

    @Test("Get Previous Period", arguments: zip([[2024, 10], [2024, 01]], [[2024, 07, 08], [2023, 11, 12]]))
    func getPrevious(testCase: [Int], expect: [Int]) {
        let date = dateFrom(year: testCase[0], month: testCase[1])
        let current = provider.current(at: date)

        let previous = provider.previous(from: current)

        #expect(previous.year == expect[0])
        #expect(previous.firstMonth == expect[1])
        #expect(previous.secondMonth == expect[2])
    }
}
