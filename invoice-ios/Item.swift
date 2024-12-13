//
//  Item.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/13.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
