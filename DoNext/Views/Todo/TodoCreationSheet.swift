//
//  TodoCreationSheet.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI
import SwiftData

/// 待辦事項創建表單
/// 提供新增待辦事項的完整功能，包含標題、分類、提醒設定等
struct TodoCreationSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(NotificationManager.self) var notificationManager
    @Query private var categories: [Category]
    
    /// 預選的分類
    let selectedCategory: Category?
    
    /// 表單狀態
    @State private var title = ""
    @State private var selectedCategoryIndex = 0
    @State private var reminderEnabled = false
    @State private var reminderDate = Date()
    @State private var repeatType = RepeatType.none
    
    /// 當前選中的分類
    private var currentCategory: Category? {
        guard selectedCategoryIndex > 0 && selectedCategoryIndex <= categories.count else {
            return nil
        }
        return categories[selectedCategoryIndex - 1]
    }
    
    var body: some View {
        NavigationView {
            Form {
                TodoFormTitleSection(title: $title)
                
                TodoFormCategorySection(
                    categories: categories,
                    selectedIndex: $selectedCategoryIndex
                )
                
                TodoFormReminderSection(
                    reminderEnabled: $reminderEnabled,
                    reminderDate: $reminderDate
                )
                
                todoFormRepeatSection
            }
            .navigationTitle("新增待辦事項")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                TodoFormToolbarContent(
                    canSave: !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
                    onCancel: { dismiss() },
                    onSave: { saveTodo() }
                )
            }
        }
        .onAppear {
            setupInitialState()
        }
    }
    
    /// 條件顯示的重複設定區段
    @ViewBuilder
    private var todoFormRepeatSection: some View {
        if reminderEnabled {
            TodoFormRepeatSection(repeatType: $repeatType)
        }
    }
    
    /// 設定初始狀態
    private func setupInitialState() {
        if let preselectedCategory = selectedCategory,
           let index = categories.firstIndex(where: { $0.id == preselectedCategory.id }) {
            selectedCategoryIndex = index + 1
        }
    }
    
    /// 儲存待辦事項
    private func saveTodo() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        let newTodo = TodoItem(title: trimmedTitle, category: currentCategory)
        
        if reminderEnabled {
            newTodo.setReminder(date: reminderDate, repeatType: repeatType)
        }
        
        modelContext.insert(newTodo)
        
        do {
            try modelContext.save()
            
            // 如果有設定提醒，排程通知
            if reminderEnabled {
                Task {
                    await notificationManager.scheduleNotification(for: newTodo)
                }
            }
            
            dismiss()
        } catch {
            print("儲存待辦事項失敗: \(error)")
        }
    }
}

#Preview {
    TodoCreationSheet(selectedCategory: nil)
        .modelContainer(for: [TodoItem.self, Category.self], inMemory: true)
}