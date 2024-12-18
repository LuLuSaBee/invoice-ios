//
//  AddInvoiceFormView.swift
//  invoice-ios
//
//  Created by 劉聖龍 on 2024/12/18.
//

import SwiftUI

struct AddInvoiceFormView: View {
    let service: InvoiceServiceable

    var body: some View {
        VStack {
            InvoiceFormView(viewModel: .init(mode: .add, service: service))

            Spacer()
        }
        .background(Color.generalBackground)
        .navigationTitle("新增發票")
        .toolbarRole(.editor)
        .toolbarVisibility(.hidden, for: .tabBar)
    }
}
