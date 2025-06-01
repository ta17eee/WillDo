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
    @State private var showSortPopup = false
    @State private var sortSetting = SortSetting(option: .priority, order: .descending)

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
                            status: .start,
                            parentId: "1" // 適切にIDをセットしてください
                        ),
                        WillDo(
                            content: "単語帳のページ2を覚える",
                            motivation: 65,
                            category: "勉強",
                            status: .completed,
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
        ZStack {
            VStack {
                HStack {
                    // ソート対象 Picker（セグメント形式）
                    Picker("並び替え", selection: $sortSetting.option) {
                        ForEach(SortOption.allCases) { option in
                            Text(option.label).tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    
                    // 昇順 / 降順 切り替えボタン
                    Button(action: {
                        // トグル処理
                        sortSetting.order = sortSetting.order == .ascending ? .descending : .ascending
                    }) {
                        Image(systemName: sortSetting.order == .ascending ? "arrow.up" : "arrow.down")
                            .imageScale(.large)
                            .padding(6)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    .padding(.trailing)
                }
                
                
                List {
                    ForEach(flattened(sampleWillDos.filter { $0.parentId == nil }, sortSetting: sortSetting)) { item in
                        OneWillDoView(
                            item: item,
                            isExpanded: expandedIds.contains(item.willDo.id),
                            toggleExpansion: toggleExpansion
                        )
                    }
                }
                
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
    func flattened(_ willDos: [WillDo], level: Int = 0, sortSetting: SortSetting) -> [FlattenedWillDo] {
        var result: [FlattenedWillDo] = []

        let sorted = willDos.sorted { lhs, rhs in
            let isAscending = sortSetting.order == .ascending

            switch sortSetting.option {
            case .priority:
                let l = lhs.priority ?? .low
                let r = rhs.priority ?? .low
                return isAscending ? (l < r) : (l > r)

            case .weight:
                let l = lhs.weight?.rawValue ?? 0
                let r = rhs.weight?.rawValue ?? 0
                return isAscending ? (l < r) : (l > r)

            case .goalAt:
                let l = lhs.goalAt ?? .distantFuture
                let r = rhs.goalAt ?? .distantFuture
                return isAscending ? (l < r) : (l > r)

            case .createAt:
                return isAscending ? (lhs.createAt < rhs.createAt) : (lhs.createAt > rhs.createAt)

            case .status:
                let l = lhs.status.progress
                let r = rhs.status.progress
                return isAscending ? (l < r) : (l > r)
            }
        }

        for willDo in sorted {
            result.append(FlattenedWillDo(willDo: willDo, level: level))
            if expandedIds.contains(willDo.id) {
                result += flattened(willDo.childWillDos, level: level + 1, sortSetting: sortSetting)
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
        let minSize: CGFloat = 10   // veryLow のとき
        let maxSize: CGFloat = 25   // veryHigh のとき

        let weightValue = CGFloat(item.willDo.weight?.rawValue ?? 1)
        let scale = (weightValue - 1) / 4 // → 0〜1 の範囲に変換
        let size = minSize + (maxSize - minSize) * scale
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Spacer()
                    .frame(width: CGFloat(item.level) * 20)

                // 展開アイコン or プレースホルダー
                Image(systemName: "dumbbell.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(
                        width: size,
                        height: size
                    ) // 表示サイズ（大きさ）
                    .frame(width: 25, alignment: .center) // 固定領域

                // 優先度による色付きアイコン
                Circle()
                    .fill(colorForPriority(item.willDo.priority))
                    .frame(width: 10, height: 10)

                // コンテンツ
                Text(item.willDo.content)
                    .font(.body)
                    .padding(.leading, 4)

                Spacer()

                // 🔽 展開マーク（子要素がいるときのみ）
                if !item.willDo.childWillDos.isEmpty {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .foregroundColor(.gray)
                        .padding(.trailing, 8)
                } else {
                    Image(systemName: "chevron.right")
                        .opacity(0)
                }

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

enum SortOption: String, CaseIterable, Identifiable {
    case priority
    case weight
    case goalAt
    case createAt
    case status

    var id: String { rawValue }

    var label: String {
        switch self {
        case .priority: return "優先度"
        case .weight: return "重み"
        case .goalAt: return "目標日"
        case .createAt: return "作成日"
        case .status: return "進捗"
        }
    }
}

enum SortOrder: String, CaseIterable, Identifiable {
    case ascending
    case descending

    var id: String { rawValue }

    var label: String {
        switch self {
        case .ascending: return "昇順"
        case .descending: return "降順"
        }
    }
}

struct SortSetting: Identifiable, Equatable {
    var option: SortOption
    var order: SortOrder

    var id: String { "\(option.rawValue)-\(order.rawValue)" }
}


