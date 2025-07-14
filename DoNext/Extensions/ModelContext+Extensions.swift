//
//  ModelContext+Extensions.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/14.
//

import SwiftData
import Foundation
import os.log

extension ModelContext {
    
    /// Logger 實例
    private static let logger = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DoNext", category: "ModelContext")
    
    /// 安全儲存資料並處理錯誤
    /// - Parameters:
    ///   - errorMessage: 儲存失敗時要顯示的錯誤訊息
    ///   - appCoordinator: 應用程式座標器（可選，用於顯示錯誤）
    ///   - onError: 可選的錯誤處理回調
    /// - Returns: 是否儲存成功
    @MainActor
    @discardableResult
    func safeSave(
        errorMessage: String = "儲存失敗",
        appCoordinator: AppCoordinator? = nil,
        onError: ((Error) -> Void)? = nil
    ) -> Bool {
        do {
            try save()
            return true
        } catch {
            // 記錄錯誤到 Logger
            Self.logger.error("\(errorMessage): \(error.localizedDescription)")
            
            // 如果提供了 AppCoordinator，顯示 Alert
            if let coordinator = appCoordinator {
                let userMessage = "\(errorMessage): \(error.localizedDescription)"
                coordinator.presentAlert(.error(message: userMessage))
            }
            
            onError?(error)
            return false
        }
    }
}

// MARK: - 便利方法

extension ModelContext {
    
    /// 儲存待辦事項
    @MainActor
    @discardableResult
    func saveTodoItem(appCoordinator: AppCoordinator? = nil) -> Bool {
        return safeSave(errorMessage: "儲存待辦事項失敗", appCoordinator: appCoordinator)
    }
    
    /// 儲存分類
    @MainActor
    @discardableResult
    func saveCategory(appCoordinator: AppCoordinator? = nil) -> Bool {
        return safeSave(errorMessage: "儲存分類失敗", appCoordinator: appCoordinator)
    }
    
    /// 刪除待辦事項
    @MainActor
    @discardableResult
    func deleteTodoItem(appCoordinator: AppCoordinator? = nil) -> Bool {
        return safeSave(errorMessage: "刪除待辦事項失敗", appCoordinator: appCoordinator)
    }
    
    /// 刪除分類
    @MainActor
    @discardableResult
    func deleteCategory(appCoordinator: AppCoordinator? = nil) -> Bool {
        return safeSave(errorMessage: "刪除分類失敗", appCoordinator: appCoordinator)
    }
    
    /// 更新待辦事項
    @MainActor
    @discardableResult
    func updateTodoItem(appCoordinator: AppCoordinator? = nil) -> Bool {
        return safeSave(errorMessage: "更新待辦事項失敗", appCoordinator: appCoordinator)
    }
    
    /// 更新分類
    @MainActor
    @discardableResult
    func updateCategory(appCoordinator: AppCoordinator? = nil) -> Bool {
        return safeSave(errorMessage: "更新分類失敗", appCoordinator: appCoordinator)
    }
}