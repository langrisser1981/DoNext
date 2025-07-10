//
//  SettingsView.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI

/// 設定視圖
struct SettingsView: View {
    @Environment(AppCoordinator.self) var appCoordinator
    @Environment(CloudKitManager.self) var cloudKitManager
    @Environment(SettingsManager.self) var settingsManager
    
    @State private var showRestartAlert = false
    
    var body: some View {
        List {
            Section("帳戶") {
                if let user = appCoordinator.currentUser {
                    Text("用戶: \(user.displayName ?? "未知")")
                }
                
                Button("登出") {
                    appCoordinator.presentAlert(.signOutConfirmation)
                }
                .foregroundColor(.red)
            }
            
            // 只有當帳號支援 iCloud 或已經啟用過同步時才顯示此區段
            if settingsManager.shouldShowCloudSyncOption || settingsManager.isCloudSyncEnabled {
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
                                // 如果用戶想要啟用同步，但 iCloud 不可用，顯示提示
                                if newValue && !cloudKitManager.syncStatus.isAvailableForSync {
                                    // 可以在這裡顯示 alert 或其他提示
                                    return
                                }
                                settingsManager.isCloudSyncEnabled = newValue
                                // 顯示需要重啟應用的提示
                                showRestartAlert = true
                            }
                        ))
                        .disabled(!settingsManager.shouldShowCloudSyncOption)
                    }
                    .padding(.vertical, 4)
                    
                    // 同步狀態顯示
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
            
            Section("其他") {
                Button("關於") {
                    // TODO: 顯示關於頁面
                }
            }
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await cloudKitManager.refreshSyncStatus()
        }
        .alert("需要重新啟動", isPresented: $showRestartAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text("更改 iCloud 同步設定需要重新啟動應用程式才能生效。")
        }
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