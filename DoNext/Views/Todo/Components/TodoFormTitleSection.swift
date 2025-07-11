//
//  TodoFormTitleSection.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 待辦事項表單標題輸入區段元件
/// 提供待辦事項標題的輸入界面
struct TodoFormTitleSection: View {
    @Binding var title: String
    
    var body: some View {
        Section {
            TextField("輸入待辦事項", text: $title)
                .font(.body)
        } header: {
            Text("標題")
        }
    }
}

#Preview {
    @State var title = ""
    return Form {
        TodoFormTitleSection(title: $title)
    }
}