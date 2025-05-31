//
//  SwiftUIView.swift
//  WillDo
//
//  Created by 高野　泰生 on 2025/05/31.
//

import SwiftUI
import SwiftData

struct WillDoListView: View {
    @Environment(\.modelContext) private var context
    @Query private var willDos: [WillDo]
    @State private var expandedIds: Set<String> = []
    let sampleWillDos: [WillDo] = [
        WillDo(
            content: "英単語を毎日10個覚える",
            childWillDos: [
                WillDo(
                    content: "単語帳のページ1を覚える",
                    childWillDos: [
                        WillDo(
                            content: "単語帳のページ1を覚える",
                            motivation: 70,
                            category: "勉強",
                            status: .planned,
                            parentId: "1" // 適切にIDをセットしてください
                        ),
                        WillDo(
                            content: "単語帳のページ2を覚える",
                            motivation: 65,
                            category: "勉強",
                            status: .planned,
                            parentId: "1"
                        ),
                        WillDo(
                            content: "単語帳の復習をする",
                            motivation: 60,
                            category: "勉強",
                            status: .planned,
                            parentId: "1"
                        )
                    ],
                    motivation: 70,
                    category: "勉強",
                    status: .planned,
                    parentId: "1" // 適切にIDをセットしてください
                ),
                WillDo(
                    content: "単語帳のページ2を覚える",
                    motivation: 65,
                    category: "勉強",
                    status: .planned,
                    parentId: "1"
                ),
                WillDo(
                    content: "単語帳の復習をする",
                    motivation: 60,
                    category: "勉強",
                    status: .planned,
                    parentId: "1"
                )
            ],
            motivation: 80,
            category: "勉強",
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
            category: "健康",
            weight: .low,
            priority: .medium,
            status: .planned
        ),
        WillDo(
            content: "アプリ開発のポートフォリオを完成させる",
            motivation: 95,
            category: "自己成長",
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
            category: "学校",
            weight: .high,
            priority: .low,
            status: .almostDone,
            impression: "読み切ったけどまとめるのが大変だった"
        )
    ]



    var body: some View {
        List {
            ForEach(flattened(sampleWillDos.filter { $0.parentId == nil })) { item in
                OneWillDoView(
                    item: item,
                    isExpanded: expandedIds.contains(item.willDo.id),
                    toggleExpansion: toggleExpansion
                )
            }
        }
    }
    
    func toggleExpansion(id: String) {
            if expandedIds.contains(id) {
                expandedIds.remove(id)
            } else {
                expandedIds.insert(id)
            }
        }
    // ここにflattenedメソッドを定義する
    func flattened(_ willDos: [WillDo], level: Int = 0) -> [FlattenedWillDo] {
        var result: [FlattenedWillDo] = []

        for willDo in willDos {
            result.append(FlattenedWillDo(willDo: willDo, level: level))
            if expandedIds.contains(willDo.id) {
                let children = willDo.childWillDos.sorted { $0.createAt < $1.createAt }
                result += flattened(children, level: level + 1)
            }
        }

        return result
    }
}

struct FlattenedWillDo: Identifiable {
    let willDo: WillDo
    let level: Int
    
    var id: String { willDo.id }
}

struct OneWillDoView: View {
    let item: FlattenedWillDo
    let isExpanded: Bool
    let toggleExpansion: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Spacer()
                    .frame(width: CGFloat(item.level) * 20)

                // 展開アイコン or プレースホルダー
                if !item.willDo.childWillDos.isEmpty {
                    Image(systemName: isExpanded ? "chevron.down.circle.fill" : "chevron.right.circle.fill")
                        .foregroundColor(.blue)
                        .onTapGesture {
                            toggleExpansion(item.willDo.id)
                        }
                } else {
                    Image(systemName: "circle")
                        .opacity(0.5)
                }

                // 優先度による色付きアイコン
                Circle()
                    .fill(colorForPriority(item.willDo.priority))
                    .frame(width: 10, height: 10)

                // コンテンツ
                Text(item.willDo.content)
                    .font(.body)
                    .padding(.leading, 4)

                Spacer()
            }
            .contentShape(Rectangle())
            .onTapGesture {
                toggleExpansion(item.willDo.id)
            }

            // 進捗バー（status に応じて）
            ProgressView(value: item.willDo.status.progress)
                .accentColor(item.willDo.status.color)
                .padding(.leading, CGFloat(item.level) * 20 + 32)

            // 目標日がある場合に表示
            if let goalDate = item.willDo.goalAt {
                Text("目標: \(formatted(date: goalDate))")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.leading, CGFloat(item.level) * 20 + 32)
            }
        }
        .padding(.vertical, 4)
    }

    private func formatted(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }

    private func colorForPriority(_ priority: Priority?) -> Color {
        switch priority {
        case .high:
            return .red
        case .medium:
            return .orange
        case .low:
            return .green
        case .none:
            return .gray
        }
    }
}


