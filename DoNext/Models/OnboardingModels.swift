//
//  OnboardingModels.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import Foundation

/// 引導頁面資料模型
/// 定義單一引導頁面的內容結構
struct OnboardingPage {
    /// 頁面標題
    let title: String
    
    /// 頁面描述
    let description: String
    
    /// 圖片名稱（可選）
    let imageName: String?
    
    /// 系統圖標名稱（可選，當沒有自定義圖片時使用）
    let systemImage: String?
    
    /// 初始化引導頁面
    /// - Parameters:
    ///   - title: 頁面標題
    ///   - description: 頁面描述
    ///   - imageName: 自定義圖片名稱
    ///   - systemImage: 系統圖標名稱
    init(title: String, description: String, imageName: String? = nil, systemImage: String? = nil) {
        self.title = title
        self.description = description
        self.imageName = imageName
        self.systemImage = systemImage
    }
}

/// 引導頁面配置
/// 包含所有引導頁面的內容配置
struct OnboardingConfiguration {
    /// 引導頁面列表
    /// 可以通過修改此陣列來自定義引導頁面的內容
    static let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "歡迎使用 DoNext",
            description: "一個簡潔且強大的待辦事項管理應用程式，幫助您高效管理日常任務。",
            systemImage: "checkmark.circle.fill"
        ),
        OnboardingPage(
            title: "智能分類管理",
            description: "使用彩色分類標籤來組織您的待辦事項，讓任務管理更加直觀和有序。",
            systemImage: "folder.fill"
        ),
        OnboardingPage(
            title: "提醒與重複",
            description: "設定提醒時間和重複週期，確保重要任務不會被遺忘。",
            systemImage: "bell.fill"
        ),
        OnboardingPage(
            title: "雲端同步",
            description: "所有資料都會自動同步到 iCloud，讓您在任何設備上都能存取您的待辦事項。",
            systemImage: "icloud.fill"
        )
    ]
}