//
//  TodoFormCategorySection.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 待辦事項表單分類選擇區段元件
/// 提供分類選擇的下拉選單
struct TodoFormCategorySection: View {
    let categories: [Category]
    @Binding var selectedIndex: Int
    
    var body: some View {
        Section {
            Picker("分類", selection: $selectedIndex) {
                Text("無分類").tag(0)
                ForEach(Array(categories.enumerated()), id: \.element.id) { index, category in
                    HStack {
                        Circle()
                            .fill(Color(hex: category.color))
                            .frame(width: 12, height: 12)
                        Text(category.name)
                    }
                    .tag(index + 1)
                }
            }
            .pickerStyle(MenuPickerStyle())
        } header: {
            Text("分類")
        }
    }
}

#Preview {
    @State var selectedIndex = 0
    return Form {
        TodoFormCategorySection(
            categories: [],
            selectedIndex: $selectedIndex
        )
    }
}