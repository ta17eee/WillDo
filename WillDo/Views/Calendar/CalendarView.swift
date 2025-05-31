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
    
    var body: some View {
        HStack {
            Spacer()
            VStack(alignment: .center, spacing: 8) {
                Spacer()
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
                    HStack(spacing: 8) {
                        ForEach(week, id: \.self) { day in
                            if day == 0 {
                                Color.clear
                            }
                            else {
                                Button(action: {
                                    
                                }) {
                                    ZStack {
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(Color.white)
                                            .shadow(radius: 1)
                                        VStack {
                                            Text("\(day)")
                                                .foregroundStyle(Calendar.getDayColor(day: day, monthOffset: monthOffset))
                                                .padding(4)
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
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
    
    private func getTargetMonth() -> String{
        let now = Date()
        let target = Calendar.current.date(byAdding: .month, value: monthOffset, to: now)!
        return String(Calendar.current.component(.month, from: target))
    }
    
    private func getTargetYear() -> String {
        let now = Date()
        let target = Calendar.current.date(byAdding: .month, value: monthOffset, to: now)!
        return String(Calendar.current.component(.year, from: target))
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
}

#Preview {
    TabView {
        CalendarView()
    }
}
