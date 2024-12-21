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
    private var invoiceRepository: InvoiceRepository

    init() {
        do {
            let container = try ModelContainer(for: Invoice.self, InvoiceDetail.self)
            let context = container.mainContext
            let existingInvoices = try? context.fetch(FetchDescriptor<Invoice>())
            if existingInvoices?.isEmpty ?? true {
                Invoice.sampleData.forEach { context.insert($0) }
                do {
                    try context.save()
                } catch {
                    fatalError("Could not save sample data: \(error)")
                }
            }
            self.invoiceRepository = StandardInvoiceRepository(modelContainer: container)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
    }

    var body: some View {
        TabView {
            Tab("我的發票", systemImage: "book.pages.fill") {
                NavigationStack { MyInvoiceView() }
            }
            Tab("掃描發票", systemImage: "qrcode.viewfinder") { Text("掃描發票") }
            Tab("統計數據", systemImage: "chart.bar.xaxis") { Text("統計數據") }
        }
    }
}

#Preview {
    let preview = Preview()
    preview.addExamples(Array(Invoice.sampleData[0...20]))

    return ContentView().modelContainer(preview.modelContainer)
}
