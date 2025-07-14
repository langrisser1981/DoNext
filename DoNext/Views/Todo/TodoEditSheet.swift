//
//  TodoEditSheet.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI
import SwiftData

/// 待辦事項編輯表單
/// 提供編輯現有待辦事項的完整功能，包含標題、分類、提醒設定等
struct TodoEditSheet: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Environment(NotificationManager.self) var notificationManager
    @Environment(AppCoordinator.self) var appCoordinator
    @Query private var categories: [Category]
    
    /// 要編輯的待辦事項
    let todoItem: TodoItem
    
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
                TodoFormTitleSection(
                    title: $title,
                    onVoiceInputComplete: { parsedData in
                        applyVoiceInputData(parsedData)
                    }
                )
                
                TodoFormCategorySection(
                    categories: categories,
                    selectedIndex: $selectedCategoryIndex
                )
                
                TodoFormReminderSection(
                    reminderEnabled: $reminderEnabled,
                    reminderDate: $reminderDate
                )
                
                TodoFormRepeatSection(
                    repeatType: $repeatType
                )
            }
            .navigationTitle("編輯待辦事項")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("儲存") {
                        saveTodoItem()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            initializeFormData()
        }
    }
    
    /// 初始化表單數據
    private func initializeFormData() {
        title = todoItem.title
        
        // 設定分類選擇
        if let category = todoItem.category,
           let index = categories.firstIndex(of: category) {
            selectedCategoryIndex = index + 1 // +1 因為 0 是 "無分類"
        } else {
            selectedCategoryIndex = 0 // 無分類
        }
        
        // 設定提醒
        if let reminderDate = todoItem.reminderDate {
            reminderEnabled = true
            self.reminderDate = reminderDate
        } else {
            reminderEnabled = false
            self.reminderDate = Date()
        }
        
        // 設定重複類型
        repeatType = todoItem.repeatType
    }
    
    /// 套用語音輸入解析結果
    private func applyVoiceInputData(_ parsedData: ParsedTodoData) {
        // 應用解析的標題
        if !parsedData.title.isEmpty {
            title = parsedData.title
        }
        
        // 應用建議的分類
        if let suggestedCategory = parsedData.suggestedCategory {
            if let categoryIndex = categories.firstIndex(where: { $0.name == suggestedCategory }) {
                selectedCategoryIndex = categoryIndex + 1 // +1 因為第一個選項是「無分類」
            }
        }
        
        // 應用提醒設定
        if parsedData.hasReminder {
            reminderEnabled = true
            if let reminderDate = parsedData.reminderDate {
                self.reminderDate = reminderDate
            }
            repeatType = parsedData.repeatType
        }
    }
    
    /// 儲存待辦事項
    private func saveTodoItem() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else { return }
        
        // 更新待辦事項
        todoItem.title = trimmedTitle
        todoItem.category = currentCategory
        todoItem.reminderDate = reminderEnabled ? reminderDate : nil
        todoItem.repeatType = reminderEnabled ? repeatType : .none
        
        let success = modelContext.updateTodoItem { error, message in
            appCoordinator.presentAlert(.error(message: "\(message): \(error.localizedDescription)"))
        }
        
        if success {
            // 處理通知
            Task {
                // 先移除舊的通知
                await notificationManager.removeNotification(for: todoItem)
                
                // 如果設定了提醒且未完成，重新排程通知
                if todoItem.reminderDate != nil && !todoItem.isCompleted {
                    await notificationManager.scheduleNotification(for: todoItem)
                }
            }
            
            dismiss()
        }
    }
}

#Preview {
    @Previewable @State var todoItem: TodoItem = {
        let category = Category(name: "工作", color: "#FF6B6B")
        let item = TodoItem(title: "範例待辦事項", category: category)
        item.reminderDate = Date()
        item.repeatType = RepeatType.daily
        return item
    }()
    
    TodoEditSheet(todoItem: todoItem)
        .modelContainer(for: [TodoItem.self, Category.self], inMemory: true)
        .environment(NotificationManager.shared)
}