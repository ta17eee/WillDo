//
//  CalendarView.swift
//  WillDo
//
//  Created by 高野　泰生 on 2025/05/31.
//

import Foundation
import SwiftUI
import SwiftData

struct CalendarView: View {
    private enum ActiveSheet: Identifiable {
        case pickMonth, showLog
        
        var id: Int {
            hashValue
        }
    }
    
    @Query var willDos: [WillDo]
    @State var monthOffset: Int = 0
    @State private var activeSheet: ActiveSheet?
    private let week: [String] = ["sun", "mon", "tue", "wed", "thu", "fri", "sat"]
    
    @State private var willDoHeight: CGFloat = 300
    @State private var lastDragValue: CGFloat = 0
    @State private var selectedDateForScroll: String? = nil
    
    var willDosInCurrentMonth: [WillDo] {
        let targetMonth = Int(getTargetMonth()) ?? 0
        let targetYear = Int(getTargetYear()) ?? 0
        return flattenWillDos(sampleWillDos)
            .filter {
                guard let goalAt = $0.goalAt else { return false }
                let components = Calendar(identifier: .gregorian).dateComponents([.year, .month], from: goalAt)
                return components.year == targetYear && components.month == targetMonth
            }
            .sorted { ($0.goalAt ?? Date.distantFuture) < ($1.goalAt ?? Date.distantFuture) }
    }

    
    
    var body: some View {
        GeometryReader { geo in
            let screenHeight = geo.size.height
            let totalSpacing: CGFloat = 5 * 6  // HStackのスペースが5、7列なので6箇所
            let horizontalPadding: CGFloat = 16 * 2 // 両端の余白仮に16pt
            let cellWidth = (geo.size.width - totalSpacing - horizontalPadding) / 7
            ZStack (alignment: .bottom) {
                
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
                                            print(day)
                                            change(day: day)
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
                                                            let displayWillDos = willDos.prefix(2)
                                                            
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
                                        .frame(height: 50)
                                    }
                                }
                            }
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
                VStack(spacing: 0) {
                    // グリップ（つまみ）
                    Capsule()
                        .fill(Color.gray)
                        .frame(width: 40, height: 6)
                        .padding(8)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    let newHeight = willDoHeight - (value.translation.height - lastDragValue)
                                    willDoHeight = min(max(newHeight, 100), screenHeight * 0.9)
                                    lastDragValue = value.translation.height
                                }
                                .onEnded { _ in
                                    lastDragValue = 0
                                }
                        )

                    Divider()

                    // 中身のリスト
                    FlatWillDoListView(
                        willDos: willDosInCurrentMonth,
                        onTap: { willDo in print("Tapped WillDo: \(willDo.content)") },
                        selectedWillDo: nil,
                        scrollToDate: selectedDateForScroll ?? ""
                    )
                    .padding(.top, 4)

                }
                .background(Color(.systemBackground))
                .cornerRadius(16)
                .frame(height: willDoHeight)
                .animation(.easeInOut(duration: 0.2), value: willDoHeight)
                .shadow(radius: 5)
    
            }
            
        }
    }
    
    func change(day: Int) {
        let dateString = formattedDate(year: Int(getTargetYear())!, month: Int(getTargetMonth())!, day: day)
        selectedDateForScroll = dateString
        print(selectedDateForScroll)
    }
    
    func formattedDate(year: Int, month: Int, day: Int) -> String {
        String(format: "%04d年%02d月%02d日", year, month, day)
    }
    
    func dummy(_ willDo: WillDo) {
        
    }
    
    func flattenWillDos(_ willDos: [WillDo]) -> [WillDo] {
        var result: [WillDo] = []
        for willDo in willDos {
            result.append(willDo)
            result.append(contentsOf: flattenWillDos(willDo.childWillDos))
        }
        return result
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

        // 🔽 ここで全階層を展開
        let allWillDos = flattenWillDos(sampleWillDos)

        let willDosForDay = allWillDos.filter {
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

struct DraggableDividerView: View {
    @State private var offsetY: CGFloat = 0

    var body: some View {
        Divider()
            .frame(height: 2)
            .background(Color.blue)
            .offset(y: offsetY)
            .gesture(
                DragGesture()
                    .onChanged { value in
                        offsetY = value.translation.width
                    }
                    .onEnded { _ in
                        // 必要ならスナップバックなど
                    }
            )
            .padding()
    }
}
