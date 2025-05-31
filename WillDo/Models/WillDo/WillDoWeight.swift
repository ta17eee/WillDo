//
//  WillDoWeight.swift
//  WillDo
//
//  Created by 加瀬一輝 on R 7/05/31.
//
import Foundation
import SwiftUI

enum Weight: Int, CaseIterable, Codable, Comparable {
    case veryLow = 1
    case low = 2
    case medium = 3
    case high = 4
    case veryHigh = 5

    // 比較可能にする
    static func < (lhs: Weight, rhs: Weight) -> Bool {
        lhs.rawValue < rhs.rawValue
    }

    // 表示名
    var label: String {
        switch self {
        case .veryLow: return "とても軽い"
        case .low: return "軽い"
        case .medium: return "普通"
        case .high: return "重い"
        case .veryHigh: return "とても重い"
        }
    }

    // 色などUI表現に使いたい場合
    var color: Color {
        switch self {
        case .veryLow: return .green
        case .low: return .mint
        case .medium: return .yellow
        case .high: return .orange
        case .veryHigh: return .red
        }
    }
}
