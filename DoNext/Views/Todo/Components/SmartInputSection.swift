//
//  SmartInputSection.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/14.
//

import SwiftUI

/// 智能輸入區段元件
/// 結合文字輸入、語音輸入與 Foundation Models 智能解析
struct SmartInputSection: View {
    @Binding var title: String
    let onSmartInputComplete: ((ParsedTodoData) -> Void)?
    
    @State private var voiceInputManager = VoiceInputManager()
    @State private var inputText = ""
    @State private var isAnalyzing = false
    @State private var showingVoiceInput = false
    @State private var analysisTimer: Timer?
    
    init(title: Binding<String>, onSmartInputComplete: ((ParsedTodoData) -> Void)? = nil) {
        self._title = title
        self.onSmartInputComplete = onSmartInputComplete
    }
    
    var body: some View {
        Section {
            inputRow
            analysisResultView
            errorMessageView
        } header: {
            Text("智能輸入")
        }
        .onAppear {
            inputText = title
        }
        .sheet(isPresented: $showingVoiceInput) {
            VoiceInputSheet(voiceInputManager: voiceInputManager) { parsedData in
                applyParsedData(parsedData)
                onSmartInputComplete?(parsedData)
                showingVoiceInput = false
            }
        }
    }
    
    /// 輸入行
    private var inputRow: some View {
        HStack {
            TextField("輸入待辦事項，支援自然語言", text: $inputText)
                .font(.body)
                .onChange(of: inputText) { _, newValue in
                    title = newValue
                    scheduleTextAnalysis()
                }
            
            Spacer()
            
            // 智能解析按鈕
            Button(action: {
                analyzeTextInput()
            }) {
                if isAnalyzing {
                    ProgressView()
                        .scaleEffect(0.8)
                } else {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.purple)
                        .font(.system(size: 20))
                }
            }
            .buttonStyle(.plain)
            .disabled(inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isAnalyzing)
            
            // 語音輸入按鈕
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
    }
    
    /// 分析結果視圖
    @ViewBuilder
    private var analysisResultView: some View {
        // 語音識別結果
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
            }
        }
        
        // 智能解析結果
        if let parsedData = voiceInputManager.parsedTodoData {
            smartAnalysisView(parsedData: parsedData, source: "語音")
        }
    }
    
    /// 錯誤訊息視圖
    @ViewBuilder
    private var errorMessageView: some View {
        if let errorMessage = voiceInputManager.errorMessage {
            Text(errorMessage)
                .font(.caption)
                .foregroundColor(.red)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.red.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    /// 智能分析視圖
    private func smartAnalysisView(parsedData: ParsedTodoData, source: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("智能解析 (\(source)):")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if source == "文字" {
                    Image(systemName: "brain.head.profile")
                        .foregroundColor(.purple)
                        .font(.caption)
                }
            }
            
            VStack(alignment: .leading, spacing: 4) {
                if !parsedData.title.isEmpty {
                    analysisRow(label: "標題", value: parsedData.title, icon: "text.cursor")
                }
                
                if let category = parsedData.suggestedCategory {
                    analysisRow(label: "建議分類", value: category, icon: "folder")
                }
                
                if parsedData.hasReminder {
                    let reminderText = parsedData.reminderDate?.formatted(date: .abbreviated, time: .shortened) ?? "已設定"
                    analysisRow(label: "提醒", value: reminderText, icon: "bell")
                }
                
                if parsedData.repeatType != .none {
                    analysisRow(label: "重複", value: parsedData.repeatType.displayName, icon: "repeat")
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.green.opacity(0.1))
            .cornerRadius(8)
            
            Button("套用解析結果") {
                applyParsedData(parsedData)
                onSmartInputComplete?(parsedData)
            }
            .font(.caption)
            .foregroundColor(.blue)
        }
    }
    
    /// 分析行
    private func analysisRow(label: String, value: String, icon: String) -> some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.secondary)
                .font(.caption)
                .frame(width: 12)
            
            Text("\(label):")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
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
    
    /// 排程文字分析
    private func scheduleTextAnalysis() {
        // 取消之前的定時器
        analysisTimer?.invalidate()
        
        // 如果文字為空，清除解析結果
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            voiceInputManager.parsedTodoData = nil
            voiceInputManager.recognizedText = ""
            return
        }
        
        // 設定新的定時器，延遲 1.5 秒後分析
        analysisTimer = Timer.scheduledTimer(withTimeInterval: 1.5, repeats: false) { _ in
            Task { @MainActor in
                await analyzeTextInputAutomatically()
            }
        }
    }
    
    /// 自動分析文字輸入（延遲觸發）
    private func analyzeTextInputAutomatically() async {
        let textToAnalyze = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToAnalyze.isEmpty else { return }
        
        // 如果文字很短（少於 3 個字），不進行分析
        guard textToAnalyze.count >= 3 else { return }
        
        await performTextAnalysis(text: textToAnalyze)
    }
    
    /// 手動分析文字輸入
    private func analyzeTextInput() {
        let textToAnalyze = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !textToAnalyze.isEmpty else { return }
        
        Task {
            await performTextAnalysis(text: textToAnalyze)
        }
    }
    
    /// 執行文字分析
    private func performTextAnalysis(text: String) async {
        isAnalyzing = true
        voiceInputManager.errorMessage = nil
        
        do {
            // 使用 VoiceInputManager 的解析功能
            let parsedData = try await voiceInputManager.parseText(text)
            await MainActor.run {
                voiceInputManager.parsedTodoData = parsedData
                voiceInputManager.recognizedText = "" // 清除語音識別文字，因為這是文字輸入
            }
        } catch {
            await MainActor.run {
                voiceInputManager.errorMessage = "智能解析失敗: \(error.localizedDescription)"
            }
        }
        
        isAnalyzing = false
    }
    
    /// 套用解析結果
    private func applyParsedData(_ parsedData: ParsedTodoData) {
        if !parsedData.title.isEmpty {
            title = parsedData.title
            inputText = parsedData.title
        }
        
        // 清除解析結果
        voiceInputManager.parsedTodoData = nil
        voiceInputManager.recognizedText = ""
        voiceInputManager.errorMessage = nil
    }
}


#Preview {
    @Previewable @State var title = ""
    return Form {
        SmartInputSection(title: $title) { parsedData in
            print("解析結果: \(parsedData)")
        }
    }
}