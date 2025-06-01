import SwiftUI
import SwiftData

struct WillDoFormView: View {
    let parentWillDo: WillDo?
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.modelContext) private var modelContext: ModelContext
    // フォームの状態管理
    @State private var content: String = ""
    @State private var category: Category = .work
    @State private var goalAt: Date? = nil
    @State private var hasGoal: Bool = false
    @State private var selectedWeight: Weight? = nil
    @State private var selectedPriority: Priority? = nil
    @State private var memoText: String = ""
    @State private var motivation: Double = 50
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // ヘッダー
                    VStack(alignment: .leading, spacing: 8) {
                        if let parent = parentWillDo {
                            Text("親WillDo: \(parent.content)")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            Divider()
                        }
                    }
                    .padding(.horizontal)
                    
                    VStack(alignment: .leading, spacing: 24) {
                        // タイトル（content）
                        VStack(alignment: .leading, spacing: 8) {
                            Text("タイトル")
                                .font(.headline)
                            TextField("\(parentWillDo == nil ? "やりたい" : "やる")ことを入力してください", text: $content)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        }
                        
                        // カテゴリー
                        HStack {
                            Text("カテゴリー")
                                .font(.headline)
                            Spacer()
                            Picker("", selection: $category) {
                                ForEach(Category.allCases, id: \.self) { category in
                                    Text(category.displayName).tag(category as Category)
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                        }
                        
                        // 目標時間
                        HStack {
                            Text("目標時間")
                                .font(.headline)
                            if hasGoal {
                                DatePicker(
                                    "",
                                    selection: Binding(
                                        get: { goalAt ?? Date() },
                                        set: { goalAt = $0 }
                                    ),
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .datePickerStyle(CompactDatePickerStyle())
                                .environment(\.locale, Locale(identifier: "ja_JP"))
                                .onChange(of: hasGoal) {
                                    if !hasGoal {
                                        goalAt = nil
                                    } else if goalAt == nil {
                                        goalAt = Date()
                                    }
                                }
                            } else {
                                Spacer()
                            }
                            Toggle(isOn: $hasGoal) {
                                EmptyView()
                            }
                            .labelsHidden()
                        }
                        .frame(height: 32)
                        
                        // モチベーション
                        HStack {
                            Text("モチベーション：\(Int(motivation))")
                                .font(.headline)
                                .frame(width: 160, alignment: .leading)
                            Slider(value: $motivation, in: 0...100, step: 1)
                                .accentColor(.blue)
                        }
                        
                        HStack(spacing: 8) {
                            // 重要度（Weight）
                            HStack {
                                Text("重要度")
                                    .font(.headline)
                                Spacer()
                                Picker("重要度", selection: $selectedWeight) {
                                    Text("選択なし").tag(Weight?.none)
                                    ForEach(Weight.allCases, id: \.self) { weight in
                                        Text(weight.label).tag(weight as Weight?)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            // 優先度（Priority）
                            HStack {
                                Text("優先度")
                                    .font(.headline)
                                Spacer()
                                Picker("優先度", selection: $selectedPriority) {
                                    Text("選択なし").tag(Priority?.none)
                                    ForEach(Priority.allCases, id: \.self) { priority in
                                        Text(priority.label).tag(priority as Priority?)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                        }
                        
                        // メモ
                        VStack(alignment: .leading, spacing: 8) {
                            Text("メモ")
                                .font(.headline)
                            
                            ZStack(alignment: .topLeading) {
                                TextEditor(text: $memoText)
                                    .frame(minHeight: 100)
                                    .padding(4)
                                    .background(Color(.systemGray6))
                                    .cornerRadius(8)
                                
                                if memoText.isEmpty {
                                    Text("自由にメモを記述してください...")
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 8)
                                        .padding(.vertical, 12)
                                        .allowsHitTesting(false)
                                }
                            }
                        }
                        
                        // 作成ボタン
                        Button(action: createWillDo) {
                            Text("WillDoを作成")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(content.isEmpty ? Color.gray : Color.blue)
                                .cornerRadius(10)
                        }
                        .disabled(content.isEmpty)
                        
                    }
                    .padding(.horizontal)
                }
            }
            .navigationTitle(parentWillDo != nil ? "子WillDoを作成" : "新規WillDoを作成")
            .navigationBarItems(
                leading: Button("キャンセル") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private func createWillDo() {
        // WillDoインスタンスを作成
        let newWillDo = WillDo(
            content: content,
            motivation: Int(motivation),
            category: category,
            goalAt: goalAt,
            weight: selectedWeight,
            priority: selectedPriority,
            parent: parentWillDo
        )
        
        // メモがある場合は追加
        if !memoText.isEmpty {
            let memo = Memo(date: Date(), content: memoText)
            newWillDo.memoList.append(memo)
        }
        
        // TODO: ここでデータ保存処理を実装（今はテストが書いてある）
        if newWillDo.parent == nil {
            modelContext.insert(newWillDo)
            do {
                try modelContext.save()
            } catch {
                return
            }
        } else {
            parentWillDo!.childWillDos.append(newWillDo)
            modelContext.insert(parentWillDo!)
            do {
                try modelContext.save()
            }
            catch {
                return
            }

        }
        
        // フォームを閉じる
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    WillDoFormView(parentWillDo: nil)
}
