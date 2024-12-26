//
//  DashboardModel.swift
//  invoice-ios
//
//  Created by lewisliu on 2024/12/26.
//

import Foundation

enum DashboardDuration: CaseIterable {
    case week
    case month
    case year

    var name: String {
        switch self {
        case .week: return "7天"
        case .month: return "4週"
        case .year: return "12個月"
        }
    }
}

struct ChartData: Hashable {
    let name: String
    let amount: Int
}
