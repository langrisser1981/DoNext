//
//  HomeEmptyState.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 首頁空狀態視圖元件
/// 當沒有待辦事項時顯示的引導界面
struct HomeEmptyState: View {
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundColor(.blue.opacity(0.6))
            
            Text("還沒有待辦事項")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("點擊右下角的 + 按鈕來新增您的第一個待辦事項")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    HomeEmptyState()
}