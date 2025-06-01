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
    @State private var filterSetting: FilterSetting = .init(
        hideCompleted: true,
        selectedCategories: Category.allCases
    )
    @State private var selectedWillDo: WillDo?

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
                
                
                CategoryFilterTiles(selectedCategories: $filterSetting.selectedCategories)
                
                HStack(spacing: 8) {
                    Spacer()
                    Text("完了済みWill Doを隠す")
                        .font(.subheadline)

                    Button(action: {
                        // トグル処理
                        filterSetting.hideCompleted = filterSetting.hideCompleted ? false : true
                    }) {
                        Image(systemName: filterSetting.hideCompleted ? "eye.slash" : "eye")
                            .imageScale(.large)
                            .padding(6)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                    .padding(.trailing)
                }
                
                WillDoList(sortSetting: sortSetting, filterSetting: filterSetting, onTap: dummy)
            }
        }
        .sheet(item: $selectedWillDo) { willDo in
            WillDoFormView(willDo: willDo)
        }
    }
    
    // MARK: 詳細表示をする関数を定義する
    func dummy(_ willDo: WillDo) {
        selectedWillDo = willDo
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

struct FilterSetting {
    var hideCompleted: Bool = false
    var selectedCategories: [Category] = Category.allCases
}

struct CategoryFilterTiles: View {
    @Binding var selectedCategories: [Category]
    
    // タイルの幅を適宜調整してください
    let tileWidth: CGFloat = 100
    let tileHeight: CGFloat = 35
    
    var body: some View {
        // タイルをグリッド状に並べたいならLazyVGridなどにするのもアリ
        // ここでは横並びでスクロール
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                Button(action: {
                    toggleAll()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: isAllSelected ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(isAllSelected ? .white : .gray)
                        Text("全て表示")
                            .font(.system(size: 14))
                            .foregroundColor(isAllSelected ? .white : .gray)
                    }
                    .frame(width: tileWidth, height: tileHeight)
                    .background(isAllSelected ? Color.blue : Color.gray.opacity(0.2))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isAllSelected ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                ForEach(Category.allCases) { category in
                    Button(action: {
                        toggleCategory(category)
                    }) {
                        HStack(spacing: 6) {
                            Image(systemName: category.iconName)
                                .foregroundColor(selectedCategories.contains(category) ? .white : .gray)
                            Text(category.displayName)
                                .font(.system(size: 14))
                                .foregroundColor(selectedCategories.contains(category) ? .white : .gray)
                        }
                        .frame(width: tileWidth, height: tileHeight)
                        .background(selectedCategories.contains(category) ? Color.blue : Color.gray.opacity(0.2))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(selectedCategories.contains(category) ? Color.blue : Color.gray.opacity(0.5), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal)
        }
    }
    
    // 全選択中かどうか
    private var isAllSelected: Bool {
        Set(selectedCategories) == Set(Category.allCases)
    }
    
    private func toggleAll() {
        if isAllSelected {
            // 全解除
            selectedCategories = []
        } else {
            // 全選択
            selectedCategories = Category.allCases
        }
    }
    
    private func toggleCategory(_ category: Category) {
        if selectedCategories.contains(category) {
            selectedCategories.removeAll { $0 == category }
        } else {
            selectedCategories.append(category)
        }
    }
}
