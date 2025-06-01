//
//  WillDoList.swift
//  WillDo
//
//  Created by 高野　泰生 on 2025/06/01.
//

import SwiftUI
import SwiftData

struct WillDoList: View {
    @Query var WillDos: [WillDo]
    @State var expandedIds: Set<String> = []
    var sortSetting: SortSetting = .init(option: .priority, order: .descending)
    var filterSetting: FilterSetting = .init()
    var selectedParent: WillDo?
    let onTap: (WillDo) -> Void
    
    var body: some View {
        VStack {
            List {
                ForEach(flattened(WillDos.filter { $0.parent == nil }, sortSetting: sortSetting, filterSetting: filterSetting)) { item in
                    SelectableWillDo(
                        item: item,
                        isExpanded: expandedIds.contains(item.willDo.id),
                        selectedParent: selectedParent,
                        toggleExpansion: toggleExpansion,
                        onTap: onTap
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

    func flattened(
        _ willDos: [WillDo],
        level: Int = 0,
        sortSetting: SortSetting,
        filterSetting: FilterSetting
    ) -> [FlattenedWillDo] {
    var result: [FlattenedWillDo] = []

    // ✅ フィルター適用
    let filtered = willDos.filter { willDo in
        var include = true

        // 完了しているものを非表示
        if filterSetting.hideCompleted {
            include = include && !willDo.isEffectivelyCompleted
        }

        // カテゴリが一致するものだけを表示
        if !filterSetting.selectedCategories.isEmpty {
            include = include && filterSetting.selectedCategories.contains(willDo.category)
        }

        return include
    }

        // ✅ ソート処理（そのまま）
        let sorted = filtered.sorted { lhs, rhs in
            let isAscending = sortSetting.order == .ascending

            switch sortSetting.option {
            case .priority:
                let l = lhs.priority ?? Priority.low
                let r = rhs.priority ?? Priority.low
                return isAscending ? (l < r) : (l > r)

            case .weight:
                let l = lhs.weight?.rawValue ?? 0
                let r = rhs.weight?.rawValue ?? 0
                return isAscending ? (l < r) : (l > r)

            case .goalAt:
                let l = lhs.goalAt ?? Date.distantFuture
                let r = rhs.goalAt ?? Date.distantFuture
                return isAscending ? (l < r) : (l > r)

            case .createAt:
                return isAscending ? (lhs.createAt < rhs.createAt) : (lhs.createAt > rhs.createAt)

            case .status:
                let l = lhs.status.progress
                let r = rhs.status.progress
                return isAscending ? (l < r) : (l > r)
            }
        }

        // ✅ 再帰処理
        for willDo in sorted {
            result.append(FlattenedWillDo(willDo: willDo, level: level))
            if expandedIds.contains(willDo.id) {
                result += flattened(
                    willDo.childWillDos,
                    level: level + 1,
                    sortSetting: sortSetting,
                    filterSetting: filterSetting
                )
            }
        }

        return result
    }
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

extension WillDo {
    var isEffectivelyCompleted: Bool {
        if childWillDos.isEmpty {
            return status == .completed
        } else {
            return totalProgress >= 1.0
        }
    }
}

struct FlatWillDoListView: View {
    let willDos: [WillDo]
    let onTap: (WillDo) -> Void
    let selectedWillDo: WillDo?
    let scrollToDate: String? // 追加。スクロールしたい日付の文字列を渡す

    var body: some View {
        ScrollViewReader { proxy in
            List {
                ForEach(groupedByDate.keys.sorted(), id: \.self) { dateString in
                    
                    // ✅ カスタム日付表示（スクロールターゲットにもなる）
                    Text(dateString)
                        .font(.headline)
                        .padding(.vertical, 8)
                        .listRowInsets(EdgeInsets()) // 余白をなくして見た目調整
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(UIColor.systemGroupedBackground))
                        .id(dateString + "_scrollTarget")
                    
                    // ✅ セクションヘッダーなしに変更
                    Section {
                        ForEach(groupedByDate[dateString] ?? []) { willDo in
                            FlatWillDoRow(
                                willDo: willDo,
                                isSelected: selectedWillDo?.id == willDo.id
                            ) {
                                onTap(willDo)
                            }
                        }
                    }
                }
            }
            .onChange(of: scrollToDate) { newValue in
                            guard let targetDate = newValue, !targetDate.isEmpty else { return }
                            let targetID = targetDate + "_scrollTarget"
                            withAnimation {
                                proxy.scrollTo(targetID, anchor: .top)
                            }
                        }
            .onAppear {
                if let targetDate = scrollToDate {
                    let targetID = targetDate + "_scrollTarget" // スクロール先は余白ID
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        withAnimation {
                            proxy.scrollTo(targetID, anchor: .top)
                        }
                    }
                }
            }

        }
    }

    private var groupedByDate: [String: [WillDo]] {
        Dictionary(grouping: willDos) { willDo in
            formattedDate(willDo.goalAt ?? Date.distantFuture)
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy年MM月dd日"
        formatter.locale = Locale(identifier: "ja_JP")
        return formatter.string(from: date)
    }
}

