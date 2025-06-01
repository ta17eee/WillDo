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

#Preview {
    TabView {
        CreateWillDo()
            .tabItem {
                Label("作成", systemImage: "plus")
            }
    }
}
