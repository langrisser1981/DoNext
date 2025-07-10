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
            
            Section("iCloud 同步") {
                HStack {
                    Image(systemName: cloudKitManager.syncStatus.systemImage)
                        .foregroundColor(statusColor)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("同步狀態")
                            .font(.headline)
                        
                        Text(cloudKitManager.syncStatus.displayText)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        if let errorMessage = cloudKitManager.errorMessage,
                           cloudKitManager.syncStatus != .available {
                            Text(errorMessage)
                                .font(.caption)
                                .foregroundColor(.red)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                    }
                    
                    Spacer()
                    
                    if cloudKitManager.syncStatus == .unknown {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                }
                .padding(.vertical, 4)
                
                Button("重新檢查同步狀態") {
                    Task {
                        await cloudKitManager.refreshSyncStatus()
                    }
                }
                .disabled(cloudKitManager.syncStatus == .unknown)
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
    }
    
    /// 同步狀態顏色
    private var statusColor: Color {
        switch cloudKitManager.syncStatus {
        case .available:
            return .green
        case .noAccount, .restricted, .error:
            return .red
        case .temporarilyUnavailable:
            return .orange
        case .unknown:
            return .gray
        }
    }
}