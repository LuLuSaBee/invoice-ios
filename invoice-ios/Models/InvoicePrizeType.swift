//
//  InvoicePrizeType.swift
//  invoice-ios
//
//  Created by 劉聖龍 on 2024/12/23.
//

import Foundation

enum InvoicePrizeType {
    case special
    case grand
    case first
    case second
    case third
    case fourth
    case fifth
    case sixth

    var name: String {
        switch self {
        case .special: return "特別獎"
        case .grand: return "特獎"
        case .first: return "頭獎"
        case .second: return "二獎"
        case .third: return "三獎"
        case .fourth: return "四獎"
        case .fifth: return "五獎"
        case .sixth: return "六獎"
        }
    }

    var prize: Int {
        switch self {
        case .special: return 10000000
        case .grand: return 2000000
        case .first: return 200000
        case .second: return 40000
        case .third: return 10000
        case .fourth: return 4000
        case .fifth: return 1000
        case .sixth: return 200
        }
    }
}
