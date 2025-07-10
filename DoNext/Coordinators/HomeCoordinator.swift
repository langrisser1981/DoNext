//
//  HomeCoordinator.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI
import Observation

/// 主頁面導航目標
enum HomeDestination: Hashable {
    case todoDetail(todoItem: TodoItem)
    case settings
}

/// 主頁面座標器
/// 管理主頁面相關的導航流程
@Observable
@MainActor
final class HomeCoordinator: BaseCoordinator {
    weak var appCoordinator: AppCoordinator?
    
    override func start() {
        // 主頁面座標器啟動時不需要特別的初始化
    }
    
    // MARK: - Navigation Methods
    
    /// 顯示待辦事項詳情
    func showTodoDetail(_ todoItem: TodoItem) {
        push(HomeDestination.todoDetail(todoItem: todoItem))
    }
    
    /// 顯示設定頁面
    func showSettings() {
        push(HomeDestination.settings)
    }
    
    /// 顯示新增待辦事項 Sheet
    func showTodoCreation(selectedCategory: Category? = nil) {
        appCoordinator?.presentSheet(.todoCreation(selectedCategory: selectedCategory))
    }
    
    /// 顯示新增分類 Sheet
    func showCategoryCreation() {
        appCoordinator?.presentSheet(.categoryCreation)
    }
    
    /// 顯示待辦事項詳情 Sheet
    func showTodoDetailSheet(_ todoItem: TodoItem) {
        appCoordinator?.presentSheet(.todoDetail(todoItem: todoItem))
    }
    
    /// 顯示設定 Sheet
    func showSettingsSheet() {
        appCoordinator?.presentSheet(.settings)
    }
    
    // MARK: - Alert Methods
    
    /// 顯示登出確認 Alert
    func showSignOutConfirmation() {
        appCoordinator?.presentAlert(.signOutConfirmation)
    }
    
    /// 顯示刪除確認 Alert
    func showDeleteConfirmation(for item: TodoItem) {
        appCoordinator?.presentAlert(.deleteConfirmation(item: item))
    }
    
    /// 顯示錯誤 Alert
    func showError(message: String) {
        appCoordinator?.presentAlert(.error(message: message))
    }
    
    // MARK: - User Actions
    
    /// 執行登出
    func signOut() async {
        do {
            try await appCoordinator?.signOut()
        } catch {
            showError(message: error.localizedDescription)
        }
    }
}