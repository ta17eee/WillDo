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
