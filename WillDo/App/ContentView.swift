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
}

#Preview {
    ContentView()
        .modelContainer(for: WillDo.self, inMemory: true)
}
