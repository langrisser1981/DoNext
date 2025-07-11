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
            SettingsAccountSection(
                currentUser: appCoordinator.currentUser,
                onSignOut: { appCoordinator.presentAlert(.signOutConfirmation) }
            )
            
            settingsCloudSyncSection
            
            SettingsOtherSection(
                onAboutTap: { /* TODO: 顯示關於頁面 */ }
            )
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
    
    /// 條件顯示的 iCloud 同步區段
    @ViewBuilder
    private var settingsCloudSyncSection: some View {
        if settingsManager.shouldShowCloudSyncOption || settingsManager.isCloudSyncEnabled {
            SettingsCloudSyncSection(showRestartAlert: $showRestartAlert)
        }
    }
}