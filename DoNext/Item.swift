//
//  Item.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import Foundation
import SwiftData

/// 待辦事項模型
/// 使用 SwiftData 進行持久化存儲，包含完整的待辦事項屬性和操作方法
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

/// 分類模型
/// 用於組織待辦事項，支援顏色標識和層級管理
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

/// 重複提醒類型
/// 定義待辦事項可設定的重複提醒週期
enum RepeatType: String, CaseIterable, Codable {
    case none = "none"
    case daily = "daily"
    case weekly = "weekly"
    case monthly = "monthly"
    case yearly = "yearly"
    
    /// 顯示名稱（中文）
    var displayName: String {
        switch self {
        case .none: return "不重複"
        case .daily: return "每日"
        case .weekly: return "每週"
        case .monthly: return "每月"
        case .yearly: return "每年"
        }
    }
}

// MARK: - Authentication Strategy Protocol

/// 驗證策略協議
/// 使用策略模式實作不同的登入方式（Apple Sign-In、Google Sign-In 等）
protocol AuthenticationStrategy {
    /// 執行登入
    /// - Returns: 驗證結果
    /// - Throws: 登入失敗時拋出錯誤
    func signIn() async throws -> AuthResult
    
    /// 執行登出
    /// - Throws: 登出失敗時拋出錯誤
    func signOut() async throws
    
    /// 當前是否已登入
    var isSignedIn: Bool { get }
}

/// 驗證結果
/// 包含成功登入後的用戶資訊
struct AuthResult {
    /// 用戶唯一識別符
    let userID: String
    
    /// 電子郵件（可選）
    let email: String?
    
    /// 顯示名稱（可選）
    let displayName: String?
}

// MARK: - Authentication Strategies

/// Apple Sign-In 驗證策略
/// 實作 Apple 官方登入服務的驗證流程
class AppleSignInStrategy: AuthenticationStrategy {
    /// 登入狀態
    var isSignedIn: Bool = false
    
    /// 執行 Apple Sign-In 登入
    /// - Returns: 驗證結果
    /// - Throws: 登入失敗時拋出錯誤
    /// - Note: 目前為模擬實作，後續需要整合真實的 Apple Sign-In SDK
    func signIn() async throws -> AuthResult {
        // TODO: 整合真實的 Apple Sign-In 實作
        // 目前返回模擬數據用於開發階段
        isSignedIn = true
        return AuthResult(userID: "apple_user_123", email: "user@example.com", displayName: "Apple User")
    }
    
    /// 執行登出
    /// - Throws: 登出失敗時拋出錯誤
    func signOut() async throws {
        isSignedIn = false
    }
}

/// Google Sign-In 驗證策略
/// 實作 Google 登入服務的驗證流程
class GoogleSignInStrategy: AuthenticationStrategy {
    /// 登入狀態
    var isSignedIn: Bool = false
    
    /// 執行 Google Sign-In 登入
    /// - Returns: 驗證結果
    /// - Throws: 登入失敗時拋出錯誤
    /// - Note: 目前為模擬實作，後續需要整合真實的 Google Sign-In SDK
    func signIn() async throws -> AuthResult {
        // TODO: 整合真實的 Google Sign-In 實作
        // 目前返回模擬數據用於開發階段
        isSignedIn = true
        return AuthResult(userID: "google_user_123", email: "user@gmail.com", displayName: "Google User")
    }
    
    /// 執行登出
    /// - Throws: 登出失敗時拋出錯誤
    func signOut() async throws {
        isSignedIn = false
    }
}
