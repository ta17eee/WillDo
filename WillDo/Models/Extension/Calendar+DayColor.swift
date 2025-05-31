import Foundation
import SwiftUI

extension Calendar {
    
    static func getDayColor(day: Int, monthOffset: Int) -> Color {
        let now = Date()
        let calendar = Calendar.current
        
        guard let targetMonth = calendar.date(byAdding: .month, value: monthOffset, to: now),
              let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: targetMonth)) else {
            return .black
        }
        
        guard let date = calendar.date(byAdding: .day, value: day - 1, to: firstDayOfMonth) else {
            return .black
        }
        
        if calendar.isJapaneseHoliday(date) {
            return .red
        }
        
        let weekday = calendar.component(.weekday, from: date)
        
        switch weekday {
        case 1: // 日曜日
            return .red
        case 7: // 土曜日
            return .blue
        default: // 平日
            return .primary
        }
    }
    private func isJapaneseHoliday(_ date: Date) -> Bool {
        let year = component(.year, from: date)
        let month = component(.month, from: date)
        let day = component(.day, from: date)
        
        // 固定祝日の判定
        switch (month, day) {
        case (1, 1): // 元日
            return true
        case (2, 11): // 建国記念の日
            return true
        case (2, 23): // 天皇誕生日
            return year >= 2020
        case (3, 21), (3, 20): // 春分の日（おおよその日付）
            return true
        case (4, 29): // 昭和の日
            return true
        case (5, 3): // 憲法記念日
            return true
        case (5, 4): // みどりの日
            return true
        case (5, 5): // こどもの日
            return true
        case (8, 11): // 山の日
            return year >= 2016
        case (9, 23), (9, 22): // 秋分の日（おおよその日付）
            return true
        case (11, 3): // 文化の日
            return true
        case (11, 23): // 勤労感謝の日
            return true
        default:
            break
        }
        
        // 可変祝日の判定
        // 成人の日（1月の第2月曜日）
        if month == 1 && isNthDayOfWeek(date, nth: 2, weekday: 2) {
            return true
        }
        
        // 海の日（7月の第3月曜日）
        if month == 7 && isNthDayOfWeek(date, nth: 3, weekday: 2) {
            return true
        }
        
        // 敬老の日（9月の第3月曜日）
        if month == 9 && isNthDayOfWeek(date, nth: 3, weekday: 2) {
            return true
        }
        
        // スポーツの日（10月の第2月曜日）
        if month == 10 && isNthDayOfWeek(date, nth: 2, weekday: 2) {
            return true
        }
        
        // 振替休日（前日が日曜かつ祝日の場合）
        let yesterday = date.addingTimeInterval(-86400) // 24時間前
        if component(.weekday, from: yesterday) == 1 && isJapaneseHoliday(yesterday) {
            return true
        }
        
        return false
    }
    
    private func isNthDayOfWeek(_ date: Date, nth: Int, weekday: Int) -> Bool {
        let day = component(.day, from: date)
        let dateWeekday = component(.weekday, from: date)
        
        return dateWeekday == weekday && ((nth - 1) * 7 + 1...nth * 7).contains(day)
    }
    
    func daysInMonth(for date: Date) -> Int {
        if let days = range(of: .day, in: .month, for: date)?.count {
            return days
        }
        
        let year = component(.year, from: date)
        let month = component(.month, from: date)
        
        switch month {
        case 1, 3, 5, 7, 8, 10, 12:
            return 31
        case 4, 6, 9, 11:
            return 30
        case 2:
            let isLeapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
            return isLeapYear ? 29 : 28
        default:
            return 30
        }
    }
}
