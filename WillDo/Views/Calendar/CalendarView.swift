//
//  CalendarView.swift
//  WillDo
//
//  Created by 高野　泰生 on 2025/05/31.
//

import Foundation
import SwiftUI

struct CalendarView: View {
    private enum ActiveSheet: Identifiable {
        case pickMonth, showLog
        
        var id: Int {
            hashValue
        }
    }
    
    @State var monthOffset: Int = 0
    @State private var activeSheet: ActiveSheet?
    private let week: [String] = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
    
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
                            status: .start,
                            parentId: "1" // 適切にIDをセットしてください
                        ),
                        WillDo(
                            content: "単語帳のページ2を覚える",
                            motivation: 65,
                            category: "勉強",
                            status: .completed,
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
                    status: .completed,
                    parentId: "1" // 適切にIDをセットしてください
                ),
                WillDo(
                    content: "単語帳のページ2を覚える",
                    childWillDos: [
                        WillDo(
                            content: "単語帳のページ1を覚える",
                            motivation: 70,
                            category: "勉強",
                            status: .start,
                            parentId: "1" // 適切にIDをセットしてください
                        ),
                        WillDo(
                            content: "単語帳のページ2を覚える",
                            motivation: 65,
                            category: "勉強",
                            status: .middle,
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
                    motivation: 65,
                    category: "勉強",
                    status: .planned,
                    parentId: "1"
                ),
                WillDo(
                    content: "単語帳の復習をする",
                    childWillDos: [
                        WillDo(
                            content: "単語帳のページ1を覚える",
                            motivation: 70,
                            category: "勉強",
                            status: .start,
                            parentId: "1" // 適切にIDをセットしてください
                        ),
                        WillDo(
                            content: "単語帳のページ2を覚える",
                            motivation: 65,
                            category: "勉強",
                            status: .completed,
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
                    motivation: 60,
                    category: "勉強",
                    status: .planned,
                    parentId: "1"
                )
            ],
            motivation: 80,
            category: "勉強",
            goalAt: Calendar(identifier: .gregorian).date(byAdding: .month, value: 0, to: Date()),
            weight: .medium,
            priority: .high,
            status: .start,
            memoList: [
                Memo(date: Date(), content: "DUO 3.0 で始めた")
            ]
        ),
        WillDo(
            content: "ランニングを週3回する",
            motivation: 60,
            category: "健康",
            goalAt: Calendar(identifier: .gregorian).date(byAdding: .month, value: 0, to: Date()),
            weight: .low,
            priority: .medium,
            status: .planned
        ),
        WillDo(
            content: "アプリ開発のポートフォリオを完成させる",
            motivation: 95,
            category: "自己成長",
            goalAt: Calendar(identifier: .gregorian).date(byAdding: .month, value: 0, to: Date())!,
            weight: .veryHigh,
            priority: .high,
            status: .middle,
            memoList: [
                Memo(date: Date(), content: "画面設計完了。次はFirestore連携")
            ]
        ),
        WillDo(
            content: "読書感想文を書く",
            motivation: 40,
            category: "学校",
            goalAt: Calendar(identifier: .gregorian).date(byAdding: .month, value: 0, to: Date()),
            weight: .high,
            priority: .low,
            status: .almostDone,
            impression: "読み切ったけどまとめるのが大変だった"
        )
    ]
    
    var willDosInCurrentMonth: [WillDo] {
        let targetMonth = Int(getTargetMonth()) ?? 0
        let targetYear = Int(getTargetYear()) ?? 0

        return sampleWillDos
            .filter {
                guard let goalAt = $0.goalAt else { return false }
                let components = Calendar(identifier: .gregorian).dateComponents([.year, .month], from: goalAt)
                return components.year == targetYear && components.month == targetMonth
            }
            .sorted { ($0.goalAt ?? Date.distantFuture) < ($1.goalAt ?? Date.distantFuture) }
    }
    
    var body: some View {
        GeometryReader { geo in
            let totalSpacing: CGFloat = 5 * 6  // HStackのスペースが5、7列なので6箇所
            let horizontalPadding: CGFloat = 16 * 2 // 両端の余白仮に16pt
            let cellWidth = (geo.size.width - totalSpacing - horizontalPadding) / 7
            HStack {
                Spacer()
                VStack(alignment: .center, spacing: 5) {
                    HStack(spacing: 8) {
                        Button(action: {
                            activeSheet = .pickMonth
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .shadow(radius: 1)
                                    .frame(width: 44, height: 44)
                                Image(systemName: "calendar")
                            }
                        }
                        Button(action: {
                            monthOffset -= 1
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .shadow(radius: 1)
                                    .frame(width: 44, height: 44)
                                Image(systemName: "arrow.left")
                            }
                        }
                        Spacer()
                        HStack {
                            Text("\(getTargetYear())")
                            Text("/")
                            Text("\(getTargetMonth())")
                        }
                        .font(.title)
                        Spacer()
                        Button(action: {
                            monthOffset += 1
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .shadow(radius: 1)
                                    .frame(width: 44, height: 44)
                                Image(systemName: "arrow.right")
                            }
                        }
                        Button(action: {
                            monthOffset = 0
                        }) {
                            ZStack {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white)
                                    .shadow(radius: 1)
                                    .frame(width: 44, height: 44)
                                Image(systemName: "arrow.counterclockwise")
                            }
                        }
                        .disabled(monthOffset == 0)
                    }
                    .font(.title3)
                    HStack(spacing: 8) {
                        ForEach(week, id: \.self) { day in
                            ZStack {
                                Color.clear
                                Text("\(day)")
                                    .foregroundColor(getDayColor(for: day))
                            }
                            .frame(height: 32)
                        }
                    }
                    ForEach(getMonthCalendar(offset: monthOffset), id: \.self) { week in
                        HStack(spacing: 5) {
                            ForEach(week, id: \.self) { day in
                                if day == 0 {
                                    Color.clear
                                        .frame(height: 60)
                                }
                                else {
                                    Button(action: {
                                        
                                    }) {
                                        ZStack {
                                            RoundedRectangle(cornerRadius: 0)
                                                .fill(Color.white)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 4)
                                                        .stroke(Color.gray, lineWidth: 1)
                                                )

                                            VStack(spacing: 2) {
                                                // 上部：日付部分（clipされない）
                                                Text("\(day)")
                                                    .font(.system(size: cellWidth / 5))
                                                    .frame(width: cellWidth - 8, alignment: .leading)
                                                    .foregroundStyle(Calendar.getDayColor(day: day, monthOffset: monthOffset))
                                                    .padding(.top, 2)

                                                // 下部：予定表示部分（clipされる）
                                                GeometryReader { geometry in
                                                    VStack(spacing: 2) {
                                                        let willDos = willDosForDay(day, monthOffset: monthOffset)
                                                        let displayWillDos = willDos.prefix(3)

                                                        ForEach(displayWillDos, id: \.self) { willDo in
                                                            Text(String(willDo.prefix(4)))
                                                                .font(.system(size: cellWidth / 5))
                                                                .lineLimit(1)
                                                                .frame(width: cellWidth - 8, alignment: .leading)
                                                                .foregroundColor(.white)
                                                                .padding(.horizontal, 3)
                                                                .background(
                                                                    RoundedRectangle(cornerRadius: 2).fill(Color.gray)
                                                                )
                                                        }
                                                    }
                                                    .frame(maxHeight: geometry.size.height) // GeometryReaderの高さまでに制限
                                                    .clipped()
                                                }
                                            }
                                            .padding(2)
                                        }
                                    }
                                    .frame(height: 60)
                                }
                            }
                        }
                    }
                    Divider()
                    ScrollView {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(willDosInCurrentMonth, id: \.id) { willDo in
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(willDo.content)
                                            .font(.headline)
                                        if let goalDate = willDo.goalAt {
                                            Text("目標日: \(formatDateWithGregorianCalendar(goalDate))")
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                    Spacer()
                                    // ステータスやモチベーション表示（必要に応じて）
                                }
                                .padding(8)
                                .background(RoundedRectangle(cornerRadius: 8).stroke(Color.gray))
                            }
                        }
                        .padding()
                    }
                    Spacer()
                }
                Spacer()
            }
            .sheet(item: $activeSheet) { sheet in
                switch sheet {
                case .pickMonth:
                    MonthPickView(monthOffset: $monthOffset)
                        .presentationDetents([.height(312)])
                case .showLog:
                    EmptyView()
                }
            }
        }
    }
    
    private func willDosForDay(_ day: Int, monthOffset: Int) -> [String] {
        let calendar = Calendar(identifier: .gregorian)
        let now = Date()
        guard let targetMonthDate = calendar.date(byAdding: .month, value: monthOffset, to: now),
              let year = calendar.dateComponents([.year], from: targetMonthDate).year,
              let month = calendar.dateComponents([.month], from: targetMonthDate).month else {
            return []
        }

        var components = DateComponents()
        components.year = year
        components.month = month
        components.day = day
        components.hour = 0
        components.minute = 0
        components.second = 0

        guard calendar.date(from: components) != nil else {
            return []
        }

        let willDosForDay = sampleWillDos.filter {
            guard let goalAt = $0.goalAt else { return false }
            let comp = calendar.dateComponents([.year, .month, .day], from: goalAt)
            return comp.year == year && comp.month == month && comp.day == day
        }

        return willDosForDay.map { $0.content }
    }
    
    private func getTargetMonth() -> String{
        let now = Date()
        let target = Calendar.current.date(byAdding: .month, value: monthOffset, to: now)!
        return String(Calendar.current.component(.month, from: target))
    }
    
    private func getTargetYear() -> String {
        let now = Date()
        let gregorian = Calendar(identifier: .gregorian)
        let target = gregorian.date(byAdding: .month, value: monthOffset, to: now)!
        let year = gregorian.component(.year, from: target)
        return String(year)
    }
    
    private func getDayColor(for day: String) -> Color {
        switch day {
        case "sun":
            return .red
        case "sat":
            return .cyan
        default:
            return .primary
        }
    }
    
    private func getMonthCalendar(offset: Int) -> [[Int]] {
        let calendar = Calendar.current
        let now = Date()
        let target = calendar.date(byAdding: .month, value: offset, to: now)!
        
        let daysCount = calendar.daysInMonth(for: target)
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: target))!
        let firstDay = calendar.component(.weekday, from: firstDayOfMonth)
        
        var result: [[Int]] = []
        var day = 1
        
        for weekRow in 0..<6 {
            var week: [Int] = []
            
            for weekdayColumn in 1...7 {
                let isEmptyDay = (weekRow == 0 && weekdayColumn < firstDay) || day > daysCount
                week.append(isEmptyDay ? 0 : day)
                if !isEmptyDay {
                    day += 1
                }
            }

            result.append(week)
        }
        
        return result
    }
    
    private func formatDateWithGregorianCalendar(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.calendar = Calendar(identifier: .gregorian) // 西暦固定
        formatter.locale = Locale(identifier: "ja_JP")         // 日本語表記で年月日
        formatter.dateFormat = "yyyy年M月d日"                   // 好みでフォーマットを調整可
        return formatter.string(from: date)
    }
}

#Preview {
    TabView {
        CalendarView()
    }
}

struct FixedClipped: ViewModifier {
    func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            content.hidden().layoutPriority(1)
            content.fixedSize(horizontal: true, vertical: false)
        }
        .clipped()
    }
}

extension View {
    func fixedClipped() -> some View {
        self.modifier(FixedClipped())
    }
}
