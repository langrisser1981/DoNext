//
//  NotificationManager.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/10.
//

import Foundation
import UserNotifications
import Observation

/// 推播通知管理器
/// 負責處理所有的本地推播通知，包括請求權限、排程通知、管理通知等
@Observable
@MainActor
final class NotificationManager {
    /// 單例實例
    static let shared = NotificationManager()
    
    /// 通知權限狀態
    var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    /// 通知中心
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        setupNotificationDelegate()
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    /// 設定通知代理
    private func setupNotificationDelegate() {
        notificationCenter.delegate = NotificationDelegate.shared
    }
    
    /// 檢查通知權限狀態
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
    
    /// 請求通知權限
    /// - Returns: 是否獲得權限
    @discardableResult
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("請求通知權限失敗：\(error)")
            return false
        }
    }
    
    /// 為待辦事項排程通知
    /// - Parameter todoItem: 待辦事項
    func scheduleNotification(for todoItem: TodoItem) async {
        // 檢查權限
        guard authorizationStatus == .authorized else {
            await requestAuthorization()
            return
        }
        
        // 檢查是否有提醒時間
        guard let reminderDate = todoItem.reminderDate,
              reminderDate > Date() else {
            return
        }
        
        // 先移除舊的通知
        await removeNotification(for: todoItem)
        
        // 創建通知內容
        let content = UNMutableNotificationContent()
        content.title = "📝 待辦提醒"
        content.body = todoItem.title
        content.sound = .default
        content.badge = NSNumber(value: await getPendingNotificationsCount() + 1)
        
        // 如果有分類，加入分類名稱
        if let category = todoItem.category {
            content.subtitle = "分類：\(category.name)"
        }
        
        // 設定用戶資訊（用於點擊通知時的處理）
        content.userInfo = [
            "todoId": todoItem.id.uuidString,
            "todoTitle": todoItem.title
        ]
        
        // 創建觸發器
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: reminderDate
        )
        let trigger = UNCalendarNotificationTrigger(
            dateMatching: dateComponents,
            repeats: shouldRepeat(for: todoItem.repeatType)
        )
        
        // 創建通知請求
        let request = UNNotificationRequest(
            identifier: todoItem.id.uuidString,
            content: content,
            trigger: trigger
        )
        
        // 排程通知
        do {
            try await notificationCenter.add(request)
            print("✅ 已為待辦事項「\(todoItem.title)」排程通知，時間：\(reminderDate)")
        } catch {
            print("❌ 排程通知失敗：\(error)")
        }
        
        // 所有重複通知都由系統自動處理
        if todoItem.repeatType != .none {
            print("📅 已設定重複通知：\(todoItem.repeatType.displayName)")
        }
    }
    
    /// 移除待辦事項的通知
    /// - Parameter todoItem: 待辦事項
    func removeNotification(for todoItem: TodoItem) async {
        let identifiers = [todoItem.id.uuidString]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
        notificationCenter.removeDeliveredNotifications(withIdentifiers: identifiers)
        print("🗑️ 已移除待辦事項「\(todoItem.title)」的通知")
    }
    
    /// 移除所有通知
    func removeAllNotifications() async {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        print("🗑️ 已移除所有通知")
    }
    
    /// 獲取待處理通知數量
    /// - Returns: 通知數量
    private func getPendingNotificationsCount() async -> Int {
        let requests = await notificationCenter.pendingNotificationRequests()
        return requests.count
    }
    
    /// 判斷是否應該重複
    /// - Parameter repeatType: 重複類型
    /// - Returns: 是否重複
    private func shouldRepeat(for repeatType: RepeatType) -> Bool {
        switch repeatType {
        case .none:
            return false
        case .daily, .weekly, .monthly, .yearly:
            return true
        }
    }
    
    /// 排程下次重複通知（用於特殊重複邏輯）
    /// - Parameter todoItem: 待辦事項
    private func scheduleNextRepeatingNotification(for todoItem: TodoItem) async {
        // 目前所有重複類型都由系統處理，暫時不需要手動排程
        print("📅 重複通知由系統自動處理：\(todoItem.repeatType.displayName)")
    }
    
    /// 獲取所有待處理的通知
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
    
    /// 獲取所有已送達的通知
    func getDeliveredNotifications() async -> [UNNotification] {
        return await notificationCenter.deliveredNotifications()
    }
}

/// 通知代理類
/// 處理應用在前台時的通知顯示和用戶點擊通知的回應
class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()
    
    private override init() {
        super.init()
    }
    
    /// 應用在前台時收到通知的處理
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // 即使應用在前台也顯示通知（使用新的 API）
        completionHandler([.banner, .sound, .badge])
    }
    
    /// 用戶點擊通知的處理
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        
        if let todoIdString = userInfo["todoId"] as? String,
           let todoId = UUID(uuidString: todoIdString) {
            
            // 這裡可以導航到具體的待辦事項
            print("📱 用戶點擊了待辦事項通知：\(todoId)")
            
            // TODO: 實作導航邏輯
            // 可以發送通知給 AppCoordinator 來處理導航
            NotificationCenter.default.post(
                name: .todoNotificationTapped,
                object: nil,
                userInfo: ["todoId": todoId]
            )
        }
        
        completionHandler()
    }
}

// MARK: - 通知名稱擴展
extension Notification.Name {
    static let todoNotificationTapped = Notification.Name("todoNotificationTapped")
}