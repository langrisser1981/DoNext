//
//  HomeTodoListContainer.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 首頁待辦事項列表容器元件
/// 管理待辦事項列表的顯示和交互
struct HomeTodoListContainer: View {
    let todos: [TodoItem]
    let onTodoToggle: (TodoItem) -> Void
    let onTodoTap: (TodoItem) -> Void
    let onTodoDelete: (TodoItem) -> Void
    
    var body: some View {
        Group {
            if todos.isEmpty {
                HomeEmptyState()
            } else {
                List {
                    ForEach(todos) { todo in
                        TodoRowView(todo: todo) {
                            onTodoToggle(todo)
                        }
                        .onTapGesture {
                            onTodoTap(todo)
                        }
                        .swipeActions(edge: .trailing) {
                            Button("刪除", role: .destructive) {
                                onTodoDelete(todo)
                            }
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

#Preview {
    HomeTodoListContainer(
        todos: [],
        onTodoToggle: { _ in },
        onTodoTap: { _ in },
        onTodoDelete: { _ in }
    )
}