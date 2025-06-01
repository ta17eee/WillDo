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
    @State private var showSortPopup = false
    @State private var sortSetting = SortSetting(option: .priority, order: .descending)

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
                WillDoList(sortSetting: sortSetting, onTap: dummy)
            }
        }
    }
    
    // MARK: 詳細表示をする関数を定義する
    func dummy(_ willDo: WillDo) {
        
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
