//
//  TodoFormReminderSection.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 待辦事項表單提醒設定區段元件
/// 提供提醒開關和時間選擇功能
struct TodoFormReminderSection: View {
    @Binding var reminderEnabled: Bool
    @Binding var reminderDate: Date
    
    var body: some View {
        Section {
            Toggle("設定提醒", isOn: $reminderEnabled)
            
            if reminderEnabled {
                DatePicker("提醒時間", selection: $reminderDate, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(GraphicalDatePickerStyle())
            }
        } header: {
            Text("提醒")
        }
    }
}

#Preview {
    @State var reminderEnabled = false
    @State var reminderDate = Date()
    return Form {
        TodoFormReminderSection(
            reminderEnabled: $reminderEnabled,
            reminderDate: $reminderDate
        )
    }
}