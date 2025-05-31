//
//  CreateWillDo.swift
//  WillDo
//
//  Created by 高野　泰生 on 2025/05/31.
//

import SwiftUI
import SwiftData

struct CreateWillDo: View {
    @Environment(\.modelContext) private var context
    @Query private var willDos: [WillDo]
    @State private var expandedIds: Set<String> = []
    @State private var selectedParentWillDo: WillDo? = nil
    @State private var isCreatingNewWillDo = false
    
    // サンプルデータ（WillDoListViewと同じやつ）
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
                            parentId: "1"
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
                    parentId: "1"
                ),
                WillDo(
                    content: "単語帳のページ2を覚える",
                    motivation: 65,
                    category: "勉強",
                    status: .planned,
                    parentId: "parent1"
                ),
                WillDo(
                    content: "単語帳の復習をする",
                    motivation: 60,
                    category: "勉強",
                    status: .planned,
                    parentId: "parent1"
                )
            ],
            motivation: 80,
            category: "勉強"
        ),
        WillDo(
            content: "健康的な生活習慣を身につける",
            childWillDos: [
                WillDo(
                    content: "早寝早起きをする",
                    motivation: 75,
                    category: "健康",
                    status: .start,
                    parentId: "parent2"
                ),
                WillDo(
                    content: "毎日運動する",
                    motivation: 70,
                    category: "健康",
                    status: .planned,
                    parentId: "parent2"
                )
            ],
            motivation: 85,
            category: "健康"
        ),
        WillDo(
            content: "本を読む",
            motivation: 60,
            category: "読書",
            goalAt: Calendar.current.date(byAdding: .month, value: 1, to: Date()),
            status: .middle,
            impression: "読み切ったけどまとめるのが大変だった"
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                Text("新しいWillDoを作成する場所を選択してください")
                    .font(.headline)
                    .padding()
                
                List {
                    ForEach(flattened(sampleWillDos.filter { $0.parentId == nil })) { item in
                        SelectableWillDoView(
                            item: item,
                            isExpanded: expandedIds.contains(item.willDo.id),
                            isSelected: selectedParentWillDo?.id == item.willDo.id,
                            toggleExpansion: toggleExpansion,
                            selectParent: selectParent
                        )
                    }
                }
                
                VStack(spacing: 16) {
                    Button(action: {
                        selectedParentWillDo = nil
                        isCreatingNewWillDo = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("新しいWillDoをルートに作成")
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .padding(.horizontal)
                    
                    if selectedParentWillDo != nil {
                        Button(action: {
                            isCreatingNewWillDo = true
                        }) {
                            HStack {
                                Image(systemName: "plus.circle.fill")
                                Text("選択したWillDoの子として作成")
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom)
            }
            .navigationTitle("WillDo作成")
        }
        .sheet(isPresented: $isCreatingNewWillDo) {
            WillDoFormView(parentWillDo: selectedParentWillDo)
        }
    }
    
    func toggleExpansion(id: String) {
        if expandedIds.contains(id) {
            expandedIds.remove(id)
        } else {
            expandedIds.insert(id)
        }
    }
    
    func selectParent(_ willDo: WillDo?) {
        selectedParentWillDo = willDo
    }
    
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

struct SelectableWillDoView: View {
    let item: FlattenedWillDo
    let isExpanded: Bool
    let isSelected: Bool
    let toggleExpansion: (String) -> Void
    let selectParent: (WillDo?) -> Void

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
                
                // 選択インジケーター
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                }
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if isSelected {
                    selectParent(nil)
                }
                else {
                    selectParent(item.willDo)
                }
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
        .background(isSelected ? Color.blue.opacity(0.1) : Color.clear)
        .cornerRadius(8)
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

struct WillDoFormView: View {
    let parentWillDo: WillDo?
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack {
                if let parent = parentWillDo {
                    Text("親WillDo: \(parent.content)")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                } else {
                    Text("新規WillDoを作成")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                }
                Divider()
                
                // 中身は後で作成
                
                Spacer()
            }
            .navigationBarItems(
                leading: Button("キャンセル") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

#Preview {
    TabView {
        CreateWillDo()
            .tabItem {
                Label("作成", systemImage: "plus")
            }
    }
}
