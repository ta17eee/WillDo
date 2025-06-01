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
    @State private var selectedParentWillDo: WillDo? = nil
    @State private var isCreatingNewWillDo = false
    
    var body: some View {
        NavigationView {
            VStack {
                Text("新しいWillDoを作成する場所を選択してください")
                    .font(.headline)
                    .padding()
                
                WillDoList(selectedParent: selectedParentWillDo, onTap: selectParent)
                
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
    
    func selectParent(_ willDo: WillDo) {
        if selectedParentWillDo == nil {
            selectedParentWillDo = willDo
        } else {
            selectedParentWillDo = nil
        }
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
        .onTapGesture {
            if isSelected {
                selectParent(nil)
            }
            else {
                selectParent(item.willDo)
            }
        }
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

#Preview {
    TabView {
        CreateWillDo()
            .tabItem {
                Label("作成", systemImage: "plus")
            }
    }
}
