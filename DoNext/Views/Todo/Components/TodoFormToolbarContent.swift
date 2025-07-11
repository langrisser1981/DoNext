//
//  TodoFormToolbarContent.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 待辦事項表單工具欄內容元件
/// 提供取消和儲存按鈕
struct TodoFormToolbarContent {
    let canSave: Bool
    let onCancel: () -> Void
    let onSave: () -> Void
}

extension TodoFormToolbarContent: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button("取消") {
                onCancel()
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button("儲存") {
                onSave()
            }
            .disabled(!canSave)
        }
    }
}