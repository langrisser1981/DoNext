//
//  TodoFormRepeatSection.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 待辦事項表單重複設定區段元件
/// 提供重複類型選擇功能
struct TodoFormRepeatSection: View {
    @Binding var repeatType: RepeatType
    
    var body: some View {
        Section {
            Picker("重複", selection: $repeatType) {
                ForEach(RepeatType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
        } header: {
            Text("重複")
        }
    }
}

#Preview {
    @State var repeatType = RepeatType.none
    return Form {
        TodoFormRepeatSection(repeatType: $repeatType)
    }
}