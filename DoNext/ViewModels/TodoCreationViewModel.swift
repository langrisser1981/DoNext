//
//  TodoCreationViewModel.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import Foundation
import SwiftData
import Observation

/// 模型相關錯誤
enum ModelError: Error {
    case saveFailed
}

/// 待辦事項創建 ViewModel
/// 管理待辦事項創建表單的狀態和業務邏輯
@Observable
@MainActor
final class TodoCreationViewModel {
    /// 待辦事項標題
    var title = ""
    
    /// 選中的分類索引
    var selectedCategoryIndex = 0
    
    /// 是否啟用提醒
    var reminderEnabled = false
    
    /// 提醒時間
    var reminderDate = Date()
    
    /// 重複類型
    var repeatType = RepeatType.none
    
    /// 表單是否有效
    var isValid: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    /// 設定預選分類
    /// - Parameters:
    ///   - category: 預選的分類
    ///   - categories: 所有分類列表
    func setPreselectedCategory(_ category: Category?, from categories: [Category]) {
        guard let preselectedCategory = category,
              let index = categories.firstIndex(where: { $0.id == preselectedCategory.id }) else {
            return
        }
        selectedCategoryIndex = index + 1
    }
    
    /// 獲取當前選中的分類
    /// - Parameter categories: 分類列表
    /// - Returns: 當前選中的分類（如果有的話）
    func currentCategory(from categories: [Category]) -> Category? {
        guard selectedCategoryIndex > 0 && selectedCategoryIndex <= categories.count else {
            return nil
        }
        return categories[selectedCategoryIndex - 1]
    }
    
    /// 創建待辦事項
    /// - Parameters:
    ///   - categories: 分類列表
    ///   - modelContext: SwiftData 模型上下文
    /// - Returns: 創建的待辦事項
    func createTodo(from categories: [Category], modelContext: ModelContext) throws -> TodoItem {
        let trimmedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedTitle.isEmpty else {
            throw TodoCreationError.emptyTitle
        }
        
        let category = currentCategory(from: categories)
        let newTodo = TodoItem(title: trimmedTitle, category: category)
        
        if reminderEnabled {
            newTodo.setReminder(date: reminderDate, repeatType: repeatType)
        }
        
        modelContext.insert(newTodo)
        
        let success = modelContext.safeSave(operation: "儲存待辦事項") { error, message in
            // 這裡可能需要更好的錯誤處理方式，因為 ViewModel 沒有 AppCoordinator
            print("\(message): \(error.localizedDescription)")
        }
        
        if !success {
            throw ModelError.saveFailed
        }
        
        return newTodo
    }
    
    /// 重置表單
    func reset() {
        title = ""
        selectedCategoryIndex = 0
        reminderEnabled = false
        reminderDate = Date()
        repeatType = .none
    }
}

/// 待辦事項創建錯誤
enum TodoCreationError: Error, LocalizedError {
    case emptyTitle
    
    var errorDescription: String? {
        switch self {
        case .emptyTitle:
            return "待辦事項標題不能為空"
        }
    }
}