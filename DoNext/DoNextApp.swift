//
//  DoNextApp.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI
import SwiftData

/// DoNext 應用程式主入口點
/// 負責設定 SwiftData 模型容器和應用程式的根視圖
@main
struct DoNextApp: App {
    /// 共享的 SwiftData 模型容器
    /// 包含所有資料模型的配置和持久化設定
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            TodoItem.self,
            Category.self,
        ])
        
        // 配置模型容器，啟用持久化存儲
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("無法建立 ModelContainer: \(error)")
        }
    }()
    
    /// 應用程式狀態管理
    @StateObject private var appState = AppState()

    /// 應用程式場景配置
    var body: some Scene {
        WindowGroup {
            // 根據應用程式狀態決定顯示的視圖
            RootView()
                .environmentObject(appState)
        }
        .modelContainer(sharedModelContainer)
    }
}

/// 根視圖
/// 負責應用程式的主要導航流程控制
struct RootView: View {
    @EnvironmentObject var appState: AppState
    
    var body: some View {
        switch appState.currentState {
        case .onboarding:
            LandingPageView()
                .transition(.slide)
        case .login:
            LoginView()
                .transition(.slide)
        case .main:
            HomeView()
                .transition(.slide)
        }
    }
}

/// 應用程式狀態管理器
/// 管理應用程式的全局狀態，包括導航狀態和用戶認證狀態
class AppState: ObservableObject {
    /// 應用程式狀態枚舉
    enum State {
        case onboarding  // 引導頁面
        case login       // 登入頁面
        case main        // 主應用程式
    }
    
    /// 當前應用程式狀態
    @Published var currentState: State = .onboarding
    
    /// 是否已完成引導流程
    @Published var hasCompletedOnboarding: Bool = false
    
    /// 是否已登入
    @Published var isLoggedIn: Bool = false
    
    /// 當前用戶資訊
    @Published var currentUser: AuthResult?
    
    /// 當前驗證策略
    private var authStrategy: AuthenticationStrategy?
    
    /// 初始化應用程式狀態
    init() {
        checkInitialState()
    }
    
    /// 檢查應用程式的初始狀態
    /// 根據用戶的使用歷史決定應該顯示哪個視圖
    private func checkInitialState() {
        // 檢查是否已完成引導流程
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "HasCompletedOnboarding")
        
        if !hasCompletedOnboarding {
            currentState = .onboarding
        } else if !isLoggedIn {
            currentState = .login
        } else {
            currentState = .main
        }
    }
    
    /// 完成引導流程
    func completeOnboarding() {
        hasCompletedOnboarding = true
        UserDefaults.standard.set(true, forKey: "HasCompletedOnboarding")
        currentState = .login
    }
    
    /// 設定驗證策略
    /// - Parameter strategy: 驗證策略實例
    func setAuthStrategy(_ strategy: AuthenticationStrategy) {
        self.authStrategy = strategy
    }
    
    /// 執行登入
    /// - Throws: 登入失敗時拋出錯誤
    func signIn() async throws {
        guard let strategy = authStrategy else {
            throw AuthError.noStrategySet
        }
        
        do {
            let result = try await strategy.signIn()
            await MainActor.run {
                self.currentUser = result
                self.isLoggedIn = true
                self.currentState = .main
            }
        } catch {
            throw error
        }
    }
    
    /// 執行登出
    /// - Throws: 登出失敗時拋出錯誤
    func signOut() async throws {
        guard let strategy = authStrategy else {
            throw AuthError.noStrategySet
        }
        
        do {
            try await strategy.signOut()
            await MainActor.run {
                self.currentUser = nil
                self.isLoggedIn = false
                self.currentState = .login
            }
        } catch {
            throw error
        }
    }
}

/// 驗證錯誤類型
enum AuthError: Error, LocalizedError {
    case noStrategySet
    
    var errorDescription: String? {
        switch self {
        case .noStrategySet:
            return "未設定驗證策略"
        }
    }
}

