//
//  InvoiceFormView.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/18.
//

import Foundation
import SwiftUI

struct InvoiceFormView: View {
    @ObservedObject var viewModel: InvoiceFormViewModel

    @FocusState private var focusedField: FocusableField?

    private enum FocusableField: Hashable {
        case shopName, numberPrefix, numberSuffix, amount
    }

    var body: some View {
        VStack {
            TextField("商家名稱", text: $viewModel.shopNameField.value)
                .modifier(InvoiceFormTextFieldModifier(
                    focusedField: $focusedField,
                    equals: .shopName,
                    errorMessage: viewModel.shopNameField.errorMessage
                ))
            HStack(alignment: .top) {
                TextField("發票號碼", text: $viewModel.numberPrefixField.value)
                    .keyboardType(.alphabet)
                    .textCase(.uppercase)
                    .modifier(InvoiceFormTextFieldModifier(
                        focusedField: $focusedField,
                        equals: .numberPrefix,
                        errorMessage: viewModel.numberPrefixField.errorMessage
                    ))
                    .frame(width: 120)
                Text("-").padding(.vertical, 8)
                TextField("發票號碼", text: $viewModel.numberSuffixField.value)
                    .keyboardType(.numberPad)
                    .modifier(InvoiceFormTextFieldModifier(
                        focusedField: $focusedField,
                        equals: .numberSuffix,
                        errorMessage: viewModel.numberSuffixField.errorMessage
                    ))
            }
        }
        .padding(16)
        .background(Color.generalBackground)
        .onAppear { focusedField = .shopName }
        .onReceive(viewModel.shouldMoveFocusSubject.eraseToAnyPublisher(), perform: moveFocused)
    }

    private func moveFocused() {
        switch self.focusedField {
        case .shopName:
            focusedField = .numberPrefix
        case .numberPrefix:
            focusedField = .numberSuffix
        case .numberSuffix:
            focusedField = .amount
        case .amount:
            focusedField = nil
        case .none:
            break
        }
    }
}

private struct InvoiceFormTextFieldModifier<T: Hashable>: ViewModifier {
    var focusedField: FocusState<T?>.Binding
    var equals: T
    var errorMessage: String?

    func body(content: Content) -> some View {
        VStack {
            content
                .focused(focusedField, equals: equals)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 8).stroke(borderColor, lineWidth: 2))
            if let message = errorMessage, focusedField.wrappedValue != equals {
                HStack {
                    Image(systemName: "info.circle")
                    Text(message)
                }
                .font(.footnote)
                .foregroundStyle(Color(.systemRed))
                .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
    }

    private var borderColor: Color {
         if focusedField.wrappedValue == equals {
            return .accentColor
         } else if errorMessage != nil {
             return Color(.systemRed)
         } else {
            return Color(.systemGray).opacity(0.5)
        }
    }
}

#Preview {
    InvoiceFormView(viewModel: .init(mode: .add, service: InvoiceManager.shared))
}
