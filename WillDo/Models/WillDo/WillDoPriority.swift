//
//  WillDoPriority.swift
//  WillDo
//
//  Created by 加瀬一輝 on R 7/05/31.
//
import SwiftUI
import Foundation

enum Priority: String, CaseIterable, Codable, Comparable {
    case low
    case medium
    case high

    // 比較可能（low < medium < high）
    static func < (lhs: Priority, rhs: Priority) -> Bool {
        lhs.rawValueIndex < rhs.rawValueIndex
    }

    // 並び順用のインデックス
    private var rawValueIndex: Int {
        switch self {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        }
    }

    // 表示名
    var label: String {
        switch self {
        case .low: return "低"
        case .medium: return "中"
        case .high: return "高"
        }
    }

    // 表示色（例：UIでラベル背景に使う）
    var color: Color {
        switch self {
        case .low: return .gray
        case .medium: return .blue
        case .high: return .red
        }
    }
}

