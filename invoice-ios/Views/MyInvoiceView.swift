//
//  MyInvoiceView.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/16.
//

import SwiftUI

struct MyInvoiceView: View {
    var body: some View {
        ZStack {
            InvoiceListView()

            AddInvoiceFloatButton()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
        .navigationTitle("我的發票")
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct AddInvoiceFloatButton: View {
    @State private var showAddOption = false

    var body: some View {
        VStack(spacing: 16) {
            Group {
                Button(action: {}) {
                    Text("掃描")
                }
                Button(action: {}) {
                    Text("手動")
                }
            }
            .offset(y: showAddOption ? 0 : 40)
            .opacity(showAddOption ? 1 : 0)

            Button(action: {
                withAnimation {
                    self.showAddOption.toggle()
                }
            }) {
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
            .padding(.bottom, 16)
            .padding(.trailing, 16)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .background {
            if showAddOption {
                Rectangle()
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.clear, Color("general_background")]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .onTapGesture {
                        withAnimation {
                            self.showAddOption.toggle()
                        }
                    }
            }
        }
    }
}
