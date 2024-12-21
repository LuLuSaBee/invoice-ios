//
//  invoice_iosApp.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/13.
//

import SwiftUI
import SwiftData

@main
struct invoice_iosApp: App {
    var body: some Scene {
        WindowGroup {
            if ProcessInfo.processInfo.environment["XCTestBundlePath"] != nil {
                Text("Running Test")
            } else {
                ContentView()
            }
        }
    }
}
