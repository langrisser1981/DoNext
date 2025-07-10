//
//  HomeViewModel.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import Foundation
import SwiftData
import Observation

/// 主頁面 ViewModel
/// 管理主頁面的業務邏輯和狀態
@Observable
@MainActor
final class HomeViewModel {
    /// 搜索文字
    var searchText = ""
    
    /// 選中的分類索引
    var selectedCategoryIndex = 0
    
    /// 過濾待辦事項
    /// - Parameters:
    ///   - todos: 原始待辦事項列表
    ///   - categories: 分類列表
    /// - Returns: 過濾後的待辦事項
    func filteredTodos(from todos: [TodoItem], categories: [Category]) -> [TodoItem] {
        var filteredTodos: [TodoItem]
        
        // 根據選中的分類過濾
        if selectedCategoryIndex == 0 {
            filteredTodos = todos
        } else if selectedCategoryIndex > 0 && selectedCategoryIndex <= categories.count {
            let selectedCategory = categories[selectedCategoryIndex - 1]
            filteredTodos = selectedCategory.todos
        } else {
            filteredTodos = todos
        }
        
        // 根據搜索文字過濾
        if !searchText.isEmpty {
            filteredTodos = filteredTodos.filter { 
                $0.title.localizedCaseInsensitiveContains(searchText) 
            }
        }
        
        // 按建立時間排序
        return filteredTodos.sorted { $0.createdAt > $1.createdAt }
    }
    
    /// 獲取當前選中的分類
    /// - Parameter categories: 分類列表
    /// - Returns: 當前選中的分類（如果有的話）
    func selectedCategory(from categories: [Category]) -> Category? {
        guard selectedCategoryIndex > 0 && selectedCategoryIndex <= categories.count else {
            return nil
        }
        return categories[selectedCategoryIndex - 1]
    }
    
    /// 清除搜索
    func clearSearch() {
        searchText = ""
    }
    
    /// 選擇分類
    /// - Parameter index: 分類索引
    func selectCategory(at index: Int) {
        selectedCategoryIndex = index
    }
}