//
//  AuthenticationStrategy.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import Foundation

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