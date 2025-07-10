//
//  SettingsManager.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/10.
//

import Foundation
import Observation

/// 設定管理器
/// 負責管理用戶偏好設定和應用程式配置
@Observable
@MainActor
final class SettingsManager {
    /// 單例實例
    static let shared = SettingsManager()
    
    /// 是否啟用 iCloud 同步
    var isCloudSyncEnabled: Bool {
        didSet {
            UserDefaults.standard.set(isCloudSyncEnabled, forKey: Keys.cloudSyncEnabled)
        }
    }
    
    /// 是否顯示 iCloud 設定選項
    var shouldShowCloudSyncOption: Bool = false
    
    private init() {
        // 從 UserDefaults 讀取設定
        self.isCloudSyncEnabled = UserDefaults.standard.bool(forKey: Keys.cloudSyncEnabled)
    }
    
    /// 重置所有設定到預設值
    func resetToDefaults() {
        isCloudSyncEnabled = false
        shouldShowCloudSyncOption = false
    }
    
    /// 設定 iCloud 同步可用性
    /// - Parameter available: 是否可用
    func setCloudSyncAvailability(_ available: Bool) {
        shouldShowCloudSyncOption = available
        
        // 如果 iCloud 不可用但用戶之前啟用了同步，自動關閉
        if !available && isCloudSyncEnabled {
            isCloudSyncEnabled = false
        }
    }
}

// MARK: - UserDefaults Keys
private extension SettingsManager {
    enum Keys {
        static let cloudSyncEnabled = "CloudSyncEnabled"
    }
}