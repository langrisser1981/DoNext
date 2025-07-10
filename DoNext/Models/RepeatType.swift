//
//  RepeatType.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import Foundation

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