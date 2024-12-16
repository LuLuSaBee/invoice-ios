//
//  InvoiceListView.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/16.
//

import SwiftUI
import SwiftData

struct InvoiceListView: View {
    @Query private var invoices: [Invoice]

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

            ForEach(invoices, id: \.numberString) { invoice in
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section(header: StickyHeaderView(title: invoice.numberString)) {
                        Text("\(invoice.shopName)")
                            .font(.title3)
                            .padding(.bottom, 4)
                        Text("\(invoice.amount)")
                            .font(.title3)
                    }
                }
                .background(Color.generalBackground, in: .rect(cornerRadius: 16))
            }

            Spacer(minLength: 96)
        }
        .padding(.horizontal, 16)
        .scrollIndicators(.hidden)
    }
}

private struct StickyHeaderView: View {
    let title: String

    var body: some View {
        Text(title)
            .font(.headline)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .zIndex(1)
            .background(Color.generalBackground)
    }
}
