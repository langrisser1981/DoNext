//
//  AlertBuilder.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/14.
//

import SwiftUI

/// Alert 建立器，使用標準 Builder Pattern 創建 Alert
/// 專注於 UI 創建，業務邏輯由呼叫方負責
@MainActor
final class AlertBuilder {
    
    // MARK: - Properties
    
    private var alertTitle: String = ""
    private var alertMessage: String = ""
    private var primaryButtonText: String = "確定"
    private var primaryButtonStyle: ButtonStyle = .default
    private var primaryButtonAction: (() -> Void)?
    private var secondaryButtonText: String?
    private var secondaryButtonAction: (() -> Void)?
    private var dismissButtonText: String?
    private var dismissButtonAction: (() -> Void)?
    
    // MARK: - Button Styles
    
    enum ButtonStyle {
        case `default`
        case cancel
        case destructive
    }
    
    // MARK: - Initializer
    
    init() {}
    
    // MARK: - Builder Methods
    
    /// 設定 Alert 標題
    /// - Parameter title: 標題文字
    /// - Returns: AlertBuilder 實例
    func title(_ title: String) -> AlertBuilder {
        self.alertTitle = title
        return self
    }
    
    /// 設定 Alert 訊息
    /// - Parameter message: 訊息內容
    /// - Returns: AlertBuilder 實例
    func message(_ message: String) -> AlertBuilder {
        self.alertMessage = message
        return self
    }
    
    /// 設定主要按鈕
    /// - Parameters:
    ///   - text: 按鈕文字
    ///   - style: 按鈕樣式
    ///   - action: 點擊時的動作
    /// - Returns: AlertBuilder 實例
    func primaryButton(
        _ text: String,
        style: ButtonStyle = .default,
        action: @escaping () -> Void
    ) -> AlertBuilder {
        self.primaryButtonText = text
        self.primaryButtonStyle = style
        self.primaryButtonAction = action
        return self
    }
    
    /// 設定次要按鈕（用於雙按鈕 Alert）
    /// - Parameters:
    ///   - text: 按鈕文字
    ///   - action: 點擊時的動作（可選）
    /// - Returns: AlertBuilder 實例
    func secondaryButton(
        _ text: String,
        action: (() -> Void)? = nil
    ) -> AlertBuilder {
        self.secondaryButtonText = text
        self.secondaryButtonAction = action
        return self
    }
    
    /// 設定關閉按鈕（用於單按鈕 Alert）
    /// - Parameters:
    ///   - text: 按鈕文字
    ///   - action: 點擊時的動作（可選）
    /// - Returns: AlertBuilder 實例
    func dismissButton(
        _ text: String = "確定",
        action: (() -> Void)? = nil
    ) -> AlertBuilder {
        self.dismissButtonText = text
        self.dismissButtonAction = action
        return self
    }
    
    // MARK: - Build Method
    
    /// 建立 Alert
    /// - Returns: SwiftUI Alert
    func build() -> Alert {
        let titleText = Text(alertTitle)
        let messageText = alertMessage.isEmpty ? nil : Text(alertMessage)
        
        // 如果有設定次要按鈕，創建雙按鈕 Alert
        if let secondaryText = secondaryButtonText {
            let primaryButton = createAlertButton(
                text: primaryButtonText,
                style: primaryButtonStyle,
                action: primaryButtonAction
            )
            
            let secondaryButton = Alert.Button.cancel(
                Text(secondaryText),
                action: secondaryButtonAction
            )
            
            return Alert(
                title: titleText,
                message: messageText,
                primaryButton: primaryButton,
                secondaryButton: secondaryButton
            )
        }
        
        // 創建單按鈕 Alert
        let buttonText = dismissButtonText ?? primaryButtonText
        let buttonAction = dismissButtonAction ?? primaryButtonAction
        
        let dismissButton = Alert.Button.default(
            Text(buttonText),
            action: buttonAction
        )
        
        return Alert(
            title: titleText,
            message: messageText,
            dismissButton: dismissButton
        )
    }
    
    // MARK: - Private Methods
    
    private func createAlertButton(
        text: String,
        style: ButtonStyle,
        action: (() -> Void)?
    ) -> Alert.Button {
        switch style {
        case .default:
            return .default(Text(text), action: action)
        case .cancel:
            return .cancel(Text(text), action: action)
        case .destructive:
            return .destructive(Text(text), action: action)
        }
    }
}

// MARK: - Convenience Extensions

extension AlertBuilder {
    
    /// 創建錯誤 Alert
    /// - Parameters:
    ///   - message: 錯誤訊息
    ///   - onDismiss: 關閉時的回調
    /// - Returns: AlertBuilder 實例
    static func error(
        _ message: String,
        onDismiss: (() -> Void)? = nil
    ) -> AlertBuilder {
        return AlertBuilder()
            .title("錯誤")
            .message(message)
            .dismissButton("確定", action: onDismiss)
    }
    
    /// 創建成功 Alert
    /// - Parameters:
    ///   - message: 成功訊息
    ///   - onDismiss: 關閉時的回調
    /// - Returns: AlertBuilder 實例
    static func success(
        _ message: String,
        onDismiss: (() -> Void)? = nil
    ) -> AlertBuilder {
        return AlertBuilder()
            .title("成功")
            .message(message)
            .dismissButton("確定", action: onDismiss)
    }
    
    /// 創建確認 Alert
    /// - Parameters:
    ///   - title: 標題
    ///   - message: 訊息
    ///   - confirmText: 確認按鈕文字
    ///   - isDestructive: 是否為危險操作
    ///   - onConfirm: 確認時的回調
    ///   - onCancel: 取消時的回調
    /// - Returns: AlertBuilder 實例
    static func confirmation(
        title: String,
        message: String,
        confirmText: String,
        isDestructive: Bool = false,
        onConfirm: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) -> AlertBuilder {
        let style: ButtonStyle = isDestructive ? .destructive : .default
        
        return AlertBuilder()
            .title(title)
            .message(message)
            .primaryButton(confirmText, style: style, action: onConfirm)
            .secondaryButton("取消", action: onCancel)
    }
    
    /// 創建資訊 Alert
    /// - Parameters:
    ///   - title: 標題
    ///   - message: 訊息
    ///   - buttonText: 按鈕文字
    ///   - onDismiss: 關閉時的回調
    /// - Returns: AlertBuilder 實例
    static func info(
        title: String,
        message: String,
        buttonText: String = "確定",
        onDismiss: (() -> Void)? = nil
    ) -> AlertBuilder {
        return AlertBuilder()
            .title(title)
            .message(message)
            .dismissButton(buttonText, action: onDismiss)
    }
    
    /// 創建網路錯誤 Alert
    /// - Parameters:
    ///   - operation: 操作名稱
    ///   - onRetry: 重試回調
    ///   - onCancel: 取消回調
    /// - Returns: AlertBuilder 實例
    static func networkError(
        operation: String,
        onRetry: @escaping () -> Void,
        onCancel: (() -> Void)? = nil
    ) -> AlertBuilder {
        return AlertBuilder()
            .title("網路錯誤")
            .message("\(operation)失敗，請檢查網路連線。")
            .primaryButton("重試", action: onRetry)
            .secondaryButton("取消", action: onCancel)
    }
}