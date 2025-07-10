//
//  TodoDetailView.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI

/// 待辦事項詳情視圖
struct TodoDetailView: View {
    let todoItem: TodoItem
    
    var body: some View {
        VStack {
            Text("待辦事項詳情")
                .font(.title)
            
            Text(todoItem.title)
                .font(.headline)
            
            Text("建立時間: \(todoItem.createdAt, style: .date)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .navigationTitle("詳情")
        .navigationBarTitleDisplayMode(.inline)
    }
}