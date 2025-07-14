//
//  AdaptiveInputSection.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/14.
//

import SwiftUI

/// 自適應輸入區段
/// 根據 Apple Intelligence 可用性動態切換界面
struct AdaptiveInputSection: View {
    @Binding var title: String
    let onInputComplete: ((ParsedTodoData) -> Void)?
    
    @Environment(\.intelligenceAvailabilityManager) private var availabilityManager
    
    init(title: Binding<String>, onInputComplete: ((ParsedTodoData) -> Void)? = nil) {
        self._title = title
        self.onInputComplete = onInputComplete
    }
    
    var body: some View {
        switch availabilityManager.availability {
        case .checking:
            CheckingAvailabilityView()
            
        case .available:
            // Apple Intelligence 可用，顯示智能輸入界面
            SmartInputSection(
                title: $title,
                onSmartInputComplete: onInputComplete
            )
            
        case .unavailable(.deviceNotEligible),
             .unavailable(.systemVersionNotSupported):
            // 設備不支援或系統版本不足，顯示傳統界面
            TraditionalInputSection(
                title: $title,
                onVoiceInputComplete: onInputComplete
            )
            
        case .unavailable(.appleIntelligenceNotEnabled):
            // Apple Intelligence 未開啟，顯示提示和傳統界面
            VStack {
                IntelligenceNotEnabledBanner()
                TraditionalInputSection(
                    title: $title,
                    onVoiceInputComplete: onInputComplete
                )
            }
            
        case .unavailable(.modelNotReady):
            // 模型未準備好，顯示等待界面和傳統輸入
            VStack {
                ModelNotReadyBanner()
                TraditionalInputSection(
                    title: $title,
                    onVoiceInputComplete: onInputComplete
                )
            }
            
        case .unavailable(.other):
            // 其他原因不可用，顯示傳統界面
            TraditionalInputSection(
                title: $title,
                onVoiceInputComplete: onInputComplete
            )
        }
    }
}

// MARK: - Supporting Views

/// 檢查可用性視圖
private struct CheckingAvailabilityView: View {
    var body: some View {
        Section {
            HStack {
                ProgressView()
                    .scaleEffect(0.8)
                Text("檢查 Apple Intelligence 可用性...")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Spacer()
            }
            .padding(.vertical, 8)
        } header: {
            Text("輸入")
        }
    }
}

/// Apple Intelligence 未開啟提示橫幅
private struct IntelligenceNotEnabledBanner: View {
    var body: some View {
        HStack {
            Image(systemName: "brain.head.profile")
                .foregroundColor(.blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Apple Intelligence 可用")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("在系統設定中開啟以使用智能輸入功能")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("設定") {
                openSettings()
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.blue.opacity(0.1))
        .cornerRadius(8)
    }
    
    private func openSettings() {
        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsURL)
        }
    }
}

/// 模型未準備好提示橫幅
private struct ModelNotReadyBanner: View {
    @Environment(\.intelligenceAvailabilityManager) private var availabilityManager
    
    var body: some View {
        HStack {
            ProgressView()
                .scaleEffect(0.7)
            
            VStack(alignment: .leading, spacing: 2) {
                Text("Apple Intelligence 準備中")
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text("模型正在下載或初始化，請稍後再試")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Button("重試") {
                Task {
                    await availabilityManager.recheckAvailability()
                }
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(8)
    }
}

/// 傳統輸入區段（重新使用原有的 TodoFormTitleSection）
private struct TraditionalInputSection: View {
    @Binding var title: String
    let onVoiceInputComplete: ((ParsedTodoData) -> Void)?
    
    var body: some View {
        TodoFormTitleSection(
            title: $title,
            onVoiceInputComplete: onVoiceInputComplete
        )
    }
}

#Preview {
    @Previewable @State var title = ""
    
    NavigationView {
        Form {
            AdaptiveInputSection(title: $title) { parsedData in
                print("輸入完成: \(parsedData)")
            }
        }
        .navigationTitle("自適應輸入測試")
    }
    .environment(\.intelligenceAvailabilityManager, IntelligenceAvailabilityManager())
}