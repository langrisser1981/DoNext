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
                titleSection
                categorySection
                reminderSection
                if reminderEnabled {
                    repeatSection
                }
            }
            .navigationTitle("新增待辦事項")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("儲存") {
                        saveTodo()
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            setupInitialState()
        }
    }
    
    /// 標題輸入區域
    private var titleSection: some View {
        Section {
            TextField("輸入待辦事項", text: $title)
                .font(.body)
        } header: {
            Text("標題")
        }
    }
    
    /// 分類選擇區域
    private var categorySection: some View {
        Section {
            Picker("分類", selection: $selectedCategoryIndex) {
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
    
    /// 提醒設定區域
    private var reminderSection: some View {
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
    
    /// 重複設定區域
    private var repeatSection: some View {
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