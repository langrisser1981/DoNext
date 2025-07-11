//
//  SettingsOtherSection.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 設定頁面其他區段元件
/// 包含關於等其他設定選項
struct SettingsOtherSection: View {
    let onAboutTap: () -> Void
    
    var body: some View {
        Section("其他") {
            Button("關於") {
                onAboutTap()
            }
        }
    }
}

#Preview {
    List {
        SettingsOtherSection(onAboutTap: { })
    }
}