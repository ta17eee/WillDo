//
//  WillDoStatus.swift
//  WillDo
//
//  Created by 加瀬一輝 on R 7/05/31.
//

import SwiftUI
import Foundation

enum Status: String, CaseIterable, Codable, Comparable {
    case planned       // 計画済み（0%）
    case start         // 着手（10%）
    case middle        // 中間（50%）
    case almostDone    // ほぼ完了（90%）
    case completed     // 完了（100%）
    case abandoned     // 中断（-1% 相当）

    // 並び順用インデックス（比較やソート用）
    private var index: Int {
        switch self {
        case .planned: return 0
        case .start: return 1
        case .middle: return 2
        case .almostDone: return 3
        case .completed: return 4
        case .abandoned: return 5  // 完了とは別の末尾扱い
        }
    }

    static func < (lhs: Status, rhs: Status) -> Bool {
        lhs.index < rhs.index
    }

    // 表示名
    var label: String {
        switch self {
        case .planned: return "計画中"
        case .start: return "開始"
        case .middle: return "途中"
        case .almostDone: return "ほぼ完了"
        case .completed: return "完了"
        case .abandoned: return "中断"
        }
    }

    // 進捗率（UIでプログレスバーに使うなど）
    var progress: Double {
        switch self {
        case .planned: return 0.0
        case .start: return 0.1
        case .middle: return 0.5
        case .almostDone: return 0.9
        case .completed: return 1.0
        case .abandoned: return 0.0
        }
    }

    // 表示色（UI上でのステータス表示に利用）
    var color: Color {
        switch self {
        case .planned: return .gray
        case .start: return .blue
        case .middle: return .orange
        case .almostDone: return .mint
        case .completed: return .green
        case .abandoned: return .red
        }
    }
}
