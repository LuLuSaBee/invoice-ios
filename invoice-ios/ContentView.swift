//
//  ContentView.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/13.
//

import UIKit
import SwiftUI
import SwiftData

struct ContentView: View {
    init() {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(named: "general_background")
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(named: "general_background")
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }

    var body: some View {
        TabView {
            Tab("我的發票", systemImage: "book.pages.fill") {
                NavigationStack { MyInvoiceView() }
            }
            Tab("掃描發票", systemImage: "qrcode.viewfinder") { Text("掃描發票") }
            Tab("統計數據", systemImage: "chart.bar.xaxis") { Text("統計數據") }
        }
    }
}

#Preview {
    let preview = Preview()
    preview.addExamples(Array(Invoice.sampleData[0...20]))

    return ContentView().modelContainer(preview.modelContainer)
}
