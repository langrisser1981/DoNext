//
//  AuthModels.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import Foundation

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

/// 驗證錯誤類型
enum AuthError: Error, LocalizedError {
    case noStrategySet
    
    var errorDescription: String? {
        switch self {
        case .noStrategySet:
            return "未設定驗證策略"
        }
    }
}