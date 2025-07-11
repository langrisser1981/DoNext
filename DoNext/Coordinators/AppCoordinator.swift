//
//  AppCoordinator.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import Observation
import SwiftUI

/// 應用程式主座標器
/// 管理整個應用程式的導航流程和狀態
@Observable
@MainActor
final class AppCoordinator: BaseCoordinator, AppCoordinatorProtocol {
    var appState: CoordinatorAppState = .onboarding
    var presentedSheet: SheetDestination?
    var presentedAlert: AlertDestination?
    
    /// 當前用戶資訊
    var currentUser: AuthResult?
    
    /// 是否已登入
    var isLoggedIn: Bool = false
    
    /// 當前驗證策略
    private var authStrategy: AuthenticationStrategy?
    
    /// 主頁面座標器
    private var homeCoordinator: HomeCoordinator?
    
    override init() {
        super.init()
        checkInitialState()
    }
    
    override func start() {
        checkInitialState()
    }
    
    /// 檢查應用程式的初始狀態
    private func checkInitialState() {
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "HasCompletedOnboarding")
        
        if !hasCompletedOnboarding {
            showOnboarding()
        } else if !isLoggedIn {
            showLogin()
        } else {
            showHome()
        }
    }
    
    // MARK: - Navigation Methods
    
    func showOnboarding() {
        appState = .onboarding
        popToRoot()
    }
    
    func showLogin() {
        appState = .login
        popToRoot()
    }
    
    func showHome() {
        appState = .authenticated
        popToRoot()
        
        // 創建並啟動主頁面座標器
        let coordinator = HomeCoordinator()
        coordinator.appCoordinator = self
        homeCoordinator = coordinator
        addChild(coordinator)
        coordinator.start()
    }
    
    func handleLoginCompleted() {
        isLoggedIn = true
        showHome()
    }
    
    func handleLogout() {
        isLoggedIn = false
        currentUser = nil
        
        // 清理主頁面座標器
        if let homeCoordinator = homeCoordinator {
            removeChild(homeCoordinator)
            self.homeCoordinator = nil
        }
        
        showLogin()
    }
    
    // MARK: - Sheet and Alert Management
    
    func presentSheet(_ sheet: SheetDestination) {
        presentedSheet = sheet
    }
    
    func dismissSheet() {
        presentedSheet = nil
    }
    
    func presentAlert(_ alert: AlertDestination) {
        presentedAlert = alert
    }
    
    func dismissAlert() {
        presentedAlert = nil
    }
    
    // MARK: - Authentication Methods
    
    /// 完成引導流程
    func completeOnboarding() {
        UserDefaults.standard.set(true, forKey: "HasCompletedOnboarding")
        showLogin()
    }
    
    /// 設定驗證策略
    func setAuthStrategy(_ strategy: AuthenticationStrategy) {
        authStrategy = strategy
    }
    
    /// 執行登入
    func signIn() async throws {
        guard let strategy = authStrategy else {
            throw AuthError.noStrategySet
        }
        
        do {
            let result = try await strategy.signIn()
            currentUser = result
            handleLoginCompleted()
        } catch {
            throw error
        }
    }
    
    /// 執行登出
    func signOut() async throws {
        guard let strategy = authStrategy else {
            throw AuthError.noStrategySet
        }
        
        do {
            try await strategy.signOut()
            handleLogout()
        } catch {
            throw error
        }
    }
}

/// Sheet 目標定義
enum SheetDestination: Identifiable {
    case todoCreation(selectedCategory: Category?)
    case todoEdit(todoItem: TodoItem)
    case categoryCreation
    case categoryEdit(category: Category)
    case todoDetail(todoItem: TodoItem)
    case settings
    
    var id: String {
        switch self {
        case .todoCreation: return "todoCreation"
        case .todoEdit: return "todoEdit"
        case .categoryCreation: return "categoryCreation"
        case .categoryEdit: return "categoryEdit"
        case .todoDetail: return "todoDetail"
        case .settings: return "settings"
        }
    }
}

/// Alert 目標定義
enum AlertDestination: Identifiable {
    case signOutConfirmation
    case deleteConfirmation(item: TodoItem)
    case categoryDeleteConfirmation(category: Category)
    case error(message: String)
    
    var id: String {
        switch self {
        case .signOutConfirmation: return "signOutConfirmation"
        case .deleteConfirmation: return "deleteConfirmation"
        case .categoryDeleteConfirmation: return "categoryDeleteConfirmation"
        case .error: return "error"
        }
    }
}
