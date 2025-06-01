//
//  WillDo.swift
//  WillDo
//
//  Created by 高野　泰生 on 2025/05/31.
//
import SwiftUI
import SwiftData
import Foundation

@Model
class WillDo {
    var id: String
    var createAt: Date
    var updateAt: Date
    var completeAt: Date?
    var content: String
    var childWillDos: [WillDo]
    var motivation: Int
    var category: Category
    var goalAt: Date?
    var weight: Weight?
    var priority: Priority?
    var status: Status
    var memoList: [Memo]
    var impression: String?
    var parentId: String?

    init(
        id: String = UUID().uuidString,
        createAt: Date = Date(),
        updateAt: Date = Date(),
        completeAt: Date? = nil,
        content: String,
        childWillDos: [WillDo] = [],
        motivation: Int,
        category: Category,
        goalAt: Date? = nil,
        weight: Weight? = nil,
        priority: Priority? = nil,
        status: Status = .planned,
        memoList: [Memo] = [],
        impression: String? = nil,
        parentId: String? = nil
    ) {
        self.id = id
        self.createAt = createAt
        self.updateAt = updateAt
        self.completeAt = completeAt
        self.content = content
        self.childWillDos = childWillDos
        self.motivation = motivation
        self.category = category
        self.goalAt = goalAt
        self.weight = weight
        self.priority = priority
        self.status = status
        self.memoList = memoList
        self.impression = impression
        self.parentId = parentId
    }
    
    static let sampleWillDos: [WillDo] = [
        WillDo(
            content: "英単語を毎日10個覚える",
            childWillDos: [
                WillDo(
                    content: "単語帳のページ1を覚える",
                    childWillDos: [
                        WillDo(
                            content: "単語帳のページ1を覚える",
                            motivation: 70,
                            category: .work,
                            status: .completed,
                            parentId: "1" // 適切にIDをセットしてください
                        ),
                        WillDo(
                            content: "単語帳のページ2を覚える",
                            motivation: 65,
                            category: .work,
                            status: .completed,
                            parentId: "1"
                        ),
                        WillDo(
                            content: "単語帳の復習をする",
                            motivation: 60,
                            category: .work,
                            status: .completed,
                            parentId: "1"
                        )
                    ],
                    motivation: 70,
                    category: .work,
                    status: .start,
                    parentId: "1" // 適切にIDをセットしてください
                ),
                WillDo(
                    content: "単語帳のページ2を覚える",
                    childWillDos: [
                        WillDo(
                            content: "単語帳のページ1を覚える",
                            motivation: 70,
                            category: .work,
                            status: .start,
                            parentId: "1" // 適切にIDをセットしてください
                        ),
                        WillDo(
                            content: "単語帳のページ2を覚える",
                            motivation: 65,
                            category: .work,
                            status: .middle,
                            parentId: "1"
                        ),
                        WillDo(
                            content: "単語帳の復習をする",
                            motivation: 60,
                            category: .work,
                            status: .planned,
                            parentId: "1"
                        )
                    ],
                    motivation: 65,
                    category: .work,
                    status: .planned,
                    parentId: "1"
                ),
                WillDo(
                    content: "単語帳の復習をする",
                    childWillDos: [
                        WillDo(
                            content: "単語帳のページ1を覚える",
                            motivation: 70,
                            category: .work,
                            status: .start,
                            parentId: "1" // 適切にIDをセットしてください
                        ),
                        WillDo(
                            content: "単語帳のページ2を覚える",
                            motivation: 65,
                            category: .work,
                            status: .completed,
                            parentId: "1"
                        ),
                        WillDo(
                            content: "単語帳の復習をする",
                            motivation: 60,
                            category: .work,
                            status: .planned,
                            parentId: "1"
                        )
                    ],
                    motivation: 60,
                    category: .work,
                    status: .planned,
                    parentId: "1"
                )
            ],
            motivation: 80,
            category: .work,
            goalAt: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
            weight: .medium,
            priority: .high,
            status: .start,
            memoList: [
                Memo(date: Date(), content: "DUO 3.0 で始めた")
            ]
        ),
        WillDo(
            content: "ランニングを週3回する",
            motivation: 60,
            category: .health,
            weight: .low,
            priority: .medium,
            status: .planned
        ),
        WillDo(
            content: "アプリ開発のポートフォリオを完成させる",
            motivation: 95,
            category: .future,
            goalAt: Calendar.current.date(byAdding: .month, value: 2, to: Date())!,
            weight: .veryHigh,
            priority: .high,
            status: .middle,
            memoList: [
                Memo(date: Date(), content: "画面設計完了。次はFirestore連携")
            ]
        ),
        WillDo(
            content: "読書感想文を書く",
            motivation: 40,
            category: .work,
            weight: .high,
            priority: .low,
            status: .completed,
            impression: "読み切ったけどまとめるのが大変だった"
        )
    ]
}
