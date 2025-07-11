//
//  SettingsCloudSyncSection.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 設定頁面 iCloud 同步區段元件
/// 管理 iCloud 同步相關設定
struct SettingsCloudSyncSection: View {
    @Environment(CloudKitManager.self) var cloudKitManager
    @Environment(SettingsManager.self) var settingsManager
    @Binding var showRestartAlert: Bool
    
    var body: some View {
        Section("iCloud 同步") {
            // iCloud 同步開關
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("啟用 iCloud 同步")
                        .font(.headline)
                    
                    Text("在不同裝置間同步待辦事項資料")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: Binding(
                    get: { settingsManager.isCloudSyncEnabled },
                    set: { newValue in
                        handleSyncToggle(newValue)
                    }
                ))
                .disabled(!settingsManager.shouldShowCloudSyncOption)
            }
            .padding(.vertical, 4)
            
            // 同步狀態顯示
            syncStatusRow
            
            // 重新檢查按鈕
            if settingsManager.shouldShowCloudSyncOption {
                Button("重新檢查 iCloud 狀態") {
                    Task {
                        await cloudKitManager.refreshSyncStatus()
                    }
                }
                .disabled(cloudKitManager.syncStatus == .unknown)
            }
        }
    }
    
    /// 同步狀態顯示行
    @ViewBuilder
    private var syncStatusRow: some View {
        HStack {
            Image(systemName: cloudKitManager.effectiveSyncStatus.systemImage)
                .foregroundColor(statusColor)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("同步狀態")
                    .font(.subheadline)
                
                Text(cloudKitManager.effectiveSyncStatus.displayText)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                if let errorMessage = cloudKitManager.errorMessage,
                   cloudKitManager.effectiveSyncStatus != .available,
                   cloudKitManager.effectiveSyncStatus != .disabled {
                    Text(errorMessage)
                        .font(.caption2)
                        .foregroundColor(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            
            Spacer()
            
            if cloudKitManager.syncStatus == .unknown {
                ProgressView()
                    .scaleEffect(0.6)
            }
        }
        .padding(.vertical, 2)
    }
    
    /// 處理同步開關切換
    private func handleSyncToggle(_ newValue: Bool) {
        // 如果用戶想要啟用同步，但 iCloud 不可用，顯示提示
        if newValue && !cloudKitManager.syncStatus.isAvailableForSync {
            // 可以在這裡顯示 alert 或其他提示
            return
        }
        settingsManager.isCloudSyncEnabled = newValue
        // 顯示需要重啟應用的提示
        showRestartAlert = true
    }
    
    /// 同步狀態顏色
    private var statusColor: Color {
        switch cloudKitManager.effectiveSyncStatus {
        case .available:
            return .green
        case .noAccount, .restricted, .error:
            return .red
        case .temporarilyUnavailable:
            return .orange
        case .unknown:
            return .gray
        case .disabled:
            return .secondary
        }
    }
}

#Preview {
    @State var showRestartAlert = false
    return List {
        SettingsCloudSyncSection(showRestartAlert: $showRestartAlert)
    }
}