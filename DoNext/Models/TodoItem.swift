//
//  TodoItem.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import Foundation
import SwiftData

/// 待辦事項模型
/// 使用 SwiftData 進行持久化存儲，包含完整的待辦事項屬性和操作方法
/// 支援 iCloud CloudKit 同步
@Model
final class TodoItem {
    /// 待辦事項的唯一識別符
    var id: UUID
    
    /// 待辦事項的標題/主旨
    var title: String
    
    /// 是否已完成
    var isCompleted: Bool
    
    /// 建立時間
    var createdAt: Date
    
    /// 最後更新時間
    var updatedAt: Date
    
    /// 提醒時間（可選）
    var reminderDate: Date?
    
    /// 重複類型
    var repeatType: RepeatType
    
    /// 所屬分類（可選）
    var category: Category?
    
    /// 初始化待辦事項
    /// - Parameters:
    ///   - title: 待辦事項標題
    ///   - category: 所屬分類（可選）
    init(title: String, category: Category? = nil) {
        self.id = UUID()
        self.title = title
        self.isCompleted = false
        self.createdAt = Date()
        self.updatedAt = Date()
        self.reminderDate = nil
        self.repeatType = .none
        self.category = category
    }
    
    /// 更新待辦事項標題
    /// - Parameter newTitle: 新的標題
    func updateTitle(_ newTitle: String) {
        self.title = newTitle
        self.updatedAt = Date()
    }
    
    /// 切換完成狀態
    func toggleCompleted() {
        self.isCompleted.toggle()
        self.updatedAt = Date()
    }
    
    /// 設定提醒
    /// - Parameters:
    ///   - date: 提醒時間（nil 表示取消提醒）
    ///   - repeatType: 重複類型，預設為不重複
    func setReminder(date: Date?, repeatType: RepeatType = .none) {
        self.reminderDate = date
        self.repeatType = repeatType
        self.updatedAt = Date()
    }
}