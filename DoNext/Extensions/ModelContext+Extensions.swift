//
//  ModelContext+Extensions.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/14.
//

import SwiftData
import Foundation

extension ModelContext {
    
    /// 安全儲存資料並處理錯誤
    /// - Parameters:
    ///   - errorMessage: 儲存失敗時要顯示的錯誤訊息
    ///   - onError: 可選的錯誤處理回調
    /// - Returns: 是否儲存成功
    @discardableResult
    func safeSave(errorMessage: String = "儲存失敗", onError: ((Error) -> Void)? = nil) -> Bool {
        do {
            try save()
            return true
        } catch {
            print("\(errorMessage): \(error)")
            onError?(error)
            return false
        }
    }
    
    /// 安全儲存資料並透過 AppCoordinator 顯示錯誤
    /// - Parameters:
    ///   - errorMessage: 儲存失敗時要顯示的錯誤訊息
    ///   - appCoordinator: 應用程式座標器（可選，用於顯示錯誤）
    ///   - onError: 可選的錯誤處理回調
    /// - Returns: 是否儲存成功
    @MainActor
    @discardableResult
    func safeSaveWithAlert(
        errorMessage: String = "儲存失敗",
        appCoordinator: AppCoordinator? = nil,
        onError: ((Error) -> Void)? = nil
    ) -> Bool {
        do {
            try save()
            return true
        } catch {
            let fullMessage = "\(errorMessage): \(error.localizedDescription)"
            print("\(errorMessage): \(error)")
            
            // 如果提供了 AppCoordinator，使用它顯示錯誤
            if let coordinator = appCoordinator {
                coordinator.presentAlert(.error(message: fullMessage))
            } else {
                // 否則使用通知中心發送錯誤事件
                NotificationCenter.default.post(
                    name: .modelContextSaveError,
                    object: fullMessage
                )
            }
            
            onError?(error)
            return false
        }
    }
}

// MARK: - 通知擴展

extension Notification.Name {
    /// ModelContext 儲存錯誤通知
    static let modelContextSaveError = Notification.Name("ModelContextSaveError")
}

// MARK: - 便利方法

extension ModelContext {
    
    /// 儲存待辦事項
    @MainActor
    @discardableResult
    func saveTodoItem(
        errorMessage: String = "儲存待辦事項失敗",
        appCoordinator: AppCoordinator? = nil
    ) -> Bool {
        if let coordinator = appCoordinator {
            return safeSaveWithAlert(errorMessage: errorMessage, appCoordinator: coordinator)
        } else {
            return safeSave(errorMessage: errorMessage)
        }
    }
    
    /// 儲存分類
    @MainActor
    @discardableResult
    func saveCategory(
        errorMessage: String = "儲存分類失敗",
        appCoordinator: AppCoordinator? = nil
    ) -> Bool {
        if let coordinator = appCoordinator {
            return safeSaveWithAlert(errorMessage: errorMessage, appCoordinator: coordinator)
        } else {
            return safeSave(errorMessage: errorMessage)
        }
    }
    
    /// 刪除待辦事項
    @MainActor
    @discardableResult
    func deleteTodoItem(
        errorMessage: String = "刪除待辦事項失敗",
        appCoordinator: AppCoordinator? = nil
    ) -> Bool {
        if let coordinator = appCoordinator {
            return safeSaveWithAlert(errorMessage: errorMessage, appCoordinator: coordinator)
        } else {
            return safeSave(errorMessage: errorMessage)
        }
    }
    
    /// 刪除分類
    @MainActor
    @discardableResult
    func deleteCategory(
        errorMessage: String = "刪除分類失敗",
        appCoordinator: AppCoordinator? = nil
    ) -> Bool {
        if let coordinator = appCoordinator {
            return safeSaveWithAlert(errorMessage: errorMessage, appCoordinator: coordinator)
        } else {
            return safeSave(errorMessage: errorMessage)
        }
    }
    
    /// 更新待辦事項
    @MainActor
    @discardableResult
    func updateTodoItem(
        errorMessage: String = "更新待辦事項失敗",
        appCoordinator: AppCoordinator? = nil
    ) -> Bool {
        if let coordinator = appCoordinator {
            return safeSaveWithAlert(errorMessage: errorMessage, appCoordinator: coordinator)
        } else {
            return safeSave(errorMessage: errorMessage)
        }
    }
    
    /// 更新分類
    @MainActor
    @discardableResult
    func updateCategory(
        errorMessage: String = "更新分類失敗",
        appCoordinator: AppCoordinator? = nil
    ) -> Bool {
        if let coordinator = appCoordinator {
            return safeSaveWithAlert(errorMessage: errorMessage, appCoordinator: coordinator)
        } else {
            return safeSave(errorMessage: errorMessage)
        }
    }
}