//
//  TodoDetailView.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI

/// 待辦事項詳情視圖
struct TodoDetailView: View {
    @Environment(AppCoordinator.self) var appCoordinator
    let todoItem: TodoItem
    
    private var homeCoordinator: HomeCoordinator? {
        appCoordinator.children.first { $0 is HomeCoordinator } as? HomeCoordinator
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // 標題
            VStack(alignment: .leading, spacing: 8) {
                Text("標題")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(todoItem.title)
                    .font(.title2)
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            // 分類
            if let category = todoItem.category {
                VStack(alignment: .leading, spacing: 8) {
                    Text("分類")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Circle()
                            .fill(Color(hex: category.color))
                            .frame(width: 12, height: 12)
                        Text(category.name)
                            .font(.body)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            
            // 提醒時間
            if let reminderDate = todoItem.reminderDate {
                VStack(alignment: .leading, spacing: 8) {
                    Text("提醒時間")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "bell")
                            .foregroundColor(.orange)
                        Text(reminderDate, style: .date)
                        Text(reminderDate, style: .time)
                    }
                    .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            
            // 重複設定
            if todoItem.repeatType != .none {
                VStack(alignment: .leading, spacing: 8) {
                    Text("重複")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    HStack(spacing: 8) {
                        Image(systemName: "repeat")
                            .foregroundColor(.blue)
                        Text(todoItem.repeatType.displayName)
                    }
                    .font(.body)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            }
            
            // 完成狀態
            VStack(alignment: .leading, spacing: 8) {
                Text("狀態")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                HStack(spacing: 8) {
                    Image(systemName: todoItem.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(todoItem.isCompleted ? .green : .gray)
                    Text(todoItem.isCompleted ? "已完成" : "待完成")
                        .font(.body)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            // 建立時間
            VStack(alignment: .leading, spacing: 8) {
                Text("建立時間")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(todoItem.createdAt, style: .date)
                    .font(.body)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)
            
            Spacer()
        }
        .navigationTitle("待辦事項詳情")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button("編輯") {
                    homeCoordinator?.showTodoEdit(todoItem)
                }
            }
        }
    }
}