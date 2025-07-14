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
    
    /// 安全儲存資料並在主執行緒顯示錯誤
    /// - Parameters:
    ///   - errorMessage: 儲存失敗時要顯示的錯誤訊息
    ///   - showAlert: 是否顯示用戶友好的錯誤提示
    ///   - onError: 可選的錯誤處理回調
    /// - Returns: 是否儲存成功
    @MainActor
    @discardableResult
    func safeSaveWithAlert(
        errorMessage: String = "儲存失敗",
        showAlert: Bool = false,
        onError: ((Error) -> Void)? = nil
    ) -> Bool {
        do {
            try save()
            return true
        } catch {
            let fullMessage = "\(errorMessage): \(error)"
            print(fullMessage)
            
            if showAlert {
                // 這裡可以整合 AppCoordinator 顯示錯誤 Alert
                // 或者使用通知中心發送錯誤事件
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
    @discardableResult
    func saveTodoItem(errorMessage: String = "儲存待辦事項失敗") -> Bool {
        return safeSave(errorMessage: errorMessage)
    }
    
    /// 儲存分類
    @discardableResult
    func saveCategory(errorMessage: String = "儲存分類失敗") -> Bool {
        return safeSave(errorMessage: errorMessage)
    }
    
    /// 刪除待辦事項
    @discardableResult
    func deleteTodoItem(errorMessage: String = "刪除待辦事項失敗") -> Bool {
        return safeSave(errorMessage: errorMessage)
    }
    
    /// 刪除分類
    @discardableResult
    func deleteCategory(errorMessage: String = "刪除分類失敗") -> Bool {
        return safeSave(errorMessage: errorMessage)
    }
    
    /// 更新待辦事項
    @discardableResult
    func updateTodoItem(errorMessage: String = "更新待辦事項失敗") -> Bool {
        return safeSave(errorMessage: errorMessage)
    }
    
    /// 更新分類
    @discardableResult
    func updateCategory(errorMessage: String = "更新分類失敗") -> Bool {
        return safeSave(errorMessage: errorMessage)
    }
}