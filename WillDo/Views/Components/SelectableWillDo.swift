import SwiftUI

struct SelectableWillDo: View {
    let item: FlattenedWillDo
    let isExpanded: Bool
    let selectedParent: WillDo?
    let toggleExpansion: (String) -> Void
    let onTap: (WillDo) -> Void

    var body: some View {
        let isSelected = selectedParent?.id == item.willDo.id
        let minSize: CGFloat = 10   // veryLow のとき
        let maxSize: CGFloat = 25   // veryHigh のとき

        let weightValue = CGFloat(item.willDo.weight?.rawValue ?? 1)
        let scale = (weightValue - 1) / 4 // → 0〜1 の範囲に変換
        let size = minSize + (maxSize - minSize) * scale
        
        HStack {
            Spacer()
                .frame(width: CGFloat(item.level) * 20)
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    
                    
                    HStack {
                        if isSelected {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                                .scaledToFit()
                                .frame(width: size, height: size)
                                .frame(width: 25)
                        } else {
                            Image(systemName: "dumbbell.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: size, height: size)
                                .frame(width: 25)
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
                    }
                    .onTapGesture {
                        onTap(item.willDo)
                    }
                    
                    Button(action: {
                        toggleExpansion(item.willDo.id)
                    }) {
                        if !item.willDo.childWillDos.isEmpty {
                            Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                                .foregroundColor(.gray)
                                .padding(.trailing, 8)
                        } else {
                            Image(systemName: "chevron.right")
                                .opacity(0)
                        }
                    }
                    
                }
                .contentShape(Rectangle())
                // 進捗バー（status に応じて）
                ProgressView(value: item.willDo.totalProgress)
                    .accentColor(item.willDo.effectiveStatusColor)
                    .padding(.leading, CGFloat(item.level) * 20 + 32)
                    .padding(.trailing, 4)

                // 目標日がある場合に表示
                if let goalDate = item.willDo.goalAt {
                    Text("目標: \(formatted(date: goalDate))")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.leading, CGFloat(item.level) * 20 + 32)
                }
            }
            .padding(.vertical, 4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color.green, lineWidth: isSelected ? 2 : 0)
            )
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
