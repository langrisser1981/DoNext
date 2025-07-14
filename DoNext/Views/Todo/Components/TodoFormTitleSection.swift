//
//  TodoFormTitleSection.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/11.
//

import SwiftUI

/// 待辦事項表單標題輸入區段元件
/// 提供待辦事項標題的輸入界面，包含語音輸入功能
struct TodoFormTitleSection: View {
    @Binding var title: String
    let onVoiceInputComplete: ((ParsedTodoData) -> Void)?
    @State private var voiceInputManager = VoiceInputManager()
    @State private var showingVoiceInput = false
    
    init(title: Binding<String>, onVoiceInputComplete: ((ParsedTodoData) -> Void)? = nil) {
        self._title = title
        self.onVoiceInputComplete = onVoiceInputComplete
    }
    
    var body: some View {
        Section {
            HStack {
                TextField("輸入待辦事項", text: $title)
                    .font(.body)
                
                Button(action: {
                    handleVoiceInput()
                }) {
                    Image(systemName: voiceInputManager.isRecording ? "waveform" : "mic.fill")
                        .foregroundColor(voiceInputManager.isRecording ? .red : .blue)
                        .font(.system(size: 20))
                        .symbolEffect(.pulse, isActive: voiceInputManager.isRecording)
                }
                .buttonStyle(.plain)
                .disabled(showingVoiceInput)
            }
            
            // 顯示語音識別文字
            if !voiceInputManager.recognizedText.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("語音識別結果:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(voiceInputManager.recognizedText)
                        .font(.body)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    
                    if let parsedData = voiceInputManager.parsedTodoData {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("智能解析:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            if !parsedData.title.isEmpty {
                                HStack {
                                    Text("標題:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(parsedData.title)
                                        .font(.caption)
                                }
                            }
                            
                            if let category = parsedData.suggestedCategory {
                                HStack {
                                    Text("建議分類:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(category)
                                        .font(.caption)
                                }
                            }
                            
                            if parsedData.hasReminder {
                                HStack {
                                    Text("提醒:")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                    Text(parsedData.reminderDate?.formatted(date: .abbreviated, time: .shortened) ?? "已設定")
                                        .font(.caption)
                                }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(8)
                        
                        Button("套用解析結果") {
                            applyParsedData(parsedData)
                            onVoiceInputComplete?(parsedData)
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
            }
            
            // 錯誤訊息
            if let errorMessage = voiceInputManager.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        } header: {
            Text("標題")
        }
        .sheet(isPresented: $showingVoiceInput) {
            VoiceInputSheet(voiceInputManager: voiceInputManager) { parsedData in
                applyParsedData(parsedData)
                onVoiceInputComplete?(parsedData)
                showingVoiceInput = false
            }
        }
    }
    
    /// 處理語音輸入
    private func handleVoiceInput() {
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
    }
    
    /// 套用解析結果
    private func applyParsedData(_ parsedData: ParsedTodoData) {
        if !parsedData.title.isEmpty {
            title = parsedData.title
        }
        // 其他屬性將通過回調傳遞給父組件
    }
}

#Preview {
    @Previewable @State var title = ""
    return Form {
        TodoFormTitleSection(title: $title)
    }
}