//
//  MyInvoiceView.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/16.
//

import SwiftUI
import Combine

struct MyInvoiceView<ViewModel: MyInvoiceViewModelProtocol>: View {
    @State private var showScanPage: Bool = false
    @State private var showAddForm: Bool = false

    @ObservedObject var viewModel: ViewModel

    var body: some View {
        ZStack {
            PageView(
                data: viewModel.displayListViewModels,
                currentID: $viewModel.currentList,
                pageBuilder: InvoiceListView.init(viewModel:),
                loadMore: viewModel.loadMore
            )

            AddInvoiceFloatButton(showScanPage: $showScanPage, showAddForm: $showAddForm)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("我的發票")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(isPresented: $showAddForm) {
            InvoiceFormView(viewModel: viewModel.makeAddInvoiceFormViewModel())
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(action: {
                    withAnimation {
                        viewModel.tapGroupingOption()
                    }
                }) {
                    switch viewModel.groupingOption {
                    case .month:
                        Image(systemName: "rectangle.3.group")
                    case .day:
                        Image(systemName: "rectangle.3.group.fill")
                    }
                }
                .foregroundStyle(Color.primary)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Image(systemName: "magnifyingglass")
            }
        }
    }
}

private struct AddInvoiceFloatButton: View {
    @Binding var showScanPage: Bool
    @Binding var showAddForm: Bool

    @State private var showAddOption = false


    var body: some View {
        VStack(alignment: .trailing, spacing: 16) {
            AddOptionButton(title: "掃描輸入", image: Image(systemName: "qrcode.viewfinder"), action: onClickScanAdd)
                .offset(y: showAddOption ? 0 : 160)
                .opacity(showAddOption ? 1 : 0)
            AddOptionButton(title: "手動輸入", image: Image(systemName: "keyboard"), action: onClickManualAdd)
                .offset(y: showAddOption ? 0 : 80)
                .opacity(showAddOption ? 1 : 0)

            Button(action: toggleShowAddOption) {
                Image(systemName: "plus")
                    .resizable()
                    .frame(width: 16, height: 16)
                    .bold()
                    .rotationEffect(.init(degrees: showAddOption ? 45 : 0))
            }
            .padding(24)
            .contentShape(Rectangle())
            .background(showAddOption ? Color.white : Color.accentColor)
            .foregroundColor(showAddOption ? .accentColor : .white)
            .clipShape(Circle())
            .overlay { Circle().stroke(showAddOption ? .gray : .clear, lineWidth: 1) }
            .contentShape(Circle())
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.bottom, 16)
        .padding(.trailing, 16)
        .background {
            if showAddOption {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.generalBackground.opacity(0.5), Color.generalBackground]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .onTapGesture(perform: toggleShowAddOption)
            }
        }
    }

    private func toggleShowAddOption() {
        withAnimation(.default.speed(1.5)) {
            self.showAddOption.toggle()
        }
    }

    private func onClickScanAdd() {
        showScanPage = true
        toggleShowAddOption()
    }

    private func onClickManualAdd() {
        showAddForm = true
        toggleShowAddOption()
    }
}

private struct AddOptionButton: View {
    var title: LocalizedStringKey
    var image: Image
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(title)
                image
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
                    .padding(12)
                    .foregroundStyle(Color.white)
                    .background(Color.accentColor)
                    .clipShape(Circle())
            }
            .padding(.trailing, 8)
        }
    }
}
