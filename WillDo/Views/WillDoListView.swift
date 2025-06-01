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
                    status: .completed,
                    parentId: "1" // 適切にIDをセットしてください
                ),
                WillDo(
                    content: "単語帳のページ2を覚える",
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
                            status: .middle,
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
                    motivation: 65,
                    category: "勉強",
                    status: .planned,
                    parentId: "1"
                ),
                WillDo(
                    content: "単語帳の復習をする",
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
                        .listRowBackground(
                            HStack(spacing: 0) {
                                // 左側 白の領域
                                Color.white
                                    .frame(width: CGFloat(item.level) * 20)

                                // 右側は階層色
                                backgroundColor(for: item.level)
                            }
                        )
                    }
                }
                .scrollContentBackground(.hidden)
                .background(Color(.systemGray6))
            }
        }
    }
    
    func backgroundColor(for level: Int) -> Color {
        let colors: [Color] = [
            Color(red: 1.0, green: 1.0, blue: 1.0), // white
            Color(red: 0.90, green: 0.93, blue: 1.0), // very light blue
            Color(red: 0.92, green: 0.97, blue: 0.95), // mint
            Color(red: 1.0, green: 0.98, blue: 0.92), // pastel yellow
            Color(red: 1.0, green: 0.95, blue: 0.95), // pink
            Color(red: 0.96, green: 0.92, blue: 1.0)  // lavender
        ]
        return colors[min(level, colors.count - 1)]
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

                Image(systemName: "dumbbell.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: size, height: size)
                    .frame(width: 25)

                Circle()
                    .fill(colorForPriority(item.willDo.priority))
                    .frame(width: 10, height: 10)

                Text(item.willDo.content)
                    .font(.body)
                    .padding(.leading, 4)

                Spacer()

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

            ProgressView(value: item.willDo.totalProgress)
                .accentColor(item.willDo.effectiveStatusColor)
                .padding(.leading, CGFloat(item.level) * 20 + 32)

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
    
    private func colorForProgress(_ progress: Double) -> Color {
        switch progress {
        case 0..<0.3:
            return .red
        case 0.3..<0.7:
            return .orange
        case 0.7...1.0:
            return .green
        default:
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


extension WillDo {
    var totalProgress: Double {
        if childWillDos.isEmpty {
            return status.progress
        } else {
            let progresses = childWillDos.map { $0.totalProgress }
            return progresses.reduce(0, +) / Double(progresses.count)
        }
    }

    var effectiveStatusColor: Color {
        if childWillDos.isEmpty {
            return status.color
        } else {
            let average = totalProgress
            switch average {
            case 0..<0.3: return .red
            case 0.3..<0.7: return .orange
            case 0.7...1.0: return .green
            default: return .gray
            }
        }
    }
}
