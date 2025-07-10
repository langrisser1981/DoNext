//
//  Category.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import Foundation
import SwiftData

/// 分類模型
/// 用於組織待辦事項，支援顏色標識和層級管理
/// 支援 iCloud CloudKit 同步
@Model
final class Category {
    /// 分類的唯一識別符
    var id: UUID
    
    /// 分類名稱
    var name: String
    
    /// 分類顏色（16進制色碼字串）
    var color: String
    
    /// 建立時間
    var createdAt: Date
    
    /// 該分類下的所有待辦事項
    var todos: [TodoItem]
    
    /// 初始化分類
    /// - Parameters:
    ///   - name: 分類名稱
    ///   - color: 分類顏色（16進制色碼）
    init(name: String, color: String) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.createdAt = Date()
        self.todos = []
    }
}