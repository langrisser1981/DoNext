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
    /// 共享的 SwiftData 模型容器
    /// 包含所有資料模型的配置和持久化設定，支援 iCloud 同步
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TodoItem.self,
            Category.self,
        ])
        
        // 配置模型容器，啟用 CloudKit 同步
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("無法建立 ModelContainer: \(error)")
        }
    }()
    
    /// 應用程式座標器
    @State private var appCoordinator = AppCoordinator()
    
    /// CloudKit 同步管理器
    @State private var cloudKitManager = CloudKitManager.shared

    /// 應用程式場景配置
    var body: some Scene {
        WindowGroup {
            AppCoordinatorView()
                .environment(appCoordinator)
                .environment(cloudKitManager)
                .modelContainer(sharedModelContainer)
                .onAppear {
                    appCoordinator.start()
                }
        }
    }
}

/// 應用程式座標器視圖
/// 管理應用程式的主要導航流程
struct AppCoordinatorView: View {
    @Environment(AppCoordinator.self) var appCoordinator
    
    var body: some View {
        NavigationStack(path: binding(for: appCoordinator.appState)) {
            rootView
                .navigationDestination(for: HomeDestination.self) { destination in
                    destinationView(for: destination)
                }
        }
        .sheet(item: Binding(
            get: { appCoordinator.presentedSheet },
            set: { _ in appCoordinator.dismissSheet() }
        )) { sheet in
            sheetView(for: sheet)
        }
        .alert(item: Binding(
            get: { appCoordinator.presentedAlert },
            set: { _ in appCoordinator.dismissAlert() }
        )) { alert in
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
        case .categoryCreation:
            CategoryCreationSheet()
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
            return Alert(
                title: Text("確認登出"),
                message: Text("您確定要登出嗎？"),
                primaryButton: .destructive(Text("登出")) {
                    Task {
                        try? await appCoordinator.signOut()
                    }
                },
                secondaryButton: .cancel()
            )
        case .deleteConfirmation(let item):
            return Alert(
                title: Text("確認刪除"),
                message: Text("您確定要刪除「\(item.title)」嗎？"),
                primaryButton: .destructive(Text("刪除")) {
                    // TODO: 實作刪除邏輯
                },
                secondaryButton: .cancel()
            )
        case .error(let message):
            return Alert(
                title: Text("錯誤"),
                message: Text(message),
                dismissButton: .default(Text("確定"))
            )
        }
    }
    
    /// 為不同的應用程式狀態創建導航綁定
    private func binding(for appState: CoordinatorAppState) -> Binding<NavigationPath> {
        if let homeCoordinator = appCoordinator.children.first(where: { $0 is HomeCoordinator }) as? HomeCoordinator {
            return Binding(
                get: { homeCoordinator.navigationPath },
                set: { homeCoordinator.navigationPath = $0 }
            )
        }
        return .constant(NavigationPath())
    }
}

