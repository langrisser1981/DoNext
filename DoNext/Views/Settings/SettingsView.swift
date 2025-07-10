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
            
            Section("其他") {
                Button("關於") {
                    // TODO: 顯示關於頁面
                }
            }
        }
        .navigationTitle("設定")
        .navigationBarTitleDisplayMode(.inline)
    }
}