//
//  ContentView.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/13.
//

import UIKit
import SwiftUI
import SwiftData

struct ContentView: View {
    private var invoiceProvider: InvoiceProvider
    private var prizeRecordProvider: PrizeDrawRecordProvider

    init(modelConfig: ModelConfiguration) {
        let modelContainer = try! ModelContainer(for: Invoice.self, InvoiceDetail.self, PrizeDrawRecord.self, configurations: modelConfig)
        modelContainer.mainContext.autosaveEnabled = true

        let invoiceRepository = SwiftDataInvoiceRepository(modelContainer: modelContainer)
        let prizeRecordRepository = SwiftDataPrizeDrawRecordRepository(modelContainer: modelContainer)

        self.invoiceProvider = InvoiceDataProvider(repository: invoiceRepository)
        self.prizeRecordProvider = PrizeDrawRecordDataProvider(repository: prizeRecordRepository)
    }

    var body: some View {
        TabView {
            Tab("我的發票", systemImage: "book.pages.fill") {
                NavigationStack {
                    MyInvoiceView(viewModel: MyInvoiceViewModel(provider: invoiceProvider))
                }
            }
            Tab("掃描發票", systemImage: "qrcode.viewfinder") { Text("掃描發票") }
            Tab("統計數據", systemImage: "chart.bar.xaxis") { Text("統計數據") }
        }
    }
}

#Preview {
    ContentView(modelConfig: .init())
}
