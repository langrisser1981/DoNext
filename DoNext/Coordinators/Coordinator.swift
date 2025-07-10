//
//  Coordinator.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI
import Observation

/// 導航座標器協議
/// 定義所有座標器必須實現的基本功能
protocol Coordinator: AnyObject, Observable {
    /// 座標器的唯一識別符
    var id: UUID { get }
    
    /// 父座標器（如果有的話）
    var parent: (any Coordinator)? { get set }
    
    /// 子座標器集合
    var children: [any Coordinator] { get set }
    
    /// 座標器的導航路徑
    var navigationPath: NavigationPath { get set }
    
    /// 啟動座標器
    func start()
    
    /// 結束座標器
    func finish()
    
    /// 添加子座標器
    nonisolated func addChild(_ coordinator: any Coordinator)
    
    /// 移除子座標器
    nonisolated func removeChild(_ coordinator: any Coordinator)
    
    /// 移除所有子座標器
    nonisolated func removeAllChildren()
}

/// 座標器基類
/// 提供座標器的基本實現
@Observable
@MainActor
class BaseCoordinator: Coordinator {
    let id = UUID()
    weak var parent: (any Coordinator)?
    var children: [any Coordinator] = []
    var navigationPath = NavigationPath()
    
    init() {}
    
    func start() {
        // 子類應該重寫此方法
    }
    
    func finish() {
        parent?.removeChild(self)
        removeAllChildren()
    }
    
    nonisolated func addChild(_ coordinator: any Coordinator) {
        Task { @MainActor in
            coordinator.parent = self
            children.append(coordinator)
        }
    }
    
    nonisolated func removeChild(_ coordinator: any Coordinator) {
        Task { @MainActor in
            children.removeAll { $0.id == coordinator.id }
        }
    }
    
    nonisolated func removeAllChildren() {
        Task { @MainActor in
            children.removeAll()
        }
    }
    
    /// 推送到新的導航目標
    func push<T: Hashable>(_ destination: T) {
        navigationPath.append(destination)
    }
    
    /// 返回上一頁
    func pop() {
        guard !navigationPath.isEmpty else { return }
        navigationPath.removeLast()
    }
    
    /// 返回到根頁面
    func popToRoot() {
        navigationPath = NavigationPath()
    }
    
    /// 替換當前頁面
    func replace<T: Hashable>(with destination: T) {
        if !navigationPath.isEmpty {
            navigationPath.removeLast()
        }
        navigationPath.append(destination)
    }
}

/// 應用程式座標器協議
/// 定義應用程式級別的座標器功能
protocol AppCoordinatorProtocol: Coordinator {
    /// 應用程式狀態
    var appState: CoordinatorAppState { get }
    
    /// 顯示引導頁面
    func showOnboarding()
    
    /// 顯示登入頁面
    func showLogin()
    
    /// 顯示主頁面
    func showHome()
    
    /// 處理登入完成
    func handleLoginCompleted()
    
    /// 處理登出
    func handleLogout()
}

/// 應用程式狀態（Coordinator 專用）
enum CoordinatorAppState {
    case onboarding
    case login
    case authenticated
}