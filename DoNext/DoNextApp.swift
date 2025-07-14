//
//  DoNextApp.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI
import SwiftData

/// DoNext 應用程式主入口點
/// 使用 Coordinator Pattern 進行現代化的頁面導航管理
@main
struct DoNextApp: App {
    /// 設定管理器
    private let settingsManager = SettingsManager.shared
    
    /// 創建共享的 SwiftData 模型容器
    /// 包含所有資料模型的配置和持久化設定，根據用戶設定決定是否啟用 iCloud 同步
    private func createModelContainer() -> ModelContainer {
        let schema = Schema([
            TodoItem.self,
            Category.self,
        ])
        
        // 使用 Builder Pattern 根據設定創建 ModelConfiguration
        let modelConfiguration = ModelConfigurationBuilder.fromSettings(
            schema: schema,
            settingsManager: settingsManager
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("無法建立 ModelContainer: \(error)")
        }
    }
    
    /// 應用程式座標器
    @State private var appCoordinator = AppCoordinator()
    
    /// CloudKit 同步管理器
    @State private var cloudKitManager = CloudKitManager.shared
    
    /// 通知管理器
    @State private var notificationManager = NotificationManager.shared

    /// 應用程式場景配置
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environment(appCoordinator)
                .environment(cloudKitManager)
                .environment(settingsManager)
                .environment(notificationManager)
                .modelContainer(createModelContainer())
                .onAppear {
                    appCoordinator.start()
                    // 請求通知權限
                    Task {
                        await notificationManager.requestAuthorization()
                    }
                }
        }
    }
}

/// 應用程式座標器視圖
/// 管理應用程式的主要導航流程
struct AppCoordinatorView: View {
    @Environment(AppCoordinator.self) var appCoordinator
    @Environment(NotificationManager.self) var notificationManager
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        @Bindable var bindableCoordinator = appCoordinator
        
        NavigationStack(path: $bindableCoordinator.navigationPath) {
            rootView
                .navigationDestination(for: HomeDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
        .sheet(item: $bindableCoordinator.presentedSheet) { sheet in
            sheetView(for: sheet)
        }
        .alert(item: $bindableCoordinator.presentedAlert) { alert in
            alertView(for: alert)
        }
    }
    
    /// 根據應用程式狀態返回根視圖
    @ViewBuilder
    private var rootView: some View {
        switch appCoordinator.appState {
        case .onboarding:
            LandingPageView()
        case .login:
            LoginView()
        case .authenticated:
            HomeView()
        }
    }
    
    /// 根據導航目標返回對應的視圖
    @ViewBuilder
    private func destinationView(for destination: HomeDestination) -> some View {
        switch destination {
        case .todoDetail(let todoItem):
            TodoDetailView(todoItem: todoItem)
        case .settings:
            SettingsView()
        }
    }
    
    /// 根據 Sheet 目標返回對應的視圖
    @ViewBuilder
    private func sheetView(for sheet: SheetDestination) -> some View {
        switch sheet {
        case .todoCreation(let selectedCategory):
            TodoCreationSheet(selectedCategory: selectedCategory)
        case .todoEdit(let todoItem):
            TodoEditSheet(todoItem: todoItem)
        case .categoryCreation:
            CategoryCreationSheet()
        case .categoryEdit(let category):
            CategoryEditSheet(category: category)
        case .todoDetail(let todoItem):
            TodoDetailView(todoItem: todoItem)
        case .settings:
            SettingsView()
        }
    }
    
    /// 根據 Alert 目標返回對應的 Alert
    private func alertView(for alert: AlertDestination) -> Alert {
        switch alert {
        case .signOutConfirmation:
            return AlertBuilder
                .confirmation(
                    title: "確認登出",
                    message: "您確定要登出嗎？",
                    confirmText: "登出",
                    isDestructive: true,
                    onConfirm: {
                        Task {
                            try? await appCoordinator.signOut()
                        }
                    }
                )
                .build()
            
        case .deleteConfirmation(let item):
            return AlertBuilder
                .confirmation(
                    title: "確認刪除",
                    message: "您確定要刪除「\(item.title)」嗎？",
                    confirmText: "刪除",
                    isDestructive: true,
                    onConfirm: {
                        handleTodoItemDeletion(item)
                    }
                )
                .build()
            
        case .categoryDeleteConfirmation(let category):
            return AlertBuilder
                .confirmation(
                    title: "確認刪除分類",
                    message: "您確定要刪除「\(category.name)」分類嗎？此分類下的所有待辦事項將會被取消分類。",
                    confirmText: "刪除",
                    isDestructive: true,
                    onConfirm: {
                        deleteCategoryWithCleanup(category)
                    }
                )
                .build()
            
        case .error(let message):
            return AlertBuilder
                .error(message)
                .build()
        }
    }
    
    
    /// 處理待辦事項刪除
    private func handleTodoItemDeletion(_ item: TodoItem) {
        // 先移除通知
        Task {
            await notificationManager.removeNotification(for: item)
        }
        
        // 刪除待辦事項
        modelContext.delete(item)
        modelContext.deleteTodoItem { [weak appCoordinator] error, message in
            appCoordinator?.presentAlert(.error(message: "\(message): \(error.localizedDescription)"))
        }
    }
    
    /// 刪除分類並清理相關待辦事項
    private func deleteCategoryWithCleanup(_ category: Category) {
        // 將該分類下的所有待辦事項的 category 設為 nil
        for todo in category.todos {
            todo.category = nil
        }
        
        // 刪除分類
        modelContext.delete(category)
        modelContext.deleteCategory { [weak appCoordinator] error, message in
            appCoordinator?.presentAlert(.error(message: "\(message): \(error.localizedDescription)"))
        }
    }
}

