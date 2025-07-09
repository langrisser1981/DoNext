//
//  DoNextTests.swift
//  DoNextTests
//
//  Created by Lenny Cheng on 2025/7/9.
//

import Testing
import SwiftData
import Foundation
@testable import DoNext

/// DoNext 應用程式測試
/// 包含資料模型和核心功能的單元測試
struct DoNextTests {

    /// 測試 TodoItem 模型的基本功能
    @Test func testTodoItemCreation() async throws {
        let todo = TodoItem(title: "測試待辦事項")
        
        #expect(todo.title == "測試待辦事項")
        #expect(todo.isCompleted == false)
        #expect(todo.repeatType == .none)
        #expect(todo.reminderDate == nil)
        #expect(todo.category == nil)
    }
    
    /// 測試 TodoItem 的狀態切換功能
    @Test func testTodoItemToggleCompleted() async throws {
        let todo = TodoItem(title: "測試待辦事項")
        
        // 初始狀態應該是未完成
        #expect(todo.isCompleted == false)
        
        // 切換為完成狀態
        todo.toggleCompleted()
        #expect(todo.isCompleted == true)
        
        // 再次切換回未完成狀態
        todo.toggleCompleted()
        #expect(todo.isCompleted == false)
    }
    
    /// 測試 TodoItem 的提醒設定功能
    @Test func testTodoItemSetReminder() async throws {
        let todo = TodoItem(title: "測試待辦事項")
        let reminderDate = Date().addingTimeInterval(3600) // 1小時後
        
        // 設定提醒
        todo.setReminder(date: reminderDate, repeatType: .daily)
        
        #expect(todo.reminderDate == reminderDate)
        #expect(todo.repeatType == .daily)
        
        // 清除提醒
        todo.setReminder(date: nil, repeatType: .none)
        
        #expect(todo.reminderDate == nil)
        #expect(todo.repeatType == .none)
    }
    
    /// 測試 Category 模型的基本功能
    @Test func testCategoryCreation() async throws {
        let category = Category(name: "工作", color: "#FF0000")
        
        #expect(category.name == "工作")
        #expect(category.color == "#FF0000")
        #expect(category.todos.isEmpty)
    }
    
    /// 測試 RepeatType 枚舉的顯示名稱
    @Test func testRepeatTypeDisplayNames() async throws {
        #expect(RepeatType.none.displayName == "不重複")
        #expect(RepeatType.daily.displayName == "每日")
        #expect(RepeatType.weekly.displayName == "每週")
        #expect(RepeatType.monthly.displayName == "每月")
        #expect(RepeatType.yearly.displayName == "每年")
    }
    
    /// 測試 AppState 的初始狀態
    @Test func testAppStateInitialState() async throws {
        let appState = AppState()
        
        #expect(appState.currentState == .onboarding)
        #expect(appState.hasCompletedOnboarding == false)
        #expect(appState.isLoggedIn == false)
        #expect(appState.currentUser == nil)
    }
    
    /// 測試 AppState 的引導流程完成
    @Test func testAppStateCompleteOnboarding() async throws {
        let appState = AppState()
        
        appState.completeOnboarding()
        
        #expect(appState.hasCompletedOnboarding == true)
        #expect(appState.currentState == .login)
    }

}
