//
//  IntelligenceAvailabilityManager.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/14.
//

import Foundation
import SwiftUI
// iOS 26+ 才會有 FoundationModels
#if canImport(FoundationModels)
import FoundationModels
#endif

/// Apple Intelligence 可用性管理器
/// 檢查 iOS 26 SystemLanguageModel 是否可用並提供動態界面選擇
@MainActor
@Observable
class IntelligenceAvailabilityManager {
    
    // MARK: - Properties
    
    /// 當前的可用性狀態
    private(set) var availability: IntelligenceAvailability = .checking
    
    /// 是否應該顯示智能輸入界面
    var shouldShowIntelligentInput: Bool {
        if case .available = availability {
            return true
        }
        return false
    }
    
    /// 狀態描述文字
    var statusDescription: String {
        switch availability {
        case .checking:
            return "正在檢查 Apple Intelligence 可用性..."
        case .available:
            return "Apple Intelligence 可用"
        case .unavailable(.deviceNotEligible):
            return "設備不支援 Apple Intelligence"
        case .unavailable(.appleIntelligenceNotEnabled):
            return "請在系統設定中開啟 Apple Intelligence"
        case .unavailable(.modelNotReady):
            return "模型正在準備中，請稍後再試"
        case .unavailable(.systemVersionNotSupported):
            return "需要 iOS 26 或更新版本"
        case .unavailable(.other(let reason)):
            return "Apple Intelligence 暫時不可用：\(reason)"
        }
    }
    
    // MARK: - Private Properties
    
    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private var systemLanguageModel: SystemLanguageModel?
    #endif
    
    // MARK: - Initialization
    
    init() {
        Task {
            await checkAvailability()
        }
    }
    
    // MARK: - Public Methods
    
    /// 檢查可用性
    func checkAvailability() async {
        availability = .checking
        
        // 檢查 iOS 版本
        guard #available(iOS 26.0, *) else {
            availability = .unavailable(.systemVersionNotSupported)
            return
        }
        
        #if canImport(FoundationModels)
        await checkSystemLanguageModelAvailability()
        #else
        // Foundation Models 框架不可用
        availability = .unavailable(.systemVersionNotSupported)
        #endif
    }
    
    /// 重新檢查可用性
    func recheckAvailability() async {
        await checkAvailability()
    }
    
    // MARK: - Private Methods
    
    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    private func checkSystemLanguageModelAvailability() async {
        do {
            // 創建 SystemLanguageModel 實例
            let model = SystemLanguageModel.default
            systemLanguageModel = model
            
            // 檢查模型可用性
            switch model.availability {
            case .available:
                availability = .available
                
            case .unavailable(.deviceNotEligible):
                availability = .unavailable(.deviceNotEligible)
                
            case .unavailable(.appleIntelligenceNotEnabled):
                availability = .unavailable(.appleIntelligenceNotEnabled)
                
            case .unavailable(.modelNotReady):
                availability = .unavailable(.modelNotReady)
                
            case .unavailable(let other):
                availability = .unavailable(.other(String(describing: other)))
            }
        } catch {
            availability = .unavailable(.other("初始化失敗: \(error.localizedDescription)"))
        }
    }
    #endif
    
    /// 獲取系統語言模型（僅在可用時）
    #if canImport(FoundationModels)
    @available(iOS 26.0, *)
    func getSystemLanguageModel() -> SystemLanguageModel? {
        guard case .available = availability else { return nil }
        return systemLanguageModel
    }
    #endif
}

// MARK: - Supporting Types

/// Apple Intelligence 可用性狀態
enum IntelligenceAvailability: Equatable {
    case checking
    case available
    case unavailable(UnavailabilityReason)
    
    /// 不可用原因
    enum UnavailabilityReason: Equatable {
        case deviceNotEligible
        case appleIntelligenceNotEnabled
        case modelNotReady
        case systemVersionNotSupported
        case other(String)
    }
}

// MARK: - Environment Key

/// SwiftUI Environment Key for IntelligenceAvailabilityManager
struct IntelligenceAvailabilityManagerKey: EnvironmentKey {
    @MainActor
    static let defaultValue = IntelligenceAvailabilityManager()
}

extension EnvironmentValues {
    var intelligenceAvailabilityManager: IntelligenceAvailabilityManager {
        get { self[IntelligenceAvailabilityManagerKey.self] }
        set { self[IntelligenceAvailabilityManagerKey.self] = newValue }
    }
}