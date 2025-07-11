//
//  HomeToolbarContent.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 首頁工具欄內容元件
/// 提供導航欄按鈕的配置
struct HomeToolbarContent {
    let syncStatus: SyncStatus
    let onSyncRefresh: () -> Void
    let onShowSettings: () -> Void
    
    /// 同步狀態顏色
    private var syncStatusColor: Color {
        switch syncStatus {
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

extension HomeToolbarContent: ToolbarContent {
    var body: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            Button {
                onSyncRefresh()
            } label: {
                Image(systemName: syncStatus.systemImage)
                    .foregroundColor(syncStatusColor)
            }
        }
        
        ToolbarItem(placement: .navigationBarTrailing) {
            Button {
                onShowSettings()
            } label: {
                Image(systemName: "person.circle")
            }
        }
    }
}