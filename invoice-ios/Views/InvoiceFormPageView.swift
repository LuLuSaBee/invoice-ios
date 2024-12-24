//
//  InvoiceFormPageView.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/18.
//

import Foundation
import SwiftUI
import SwiftData

struct InvoiceFormPageView<ViewModel: InvoiceFormPageViewModelProtocol>: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var keyboardMonitor = KeyboardMonitor()
    @ObservedObject private var viewModel: ViewModel

    @State private var showDeleteDialog = false

    private var buttonColor: Color {
        viewModel.isValid ? .accentColor : Color(.systemGray)
    }

    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }

    var body: some View {
        VStack {
            FormView(viewModel: viewModel)
        }
        .background(Color.generalBackground)
        .navigationTitle(viewModel.pageTitle)
        .toolbarRole(.editor)
        .toolbarVisibility(.hidden, for: .tabBar)
        .toolbar {
            if viewModel.showDeleteOption {
                ToolbarItem(placement: .navigation) {
                    Button("刪除") {
                        showDeleteDialog = true
                    }
                }
            }
        }
        .alert("確認刪除?", isPresented: $showDeleteDialog) {
            Button("確認") {
                viewModel.delete { dismiss() }
            }
            Button("取消", role: .cancel) {}
        }
        .alert("發票號碼重複", isPresented: $viewModel.showDuplicateError) {
            Button("重新填寫") {}
        }
        .safeAreaInset(edge: .bottom, spacing: 0) {
            if !keyboardMonitor.isKeyboardVisible {
                VStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.gray)
                        .opacity(0.3)

                    Text("儲存發票")
                        .font(.body)
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.white)
                        .padding(.vertical, 8)
                        .background(buttonColor, in: RoundedRectangle(cornerRadius: 8))
                        .contentShape(Rectangle())
                        .onTapGesture {
                            viewModel.save { dismiss() }
                        }
                        .padding(.horizontal, 16)
                        .disabled(!viewModel.isValid)

                    if viewModel.showAddAnotherOption {
                        Text("儲存並新增下一筆")
                            .font(.body)
                            .frame(maxWidth: .infinity)
                            .foregroundColor(buttonColor)
                            .padding(.vertical, 8)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                viewModel.save { dismiss() }
                                // TODO: Reset form data
                            }
                            .padding(.horizontal, 16)
                            .disabled(!viewModel.isValid)
                    }
                }
                .frame(maxWidth: .infinity)
                .ignoresSafeArea(.keyboard, edges: .bottom)
                .background(Color.generalBackground)
            }
        }
    }
}

private struct FormView<ViewModel: InvoiceFormPageViewModelProtocol>: View {
    @ObservedObject var viewModel: ViewModel

    @FocusState private var focusedField: FocusableField?

    private enum FocusableField: Hashable {
        case shopName, numberPrefix, numberSuffix, amount, detail(id: PersistentIdentifier)
    }

    var body: some View {
        ScrollView {
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
                        .textInputAutocapitalization(.never)
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

                HStack {
                    Text("消費明細")
                    Spacer()
                    Button("新增明細") {
                        let detail = viewModel.addDetail()
                        focusedField = .detail(id: detail.id)
                    }
                    .buttonStyle(.bordered)
                }

                ForEach(Array(viewModel.details.enumerated()), id: \.element.id) { (index, detail) in
                    HStack {
                        TextField("明細", text: .init(get: {
                            detail.name
                        }, set: {
                            detail.name = $0
                        }))
                        .submitLabel(.continue)
                        .onSubmit {
                            if index == viewModel.details.count - 1 {
                                focusedField = nil
                            } else {
                                focusedField = .detail(id: viewModel.details[index + 1].id)
                            }
                        }
                        .modifier(InvoiceFormTextFieldModifier(
                            focusedField: $focusedField,
                            equals: .detail(id: detail.id),
                            errorMessage: viewModel.amountField.errorMessage
                        ))

                        Button(action: {
                            viewModel.deleteDetail(at: detail)
                        }, label: {
                            Image(systemName: "trash")
                                .foregroundColor(.red)
                        })
                    }
                    .id(detail.id)
                }
            }
            .padding(16)
        }
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
        case .amount, .detail:
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