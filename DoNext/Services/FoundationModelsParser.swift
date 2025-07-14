//
//  FoundationModelsParser.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/14.
//

import Foundation
// 注意：FoundationModels 框架將在 iOS 26 正式發布後可用
// import FoundationModels

/// Foundation Models 文字解析器
/// 使用 iOS 26 的 Foundation Models 框架進行智能文字解析
@available(iOS 26.0, *)
class FoundationModelsParser {
    
    // MARK: - Properties
    
    private let maxRetries = 3
    private let timeoutInterval: TimeInterval = 30
    
    // MARK: - Public Methods
    
    /// 解析語音識別文字為結構化的待辦事項資料
    /// - Parameter text: 要解析的文字
    /// - Returns: 解析後的待辦事項資料
    func parseTodoText(_ text: String) async throws -> ParsedTodoData {
        // 創建解析提示
        let prompt = createParsingPrompt(for: text)
        
        // 使用 Foundation Models 進行解析
        do {
            let result = try await performFoundationModelsInference(prompt: prompt)
            return try parseFoundationModelsResult(result)
        } catch {
            // 如果 Foundation Models 失敗，使用關鍵字解析作為後備
            print("Foundation Models 解析失敗，使用關鍵字解析: \(error)")
            return parseWithKeywords(text)
        }
    }
    
    // MARK: - Foundation Models Integration
    
    /// 執行 Foundation Models 推理
    private func performFoundationModelsInference(prompt: String) async throws -> String {
        // 注意：這裡需要等待 iOS 26 正式發布後才能使用真實的 Foundation Models API
        // 目前使用模擬實現
        
        #if false // 等待 iOS 26 發布後啟用
        // 當 FoundationModels 框架可用時，使用以下代碼：
        /*
        let request = MLFoundationModelRequest(
            prompt: prompt,
            maxTokens: 200,
            temperature: 0.3
        )
        
        let response = try await MLFoundationModel.shared.generateResponse(request)
        return response.text
        */
        #endif
        
        // 模擬 Foundation Models 回應
        return try await simulateFoundationModelsResponse(for: prompt)
    }
    
    /// 模擬 Foundation Models 回應（用於開發階段）
    private func simulateFoundationModelsResponse(for prompt: String) async throws -> String {
        // 模擬網路延遲
        try await Task.sleep(nanoseconds: 1_000_000_000) // 1秒
        
        // 根據輸入生成模擬的結構化回應
        let input = extractInputFromPrompt(prompt)
        return generateMockResponse(for: input)
    }
    
    /// 從提示中提取原始輸入
    private func extractInputFromPrompt(_ prompt: String) -> String {
        // 提取 "用戶輸入:" 後的內容
        if let range = prompt.range(of: "用戶輸入:") {
            let startIndex = range.upperBound
            let substring = prompt[startIndex...].trimmingCharacters(in: .whitespacesAndNewlines)
            return String(substring)
        }
        return prompt
    }
    
