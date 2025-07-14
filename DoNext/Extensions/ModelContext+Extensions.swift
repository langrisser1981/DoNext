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
    ///   - operation: 操作名稱，用於錯誤記錄
    ///   - onError: 可選的錯誤處理回調
    /// - Returns: 是否儲存成功
    @discardableResult
    func safeSave(
        operation: String = "儲存",
        onError: ((Error, String) -> Void)? = nil
    ) -> Bool {
        do {
            try save()
            return true
        } catch {
            let errorMessage = "\(operation)失敗"
            
            // 記錄錯誤到 Logger
            Self.logger.error("\(errorMessage): \(error.localizedDescription)")
            
            // 呼叫錯誤處理回調，讓外部決定如何處理
            onError?(error, errorMessage)
            
            return false
        }
    }
}

// MARK: - 便利方法

extension ModelContext {
    
    /// 儲存待辦事項
    @discardableResult
    func saveTodoItem(onError: ((Error, String) -> Void)? = nil) -> Bool {
        return safeSave(operation: "儲存待辦事項", onError: onError)
    }
    
    /// 儲存分類
    @discardableResult
    func saveCategory(onError: ((Error, String) -> Void)? = nil) -> Bool {
        return safeSave(operation: "儲存分類", onError: onError)
    }
    
    /// 刪除待辦事項
    @discardableResult
    func deleteTodoItem(onError: ((Error, String) -> Void)? = nil) -> Bool {
        return safeSave(operation: "刪除待辦事項", onError: onError)
    }
    
    /// 刪除分類
    @discardableResult
    func deleteCategory(onError: ((Error, String) -> Void)? = nil) -> Bool {
        return safeSave(operation: "刪除分類", onError: onError)
    }
    
    /// 更新待辦事項
    @discardableResult
    func updateTodoItem(onError: ((Error, String) -> Void)? = nil) -> Bool {
        return safeSave(operation: "更新待辦事項", onError: onError)
    }
    
    /// 更新分類
    @discardableResult
    func updateCategory(onError: ((Error, String) -> Void)? = nil) -> Bool {
        return safeSave(operation: "更新分類", onError: onError)
    }
}