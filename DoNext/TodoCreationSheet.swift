//
//  TodoCreationSheet.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI
import SwiftData

/// 待辦事項創建表單
/// 提供新增待辦事項的完整功能，包括標題、分類、提醒時間和重複設定
struct TodoCreationSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var categories: [Category]
    
    /// 預設選中的分類
    let selectedCategory: Category?
    
    // 表單狀態
    @State private var title = ""
    @State private var selectedCategoryIndex = 0
    @State private var hasReminder = false
    @State private var reminderDate = Date()
    @State private var repeatType = RepeatType.none
    @State private var showingDatePicker = false
    
    /// 是否可以創建待辦事項
    private var canCreateTodo: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// 選中的分類
    private var chosenCategory: Category? {
        guard selectedCategoryIndex > 0 && selectedCategoryIndex <= categories.count else {
            return nil
        }
        return categories[selectedCategoryIndex - 1]
    }
    
    var body: some View {
        NavigationView {
            Form {
                // 標題輸入區段
                titleSection
                
                // 分類選擇區段
                categorySection
                
                // 提醒設定區段
                reminderSection
                
                // 重複設定區段
                if hasReminder {
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
                    Button("完成") {
                        createTodo()
                    }
                    .disabled(!canCreateTodo)
                }
            }
        }
        .onAppear {
            setupInitialState()
        }
    }
    
    /// 標題輸入區段
    private var titleSection: some View {
        Section {
            TextField("請輸入待辦事項標題", text: $title)
                .textFieldStyle(PlainTextFieldStyle())
        } header: {
            Text("標題")
        }
    }
    
    /// 分類選擇區段
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
    
    /// 提醒設定區段
    private var reminderSection: some View {
        Section {
            Toggle("設定提醒", isOn: $hasReminder)
                .onChange(of: hasReminder) { _, newValue in
                    if !newValue {
                        repeatType = .none
                    }
                }
            
            if hasReminder {
                Button(action: {
                    showingDatePicker = true
                }) {
                    HStack {
                        Image(systemName: "calendar")
                            .foregroundColor(.blue)
                        
                        Text("提醒時間")
                            .foregroundColor(.primary)
                        
                        Spacer()
                        
                        Text(reminderDate, style: .date)
                            .foregroundColor(.secondary)
                        
                        Text(reminderDate, style: .time)
                            .foregroundColor(.secondary)
                    }
                }
                .sheet(isPresented: $showingDatePicker) {
                    DatePickerSheet(selectedDate: $reminderDate)
                }
            }
        } header: {
            Text("提醒設定")
        }
    }
    
    /// 重複設定區段
    private var repeatSection: some View {
        Section {
            Picker("重複頻率", selection: $repeatType) {
                ForEach(RepeatType.allCases, id: \.self) { type in
                    Text(type.displayName).tag(type)
                }
            }
            .pickerStyle(MenuPickerStyle())
        } header: {
            Text("重複設定")
        }
    }
    
    /// 設定初始狀態
    private func setupInitialState() {
        if let selectedCategory = selectedCategory,
           let index = categories.firstIndex(where: { $0.id == selectedCategory.id }) {
            selectedCategoryIndex = index + 1
        }
    }
    
    /// 創建待辦事項
    private func createTodo() {
        let newTodo = TodoItem(title: title.trimmingCharacters(in: .whitespacesAndNewlines))
        
        // 設定分類
        if let chosenCategory = chosenCategory {
            newTodo.category = chosenCategory
        }
        
        // 設定提醒
        if hasReminder {
            newTodo.setReminder(date: reminderDate, repeatType: repeatType)
        }
        
        // 保存到 SwiftData
        modelContext.insert(newTodo)
        
        // 如果有分類，更新分類的待辦事項列表
        if let chosenCategory = chosenCategory {
            chosenCategory.todos.append(newTodo)
        }
        
        dismiss()
    }
}

/// 日期選擇器表單
/// 提供日期和時間選擇的完整界面
struct DatePickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker(
                    "選擇提醒時間",
                    selection: $selectedDate,
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .padding()
                
                Spacer()
            }
            .navigationTitle("選擇提醒時間")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}


// MARK: - 預覽

#Preview {
    TodoCreationSheet(selectedCategory: nil)
        .modelContainer(for: [TodoItem.self, Category.self], inMemory: true)
}