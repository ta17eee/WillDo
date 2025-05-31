import Foundation
import SwiftUI

struct MonthPickView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var monthOffset: Int
    @State var selectedMonth: Int = Calendar.current.component(.month, from: Date())
    @State var selectedYear: Int = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        VStack {
            HStack {
                Button("キャンセル") {
                    dismiss()
                }
                .padding(.horizontal)
                .frame(height: 44)
                Spacer()
                Button("確定") {
                    let month = Calendar.current.component(.month, from: Date())
                    let year = Calendar.current.component(.year, from: Date())
                    monthOffset = (selectedYear - year) * 12 + (selectedMonth - month)
                    dismiss()
                }
                .padding(.horizontal)
                .frame(height: 44)
            }
            Spacer()
                .frame(height: 0)
            HStack {
                Picker("年", selection: $selectedYear) {
                    ForEach(2000...2099, id: \.self) { year in
                        Text(String(year))
                    }
                }
                .pickerStyle(.wheel)
                Picker("月", selection: $selectedMonth) {
                    ForEach(1...12, id: \.self) { month in
                        Text(String(month))
                    }
                }
                .pickerStyle(.wheel)
            }
            Spacer()
        }
    }
}
