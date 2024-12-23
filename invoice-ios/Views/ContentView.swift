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

    init(invoiceProvider: InvoiceProvider) {
        self.invoiceProvider = invoiceProvider
    }

    var body: some View {
        TabView {
            Tab("我的發票", systemImage: "book.pages.fill") {
                NavigationStack { MyInvoiceView(viewModel: MyInvoiceViewModel(provider: invoiceProvider)) }
            }
            Tab("掃描發票", systemImage: "qrcode.viewfinder") { Text("掃描發票") }
            Tab("統計數據", systemImage: "chart.bar.xaxis") { Text("統計數據") }
        }
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let invoiceRepository = SwiftDataInvoiceRepository(config: config)
    let invoiceProvider = InvoiceDataProvider(repository: invoiceRepository)

    Task {
        for invoice in Invoice.sampleData[0...20] {
            await invoiceRepository.insertInvoice(invoice)
        }
    }

    return ContentView(invoiceProvider: invoiceProvider)
}
