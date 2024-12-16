//
//  InvoiceListView.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/16.
//

import SwiftUI

struct InvoiceListView: View {
    var body: some View {
        ScrollView {
            ForEach(0..<2) { section in
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    Section(header: StickyHeaderView(title: "Section \(section + 1)")) {
                        ForEach(0..<20) { item in
                            Text("Item \(item)")
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
                .background(Color.generalBackground, in: .rect(cornerRadius: 16))
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
            }
        }
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
