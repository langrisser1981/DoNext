//
//  CloudKitManager.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/10.
//

import Foundation
import CloudKit
import SwiftData
import Observation

/// iCloud CloudKit 同步管理器
/// 負責監控和管理 CloudKit 同步狀態
@Observable
@MainActor
final class CloudKitManager {
    /// 單例實例
    static let shared = CloudKitManager()
    
    /// CloudKit 同步狀態
    var syncStatus: SyncStatus = .unknown
    
    /// 同步錯誤訊息
    var errorMessage: String?
    
    /// CloudKit 容器
    private let container = CKContainer(identifier: "iCloud.com.lenny.DoNext")
    
    private init() {
        Task {
            await checkAccountStatus()
        }
    }
    
    /// 檢查 iCloud 帳號狀態
    func checkAccountStatus() async {
        do {
            let status = try await container.accountStatus()
            
            switch status {
            case .available:
                syncStatus = .available
                errorMessage = nil
            case .noAccount:
                syncStatus = .noAccount
                errorMessage = "請在設定中登入 iCloud 帳號以啟用資料同步"
            case .restricted:
                syncStatus = .restricted
                errorMessage = "iCloud 帳號受限，無法使用同步功能"
            case .couldNotDetermine:
                syncStatus = .unknown
                errorMessage = "無法確定 iCloud 帳號狀態"
            case .temporarilyUnavailable:
                syncStatus = .temporarilyUnavailable
                errorMessage = "iCloud 服務暫時無法使用"
            @unknown default:
                syncStatus = .unknown
                errorMessage = "未知的 iCloud 帳號狀態"
            }
        } catch {
            syncStatus = .error
            errorMessage = "檢查 iCloud 帳號狀態時發生錯誤：\(error.localizedDescription)"
        }
    }
    
    /// 手動觸發同步檢查
    func refreshSyncStatus() async {
        await checkAccountStatus()
    }
}

/// CloudKit 同步狀態
enum SyncStatus {
    case unknown
    case available
    case noAccount
    case restricted
    case temporarilyUnavailable
    case error
    
    /// 狀態顯示文字
    var displayText: String {
        switch self {
        case .unknown:
            return "檢查中..."
        case .available:
            return "iCloud 同步已啟用"
        case .noAccount:
            return "未登入 iCloud"
        case .restricted:
            return "iCloud 受限"
        case .temporarilyUnavailable:
            return "iCloud 暫時無法使用"
        case .error:
            return "同步錯誤"
        }
    }
    
    /// 狀態圖示
    var systemImage: String {
        switch self {
        case .unknown:
            return "questionmark.circle"
        case .available:
            return "icloud.fill"
        case .noAccount:
            return "icloud.slash"
        case .restricted:
            return "exclamationmark.icloud"
        case .temporarilyUnavailable:
            return "icloud.slash"
        case .error:
            return "exclamationmark.triangle"
        }
    }
}