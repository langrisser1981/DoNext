//
//  VoiceInputSheet.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/14.
//

import SwiftUI

/// 語音輸入彈出視窗
/// 提供完整的語音輸入和智能解析界面
struct VoiceInputSheet: View {
    let voiceInputManager: VoiceInputManager
    let onComplete: (ParsedTodoData) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var showingPermissionAlert = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 24) {
                // 語音輸入狀態指示
                VoiceInputStatusView(voiceInputManager: voiceInputManager)
                
                // 識別結果顯示
                RecognizedTextView(voiceInputManager: voiceInputManager)
                
                // 解析結果顯示
                if let parsedData = voiceInputManager.parsedTodoData {
                    ParsedDataView(parsedData: parsedData)
                }
                
                Spacer()
                
                // 控制按鈕
                VoiceInputControlButtons(
                    voiceInputManager: voiceInputManager,
                    onComplete: onComplete,
                    onCancel: { dismiss() }
                )
            }
            .padding()
            .navigationTitle("語音輸入")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("取消") {
                        voiceInputManager.stopRecording()
                        dismiss()
                    }
                }
            }
        }
        .alert("需要權限", isPresented: $showingPermissionAlert) {
            Button("前往設定") {
                if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(settingsUrl)
                }
            }
            Button("取消", role: .cancel) {
                dismiss()
            }
        } message: {
            Text("需要麥克風和語音識別權限才能使用語音輸入功能")
        }
        .onAppear {
            Task {
                let hasPermission = await voiceInputManager.requestPermissions()
                if !hasPermission {
                    showingPermissionAlert = true
                }
            }
        }
    }
}

/// 語音輸入狀態指示視圖
struct VoiceInputStatusView: View {
    @Bindable var voiceInputManager: VoiceInputManager
    
    var body: some View {
        VStack(spacing: 16) {
            // 麥克風圖示
            ZStack {
                Circle()
                    .fill(voiceInputManager.isRecording ? Color.red.opacity(0.2) : Color.blue.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(voiceInputManager.isRecording ? 1.2 : 1.0)
                    .animation(voiceInputManager.isRecording ? 
                              .easeInOut(duration: 0.8).repeatForever(autoreverses: true) : 
                              .easeInOut(duration: 0.3), 
                              value: voiceInputManager.isRecording)
                
                Image(systemName: "mic.fill")
                    .font(.system(size: 40))
                    .foregroundColor(voiceInputManager.isRecording ? .red : .blue)
            }
            
            // 狀態文字
            Text(voiceInputManager.isRecording ? "正在聆聽..." : "點擊開始錄音")
                .font(.headline)
                .foregroundColor(voiceInputManager.isRecording ? .red : .primary)
            
            // 錯誤訊息
            if let errorMessage = voiceInputManager.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
    }
}

/// 識別文字顯示視圖
struct RecognizedTextView: View {
    @Bindable var voiceInputManager: VoiceInputManager
    
    var body: some View {
        if !voiceInputManager.recognizedText.isEmpty {
            VStack(alignment: .leading, spacing: 8) {
                Text("語音識別結果:")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
                ScrollView {
                    Text(voiceInputManager.recognizedText)
                        .font(.body)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                }
                .frame(maxHeight: 120)
            }
        }
    }
}

/// 解析結果顯示視圖
struct ParsedDataView: View {
    let parsedData: ParsedTodoData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("智能解析結果:")
                .font(.headline)
                .foregroundColor(.secondary)
            
            VStack(spacing: 8) {
                if !parsedData.title.isEmpty {
                    ParsedDataRow(title: "標題", value: parsedData.title, color: .blue)
                }
                
                if let category = parsedData.suggestedCategory {
                    ParsedDataRow(title: "建議分類", value: category, color: .green)
                }
                
                if parsedData.hasReminder {
                    let dateText = parsedData.reminderDate?.formatted(date: .abbreviated, time: .shortened) ?? "已設定"
                    ParsedDataRow(title: "提醒時間", value: dateText, color: .orange)
                }
                
                if parsedData.repeatType != .none {
                    ParsedDataRow(title: "重複", value: parsedData.repeatType.displayName, color: .purple)
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(12)
        }
    }
}

/// 解析結果行視圖
struct ParsedDataRow: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(title + ":")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(color)
        }
    }
}

/// 語音輸入控制按鈕
struct VoiceInputControlButtons: View {
    @Bindable var voiceInputManager: VoiceInputManager
    let onComplete: (ParsedTodoData) -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            // 錄音控制按鈕
            Button(action: {
                if voiceInputManager.isRecording {
                    voiceInputManager.stopRecording()
                } else {
                    Task {
                        do {
                            try await voiceInputManager.startRecording()
                        } catch {
                            voiceInputManager.errorMessage = error.localizedDescription
                        }
                    }
                }
            }) {
                HStack {
                    Image(systemName: voiceInputManager.isRecording ? "stop.circle.fill" : "mic.circle.fill")
                    Text(voiceInputManager.isRecording ? "停止錄音" : "開始錄音")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(voiceInputManager.isRecording ? Color.red : Color.blue)
                .cornerRadius(12)
            }
            
            // 完成和取消按鈕
            if let parsedData = voiceInputManager.parsedTodoData {
                HStack(spacing: 16) {
                    Button("取消") {
                        onCancel()
                    }
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray5))
                    .cornerRadius(12)
                    
                    Button("使用結果") {
                        onComplete(parsedData)
                    }
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .cornerRadius(12)
                }
            }
        }
    }
}

// MARK: - Extensions


#Preview {
    VoiceInputSheet(voiceInputManager: VoiceInputManager()) { _ in }
}