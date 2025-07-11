//
//  SettingsAccountSection.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 設定頁面帳戶區段元件
/// 顯示用戶資訊和登出選項
struct SettingsAccountSection: View {
    let currentUser: AuthResult?
    let onSignOut: () -> Void
    
    var body: some View {
        Section("帳戶") {
            if let user = currentUser {
                Text("用戶: \(user.displayName ?? "未知")")
            }
            
            Button("登出") {
                onSignOut()
            }
            .foregroundColor(.red)
        }
    }
}

#Preview {
    List {
        SettingsAccountSection(
            currentUser: nil as AuthResult?,
            onSignOut: { }
        )
    }
}