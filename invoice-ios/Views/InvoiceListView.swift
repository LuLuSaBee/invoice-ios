//
//  InvoiceListView.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/16.
//

import Foundation
import SwiftUI
import SwiftData

struct InvoiceListView: View {
    @ObservedObject var viewModel: InvoiceListViewModel
    var groupingOption: InvoiceGroupingOption

    @State private var selectedInvoice: Invoice?
    @State private var sectionDatas: [SectionData] = []
    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter
    }()

    private struct SectionData {
        var title: String
        var amount: Int
        var invoices: [Invoice]
    }

    init(viewModel: InvoiceListViewModel, groupingOption: InvoiceGroupingOption) {
        self.viewModel = viewModel
        self.groupingOption = groupingOption
    }

    @ViewBuilder func sectionHeader(title: String, amount: Int) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(title)
                Spacer()
                Text("$\(amount.formatted(.number))")
            }
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color.generalBackground)

            Rectangle()
                .frame(height: 1)
                .foregroundColor(.gray)
                .opacity(0.3)
        }
    }

    @ViewBuilder func invoiceCell(_ invoice: Invoice) -> some View {
        HStack {
            if groupingOption == .month {
                VStack(alignment: .center) {
                    Text("\(invoice.day)")
                    Text(formatDate(invoice.date, formatter: "EEE"))
                        .font(.footnote)
                }
                .foregroundStyle(.primary.opacity(0.8))
                .padding(.trailing, 16)
            }

            VStack(alignment: .leading) {
                Group {
                    if invoice.shopName.isEmpty {
                        Text("無商家名稱")
                    } else {
                        Text(invoice.shopName)
                    }
                }
                .lineLimit(1)
                .font(.title3)

                HStack(spacing: 4) {
                    Text(invoice.type == .scan ? "掃描" : "手動")
                        .font(.caption)
                        .foregroundStyle(.primary.opacity(0.8))
                        .padding(.horizontal, 2)
                        .contentShape(Rectangle())
                        .background(Color.primary.opacity(0.1), in: RoundedRectangle(cornerRadius: 4))
                    Text(invoice.numberString)
                        .foregroundStyle(.primary.opacity(0.5))
                        .font(.footnote)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            Text("$\(invoice.amount.formatted(.number))")
                .frame(minWidth: 50, alignment: .trailing)
                .foregroundStyle(.primary.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .contentShape(Rectangle())
        .onTapGesture {
            selectedInvoice = invoice
        }
    }

    var body: some View {
        ScrollView {
            VStack {
                HStack {
                    Image(systemName: "calendar.badge.clock")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 24, height: 24)
                    Text("開獎倒數")
                        .font(.title3.bold())
                        .padding(.bottom, 4)
                }
                .foregroundStyle(Color.accentColor)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(Color.generalBackground, in: .rect(cornerRadius: 16))
            .padding(.top, 8)

            ForEach(self.sectionDatas, id: \.title) { section in
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section(header: sectionHeader(title: section.title, amount: section.amount)) {
                        ForEach(section.invoices, content: invoiceCell)
                    }
                }
                .padding(.bottom, 8)
                .background(Color.generalBackground, in: .rect(cornerRadius: 16))
            }

            Spacer(minLength: 96)
        }
        .padding(.horizontal, 16)
        .scrollIndicators(.hidden)
        .onChange(of: viewModel.invoices) { updateData() }
        .onChange(of: groupingOption) { updateData() }
        .onAppear(perform: updateData)
        .navigationDestination(item: $selectedInvoice) { invoice in
            InvoiceFormView(mode: .edit(invoice), service: InvoiceManager.shared)
        }
    }

    private func formatDate(_ date: Date, formatter: String) -> String {
        dateFormatter.dateFormat = formatter
        return dateFormatter.string(from: date)
    }

    private func updateData() {
        let sortedInvoices = viewModel.invoices.sorted(by: { $0.date > $1.date })
        var grouped: [String: [Invoice]]
        switch groupingOption {
        case .month:
            grouped = Dictionary(grouping: sortedInvoices) { invoice in
                formatDate(invoice.date, formatter: "MMMM")
            }
        case .day:
            grouped = Dictionary(grouping: sortedInvoices) { invoice in
                "\(String(format: "%02d", invoice.month))/\(String(format: "%02d", invoice.day)) \(formatDate(invoice.date, formatter: "EEE"))"
            }
        }

        sectionDatas = grouped.map { (key, invoices) in
            let totalAmount = invoices.reduce(0) { $0 + $1.amount }
            return SectionData(title: key, amount: totalAmount, invoices: invoices)
        }
        .sorted { $0.title > $1.title }
    }
}
