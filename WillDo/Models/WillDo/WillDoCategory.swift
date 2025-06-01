//
//  WillDoCategory.swift
//  WillDo
//
//  Created by 加瀬一輝 on R 7/06/01.
//
import SwiftUI

enum Category: String, CaseIterable, Identifiable, Codable{
    case work        // 仕事・勉強
    case home        // 生活・家事
    case health      // 健康・運動
    case social      // 人間関係・コミュニケーション
    case hobby       // 趣味・自己啓発
    case future      // 将来の計画・夢
    case other       // その他

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .work: return "仕事・勉強"
        case .home: return "生活・家事"
        case .health: return "健康・運動"
        case .social: return "人間関係"
        case .hobby: return "趣味"
        case .future: return "将来の計画"
        case .other: return "その他"
        }
    }

    var iconName: String {
        switch self {
        case .work: return "briefcase"
        case .home: return "house"
        case .health: return "heart"
        case .social: return "person.2"
        case .hobby: return "paintbrush"
        case .future: return "sparkles"
        case .other: return "questionmark.circle"
        }
    }
}