    /// 生成模擬回應
    private func generateMockResponse(for input: String) -> String {
        var response = "{\n"
        
        // 解析標題
        var title = input
        var category: String?
        var hasReminder = false
        var reminderDate: String?
        var repeatType = "none"
        
        // 時間解析
        let timePatterns = [
            ("明天", "tomorrow"),
            ("後天", "day_after_tomorrow"),
            ("下週", "next_week"),
            ("下個月", "next_month"),
            ("今天下午", "today_afternoon"),
            ("晚上", "tonight")
        ]
        
        for (keyword, timeKey) in timePatterns {
            if input.contains(keyword) {
                hasReminder = true
                reminderDate = timeKey
                title = title.replacingOccurrences(of: keyword, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                break
            }
        }
        
        // 重複模式解析
        let repeatPatterns = [
            ("每天", "daily"),
            ("每日", "daily"),
            ("每週", "weekly"),
            ("每个星期", "weekly"),
            ("每月", "monthly"),
            ("每年", "yearly")
        ]
        
        for (keyword, type) in repeatPatterns {
            if input.contains(keyword) {
                hasReminder = true
                repeatType = type
                title = title.replacingOccurrences(of: keyword, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                break
            }
        }
        
        // 分類解析
        let categoryPatterns = [
            "工作", "學習", "運動", "健康", "家庭", "購物", "旅行", "娛樂", "會議"
        ]
        
        for cat in categoryPatterns {
            if input.contains(cat) {
                category = cat
                title = title.replacingOccurrences(of: cat, with: "").trimmingCharacters(in: .whitespacesAndNewlines)
                break
            }
        }
        
        // 構建 JSON 回應
        response += "  \"title\": \"\(title)\",\n"
        
        if let category = category {
            response += "  \"category\": \"\(category)\",\n"
        }
        
        response += "  \"hasReminder\": \(hasReminder),\n"
        
        if let reminderDate = reminderDate {
            response += "  \"reminderDate\": \"\(reminderDate)\",\n"
        }
        
        response += "  \"repeatType\": \"\(repeatType)\"\n"
        response += "}"
        
        return response
    }
    
    // MARK: - Prompt Creation
    
    /// 創建解析提示
    private func createParsingPrompt(for text: String) -> String {
        return """
        你是一個智能的待辦事項解析助手。請將用戶的語音輸入解析為結構化的待辦事項資料。

        規則：
        1. 提取待辦事項的標題（移除時間和分類關鍵字）
        2. 識別可能的分類：工作、學習、運動、健康、家庭、購物、旅行、娛樂
        3. 解析時間相關的關鍵字：明天、後天、下週、下個月、今天下午、晚上等
        4. 識別重複模式：每天、每週、每月、每年
        5. 回應格式必須是有效的 JSON

        回應格式：
        {
          "title": "清理後的待辦事項標題",
          "category": "建議的分類（如果有）",
          "hasReminder": true/false,
          "reminderDate": "解析的時間（如果有）",
          "repeatType": "none/daily/weekly/monthly/yearly"
        }

        用戶輸入: \(text)

        請解析上述輸入並以 JSON 格式回應：
        """
    }
    
    /// 解析 Foundation Models 結果
    private func parseFoundationModelsResult(_ result: String) throws -> ParsedTodoData {
        guard let data = result.data(using: .utf8) else {
            throw ParsingError.invalidResponse
        }
        
        do {
            let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return try parseParsedDataFromJSON(json)
        } catch {
            throw ParsingError.jsonParsingFailed(error)
        }
    }
    
    /// 從 JSON 解析 ParsedTodoData
    private func parseParsedDataFromJSON(_ json: [String: Any]?) throws -> ParsedTodoData {
        guard let json = json else {
            throw ParsingError.invalidJSON
        }
        
        var data = ParsedTodoData()
        
        data.title = json["title"] as? String ?? ""
        data.suggestedCategory = json["category"] as? String
        data.hasReminder = json["hasReminder"] as? Bool ?? false
        
        if let reminderDateString = json["reminderDate"] as? String {
            data.reminderDate = parseReminderDate(from: reminderDateString)
        }
        
        if let repeatTypeString = json["repeatType"] as? String {
            data.repeatType = RepeatType.from(string: repeatTypeString)
        }
        
        return data
    }
    
    /// 解析提醒日期
    private func parseReminderDate(from string: String) -> Date? {
        let calendar = Calendar.current
        let now = Date()
        
        switch string {
        case "tomorrow":
            return calendar.date(byAdding: .day, value: 1, to: now)
        case "day_after_tomorrow":
            return calendar.date(byAdding: .day, value: 2, to: now)
        case "next_week":
            return calendar.date(byAdding: .weekOfYear, value: 1, to: now)
        case "next_month":
            return calendar.date(byAdding: .month, value: 1, to: now)
        case "today_afternoon":
            return calendar.date(bySettingHour: 14, minute: 0, second: 0, of: now)
        case "tonight":
            return calendar.date(bySettingHour: 19, minute: 0, second: 0, of: now)
        default:
            return nil
        }
    }
    
    // MARK: - Fallback Parser
    
    /// 關鍵字解析（後備方案）
    private func parseWithKeywords(_ text: String) -> ParsedTodoData {
        var data = ParsedTodoData()
        var title = text
        
        // 時間解析
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
        
        // 重複模式解析
        let repeatPatterns: [String: RepeatType] = [
            "每天": .daily,
            "每日": .daily,
            "每週": .weekly,
            "每個星期": .weekly,
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
        
        // 分類解析
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
        
        data.title = title.trimmingCharacters(in: .whitespacesAndNewlines)
        return data
    }
}

// MARK: - Supporting Types

enum ParsingError: LocalizedError {
    case invalidResponse
    case jsonParsingFailed(Error)
    case invalidJSON
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "無效的回應格式"
        case .jsonParsingFailed(let error):
            return "JSON 解析失敗: \(error.localizedDescription)"
        case .invalidJSON:
            return "無效的 JSON 資料"
        }
    }
}

extension RepeatType {
    static func from(string: String) -> RepeatType {
        switch string {
        case "daily": return .daily
        case "weekly": return .weekly
        case "monthly": return .monthly
        case "yearly": return .yearly
        default: return .none
        }
    }
}