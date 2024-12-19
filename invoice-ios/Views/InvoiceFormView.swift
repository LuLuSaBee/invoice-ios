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
        VStack(spacing: 16) {
            DatePicker("發票日期", selection: $viewModel.dateField.value, displayedComponents: .date)
            TextField("商家名稱", text: $viewModel.shopNameField.value)
                .submitLabel(.next)
                .onSubmit(moveFocused)
                .modifier(InvoiceFormTextFieldModifier(
                    focusedField: $focusedField,
                    equals: .shopName,
                    errorMessage: viewModel.shopNameField.errorMessage
                ))
            HStack(alignment: .top) {
                TextField("發票號碼", text: $viewModel.numberPrefixField.value)
                    .textInputAutocapitalization(.characters)
                    .keyboardType(.alphabet)
                    .textCase(.uppercase)
                    .submitLabel(.next)
                    .onSubmit(moveFocused)
                    .modifier(InvoiceFormTextFieldModifier(
                        focusedField: $focusedField,
                        equals: .numberPrefix,
                        errorMessage: viewModel.numberPrefixField.errorMessage
                    ))
                    .frame(width: 120)
                Text("-").padding(.vertical, 8)
                TextField("發票號碼", text: $viewModel.numberSuffixField.value)
                    .keyboardType(.numberPad)
                    .submitLabel(.next)
                    .modifier(InvoiceFormTextFieldModifier(
                        focusedField: $focusedField,
                        equals: .numberSuffix,
                        errorMessage: viewModel.numberSuffixField.errorMessage
                    ))
            }
            TextField("消費金額", text: .init(get: {
                "$" + viewModel.amountField.value.formatted(.number)
            }, set: { value in
                if let number = Int(value.filter { $0.isNumber }) {
                    viewModel.amountField.value = number
                } else {
                    viewModel.amountField.value = 0
                }
            }))
            .keyboardType(.numberPad)
            .submitLabel(.next)
            .modifier(InvoiceFormTextFieldModifier(
                focusedField: $focusedField,
                equals: .amount,
                errorMessage: viewModel.amountField.errorMessage
            ))
        }
        .padding(16)
        .onAppear { focusedField = .shopName }
        .onReceive(viewModel.shouldMoveFocusSubject.eraseToAnyPublisher(), perform: moveFocused)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("完成") { focusedField = nil }
                Button("下一步") { moveFocused() }
            }
        }
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
                .contentShape(Rectangle())
                .onTapGesture { focusedField.wrappedValue = equals }
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
