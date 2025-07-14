//
//  VoiceInputManager.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/14.
//

import Foundation
import Speech
import AVFoundation

/// 語音輸入管理器
/// 整合語音識別和智能解析功能，將語音轉換為結構化的待辦事項資料
@MainActor
@Observable
class VoiceInputManager: NSObject {
    
    // MARK: - Properties
    
    /// 語音識別器
    private var speechRecognizer: SFSpeechRecognizer?
    /// 語音識別請求
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    /// 語音識別任務
    private var recognitionTask: SFSpeechRecognitionTask?
    /// 音頻引擎
    private let audioEngine = AVAudioEngine()
    /// Foundation Models 解析器
    private var foundationModelsParser: FoundationModelsParser?
    
    /// 當前錄音狀態
    var isRecording = false
    /// 識別的文字
    var recognizedText = ""
    /// 錯誤訊息
    var errorMessage: String?
    /// 解析結果
    var parsedTodoData: ParsedTodoData?
    
    // MARK: - Initialization
    
    override init() {
        super.init()
        setupSpeechRecognizer()
    }
    
    // MARK: - Setup
    
    /// 設定語音識別器
    private func setupSpeechRecognizer() {
        // 使用繁體中文語音識別
        speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "zh-TW"))
        speechRecognizer?.delegate = self
    }
    
    // MARK: - Permission
    
    /// 請求語音識別權限
    func requestPermissions() async -> Bool {
        // 請求語音識別權限
        let speechStatus = await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status)
            }
        }
        
        guard speechStatus == .authorized else {
            errorMessage = "語音識別權限未授權"
            return false
        }
        
        // 請求麥克風權限
        let microphoneStatus = await AVAudioApplication.requestRecordPermission()
        guard microphoneStatus else {
            errorMessage = "麥克風權限未授權"
            return false
        }
        
        return true
    }
    
    // MARK: - Recording Control
    
    /// 開始錄音和語音識別
    func startRecording() async throws {
        guard await requestPermissions() else {
            throw VoiceInputError.permissionDenied
        }
        
        // 重置狀態
        recognizedText = ""
        errorMessage = nil
        parsedTodoData = nil
        
        // 停止現有的錄音
        if audioEngine.isRunning {
            stopRecording()
        }
        
        try await setupAudioSession()
        try startSpeechRecognition()
        
        isRecording = true
    }
    
    /// 停止錄音
    func stopRecording() {
        isRecording = false
        
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask?.cancel()
        recognitionTask = nil
    }
    
    // MARK: - Audio Setup
    
    /// 設定音頻會話
    private func setupAudioSession() async throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    /// 開始語音識別
    private func startSpeechRecognition() throws {
        guard let speechRecognizer = speechRecognizer,
              speechRecognizer.isAvailable else {
            throw VoiceInputError.speechRecognizerUnavailable
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw VoiceInputError.recognitionRequestFailed
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            recognitionRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            Task { @MainActor in
                self?.handleRecognitionResult(result: result, error: error)
            }
        }
    }
    
    // MARK: - Speech Recognition Handling
    
    /// 處理語音識別結果
    private func handleRecognitionResult(result: SFSpeechRecognitionResult?, error: Error?) {
        if let error = error {
            self.errorMessage = "語音識別錯誤: \(error.localizedDescription)"
            stopRecording()
            return
        }
        
        if let result = result {
            self.recognizedText = result.bestTranscription.formattedString
            
            // 如果是最終結果，進行智能解析
            if result.isFinal {
                Task {
                    await parseRecognizedText()
                }
            }
        }
    }
    
    // MARK: - Text Parsing
    
    /// 解析識別的文字
    private func parseRecognizedText() async {
        guard !recognizedText.isEmpty else { return }
        
        do {
            parsedTodoData = try await parseTextWithFoundationModels(recognizedText)
        } catch {
            errorMessage = "解析錯誤: \(error.localizedDescription)"
        }
    }
    
    /// 使用 Foundation Models 解析文字
    private func parseTextWithFoundationModels(_ text: String) async throws -> ParsedTodoData {
        if #available(iOS 26.0, *) {
            if foundationModelsParser == nil {
                foundationModelsParser = FoundationModelsParser()
            }
            return try await foundationModelsParser!.parseTodoText(text)
        } else {
            // iOS 26 以下使用關鍵字解析
            return parseTextWithKeywords(text)
        }
    }
    
    /// 關鍵字解析（後備方案）
    private func parseTextWithKeywords(_ text: String) -> ParsedTodoData {
        var data = ParsedTodoData()
        
        // 解析標題（移除時間和分類關鍵字）
        var title = text
        
        // 解析時間相關關鍵字
        let timePatterns = [
            "明天": Calendar.current.date(byAdding: .day, value: 1, to: Date()),
            "後天": Calendar.current.date(byAdding: .day, value: 2, to: Date()),
            "下週": Calendar.current.date(byAdding: .weekOfYear, value: 1, to: Date()),
            "下個月": Calendar.current.date(byAdding: .month, value: 1, to: Date())
        ]
        
        for (keyword, date) in timePatterns {
            if text.contains(keyword) {
                data.reminderDate = date
                data.hasReminder = true
                title = title.replacingOccurrences(of: keyword, with: "")
                break
            }
        }
        
        // 解析重複模式
        let repeatPatterns: [String: RepeatType] = [
            "每天": .daily,
            "每日": .daily,
            "每週": .weekly,
            "每个星期": .weekly,
            "每月": .monthly,
            "每年": .yearly
        ]
        
        for (keyword, repeatType) in repeatPatterns {
            if text.contains(keyword) {
                data.repeatType = repeatType
                data.hasReminder = true
                title = title.replacingOccurrences(of: keyword, with: "")
                break
            }
        }
        
        // 解析分類關鍵字
        let categoryKeywords = [
            "工作", "學習", "運動", "健康", "家庭", "購物", "旅行", "娛樂"
        ]
        
        for category in categoryKeywords {
            if text.contains(category) {
                data.suggestedCategory = category
                title = title.replacingOccurrences(of: category, with: "")
                break
            }
        }
        
        // 清理標題
        data.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        
        return data
    }
    
    /// 解析純文字輸入（不經過語音識別）
    /// - Parameter text: 要解析的文字
    /// - Returns: 解析後的待辦事項資料
    /// - Throws: 解析過程中的錯誤
    @MainActor
    func parseText(_ text: String) async throws -> ParsedTodoData {
        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw VoiceInputError.invalidInput("輸入文字不能為空")
        }
        
        // 使用與 parseTextWithFoundationModels 相同的邏輯
        return try await parseTextWithFoundationModels(text)
    }
}

// MARK: - SFSpeechRecognizerDelegate

extension VoiceInputManager: SFSpeechRecognizerDelegate {
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        if !available {
            errorMessage = "語音識別服務暫時不可用"
            stopRecording()
        }
    }
}

// MARK: - Supporting Types

/// 解析的待辦事項資料
struct ParsedTodoData {
    var title: String = ""
    var suggestedCategory: String?
    var hasReminder: Bool = false
    var reminderDate: Date?
    var repeatType: RepeatType = .none
}

/// 語音輸入錯誤
enum VoiceInputError: LocalizedError {
    case permissionDenied
    case speechRecognizerUnavailable
    case recognitionRequestFailed
    case invalidInput(String)
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "語音識別或麥克風權限被拒絕"
        case .speechRecognizerUnavailable:
            return "語音識別服務不可用"
        case .recognitionRequestFailed:
            return "無法創建語音識別請求"
        case .invalidInput(let message):
            return message
        }
    }
}
