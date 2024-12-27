//
//  InvoiceListView.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/16.
//

import Foundation
import SwiftUI
import SwiftData

struct InvoiceListView<ViewModel: InvoiceListViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel
    @State private var selectedInvoice: Invoice?

    @State private var showPrizeInputs: Bool = false

    private var dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        return formatter
    }()

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    @ViewBuilder func timeToDraw(left day: Int) -> some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "calendar.badge.clock")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .bold()
                    .frame(width: 24, height: 24)
                Text("開獎倒數")
                    .font(.callout.bold())
                    .padding(.bottom, 4)
            }
            .foregroundStyle(Color.accentColor)
            HStack(alignment: .bottom, spacing: 0) {
                Text("\(day)天")
                    .font(.title3.bold())
                Text("／共\(viewModel.totalInvoiceCount)張")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.generalBackground, in: .rect(cornerRadius: 8))
    }

    @ViewBuilder func showWinningInvoices(_ winnings: [WinningInvoice]) -> some View {
        VStack {
            Text("手動對獎完成")
                .font(.footnote)
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.secondary.opacity(0.8), in: .rect(topLeadingRadius: 8, topTrailingRadius: 8))
            HStack {
                VStack(alignment: .leading) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .bold()
                            .frame(width: 20, height: 20)
                        Text("中獎金額")
                            .font(.callout.bold())
                    }
                    .foregroundStyle(Color.accentColor)
                    HStack(alignment: .bottom, spacing: 0) {
                        let totalPrize = winnings.reduce(0) { $0 + $1.prizeType.prize }
                        Text("$\(totalPrize)")
                            .font(.title3.bold())
                        Text("／中\(winnings.count)張")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text("共有\(viewModel.totalInvoiceCount)張發票")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)

            if !winnings.isEmpty {
                Rectangle()
                    .frame(height: 1)
                    .foregroundColor(.gray)
                    .opacity(0.3)
                ForEach(winnings, id: \.invoice.id) { winning in
                    invoiceCell(winning.invoice, withPrize: winning.prizeType)
                }
            }
        }
        .padding(.bottom, 8)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.generalBackground, in: .rect(cornerRadius: 8))
    }

    @ViewBuilder func drawThePrize() -> some View {
        HStack {
            Image(systemName: "dollarsign.circle.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .bold()
                .frame(width: 24, height: 24)
            Text("立即對獎")
                .font(.title2.bold())
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 21.5)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundStyle(.white)
        .background(Color.accentColor, in: .rect(cornerRadius: 8))
        .contentShape(Rectangle())
        .onTapGesture { showPrizeInputs = true }
        .alert("請輸入中獎號碼", isPresented: $showPrizeInputs) {
            PrizeDrawInputs(submit: viewModel.drawPrizeNumber)
                .id(showPrizeInputs)
        }
    }

    @ViewBuilder func prizeDrawView() -> some View {
        if viewModel.dayToDraw > 0 {
            timeToDraw(left: viewModel.dayToDraw)
        } else if let winningInvoices = viewModel.winningInvoices {
            showWinningInvoices(winningInvoices)
        } else {
            drawThePrize()
        }
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

    @ViewBuilder func invoiceCell(_ invoice: Invoice, withPrize prizeType: InvoicePrizeType? = nil) -> some View {
        HStack {
            if viewModel.groupOption == .month {
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
                    if let type = prizeType {
                        Text(type.name)
                            .font(.caption)
                            .foregroundStyle(.white)
                            .padding(.horizontal, 2)
                            .contentShape(Rectangle())
                            .background(Color(.systemYellow), in: RoundedRectangle(cornerRadius: 4))
                    }
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
        VStack(spacing: 0) {
            Text(viewModel.period.description)
                .font(.footnote)
                .padding(.vertical, 8)
                .frame(maxWidth: .infinity)
                .foregroundStyle(.primary.opacity(0.8))
                .background(Color.generalBackground.opacity(0.8))

            if viewModel.displayData.isEmpty {
                VStack {
                    prizeDrawView()
                        .padding(.top, 8)
                    Spacer()
                    Image(systemName: "truck.box.badge.clock")
                        .symbolRenderingMode(.hierarchical)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 128, height: 128)
                        .foregroundStyle(.secondary)
                    Text("尚無發票紀錄")
                        .foregroundStyle(.secondary)
                    Spacer()
                }
                .padding(.horizontal, 16)
            } else {
                ScrollView {
                    prizeDrawView()
                        .padding(.top, 8)

                    ForEach(viewModel.displayData, id: \.title) { section in
                        LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                            Section(header: sectionHeader(title: section.title, amount: section.totalAmount)) {
                                ForEach(section.invoices) { invoiceCell($0) }
                            }
                        }
                        .padding(.bottom, 8)
                        .background(Color.generalBackground, in: .rect(cornerRadius: 8))
                    }

                    Spacer(minLength: 96)
                }
                .padding(.horizontal, 16)
                .scrollIndicators(.hidden)
                .navigationDestination(item: $selectedInvoice) { invoice in
                    InvoiceFormPageView(viewModel: viewModel.makeEditInvoiceFormPageViewModel(invoice: invoice))
                }
            }
        }
    }

    private func formatDate(_ date: Date, formatter: String) -> String {
        dateFormatter.dateFormat = formatter
        return dateFormatter.string(from: date)
    }
}

private struct PrizeDrawInputs: View {
    @State private var specialPrizeValue: String = ""
    @State private var grandPrizeValue: String = ""
    @State private var firstPrizeValue1: String = ""
    @State private var firstPrizeValue2: String = ""
    @State private var firstPrizeValue3: String = ""

    var submit: (String, String, [String]) -> Void

    var body: some View {
        VStack {
            TextField("特大獎", text: $specialPrizeValue)
                .keyboardType(.numberPad)
            TextField("特獎", text: $grandPrizeValue)
                .keyboardType(.numberPad)
            TextField("頭獎 1", text: $firstPrizeValue1)
                .keyboardType(.numberPad)
            TextField("頭獎 2", text: $firstPrizeValue2)
                .keyboardType(.numberPad)
            TextField("頭獎 3", text: $firstPrizeValue3)
                .keyboardType(.numberPad)
            Button("兌獎") {
                submit(specialPrizeValue, grandPrizeValue, [firstPrizeValue1, firstPrizeValue2, firstPrizeValue3])
            }
            .disabled(specialPrizeValue.isEmpty && grandPrizeValue.isEmpty && firstPrizeValue1.isEmpty && firstPrizeValue2.isEmpty && firstPrizeValue3.isEmpty)
            Button("Cancel", role: .cancel) { }
        }
    }
}
