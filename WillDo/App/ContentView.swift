//
//  ContentView.swift
//  WillDo
//
//  Created by 高野　泰生 on 2025/05/31.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var items: [Item]
    @State var selectedTab: Int = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            WillDoListView()
                .tabItem {
                    Label("WillDo", systemImage: "list.bullet")
                }
                .tag(0)
            
            CreateWillDo()
                .tabItem {
                    Label("作成", systemImage: "plus")
                }
                .tag(1)

            CalendarView()
                .tabItem {
                    Label("カレンダー", systemImage: "calendar")
                }
                .tag(2)

            AnalyzeView()
                .tabItem {
                    Label("分析", systemImage: "chart.bar")
                }
                .tag(3)
        }
    }

    private func addItem() {
        withAnimation {
            let newItem = Item(timestamp: Date())
            modelContext.insert(newItem)
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
