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
    @Attribute(.unique)
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
    var parent: WillDo?

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
        parent: WillDo? = nil
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
        self.parent = parent
    }

}
