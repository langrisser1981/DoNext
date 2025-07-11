//
//  HomeView.swift
//  DoNext
//
//  Created by Lenny Cheng on 2025/7/9.
//

import SwiftUI
import SwiftData

/// 主頁面視圖 (Coordinator 版本)
/// 使用 HomeCoordinator 進行現代化的頁面導航管理
struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppCoordinator.self) var appCoordinator
    @Environment(CloudKitManager.self) var cloudKitManager
    @Environment(NotificationManager.self) var notificationManager
    
    private var homeCoordinator: HomeCoordinator? {
        appCoordinator.children.first { $0 is HomeCoordinator } as? HomeCoordinator
    }
    
    @Query private var categories: [Category]
    @Query private var allTodos: [TodoItem]
    
    @State private var selectedCategoryIndex = 0
    @State private var searchText = ""
    
    // Action Bar 狀態
    @State private var showActionBar = false
    @State private var actionBarCategory: Category?
    
    /// 總類別數量（包含"全部"類別）
    private var totalCategoryCount: Int {
        return categories.count + 1 // +1 for "全部" category
    }
    
    /// 當前選中的分類
    private var selectedCategory: Category? {
        guard selectedCategoryIndex > 0 && selectedCategoryIndex <= categories.count else {
            return nil
        }
        return categories[selectedCategoryIndex - 1]
    }
    
    /// 根據選中分類和搜索條件過濾的待辦事項
    private var filteredTodos: [TodoItem] {
        var todos = selectedCategory?.todos ?? allTodos
        
        if !searchText.isEmpty {
            todos = todos.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
        }
        
        return todos.sorted { $0.createdAt > $1.createdAt }
    }
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 0) {
                HomeSearchBar(searchText: $searchText)
                
                HomeCategoryTabs(
                    categories: categories,
                    selectedIndex: $selectedCategoryIndex,
                    allTodosCount: allTodos.count,
                    onCategorySelected: handleCategorySelection,
                    onAddCategory: { homeCoordinator?.showCategoryCreation() },
                    onCategoryLongPress: { showActionBarForCategory($0) }
                )
                
                HomeTodoListContainer(
                    todos: filteredTodos,
                    onTodoToggle: toggleTodoCompletion,
                    onTodoTap: { homeCoordinator?.showTodoDetail($0) },
                    onTodoDelete: { homeCoordinator?.showDeleteConfirmation(for: $0) }
                )
            }
            .simultaneousGesture(
                // 整個畫面的邊緣滑動手勢
                DragGesture()
                    .onEnded { gesture in
                        let horizontalDistance = abs(gesture.translation.width)
                        let verticalDistance = abs(gesture.translation.height)
                        let startLocation = gesture.startLocation
                        
                        // 使用實際的螢幕寬度
                        let screenWidth = geometry.size.width
                        let edgeThreshold: CGFloat = 50 // 邊緣區域的寬度
                        
                        // 檢查是否從螢幕邊緣開始滑動
                        let isFromLeftEdge = startLocation.x <= edgeThreshold
                        let isFromRightEdge = startLocation.x >= screenWidth - edgeThreshold
                        let isFromEdge = isFromLeftEdge || isFromRightEdge
                        
                        // 檢查滑動是否有效（相對寬鬆的條件）
                        let isMainlyHorizontal = horizontalDistance > verticalDistance
                        let hasMinimumDistance = horizontalDistance > 30
                        
                        if isFromEdge && isMainlyHorizontal && hasMinimumDistance {
                            handleSwipeGesture(gesture)
                        }
                    }
            )
        }
        .navigationTitle("DoNext")
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            HomeToolbarContent(
                syncStatus: cloudKitManager.effectiveSyncStatus,
                onSyncRefresh: {
                    Task { await cloudKitManager.refreshSyncStatus() }
                },
                onShowSettings: { homeCoordinator?.showSettings() }
            )
        }
        .overlay(
            HomeFloatingAddButton {
                homeCoordinator?.showTodoCreation(selectedCategory: selectedCategory)
            },
            alignment: .bottomTrailing
        )
        .overlay(
            // Action Bar Overlay - 顯示在最上層
            Group {
                if showActionBar, let category = actionBarCategory {
                    ZStack {
                        // 背景遮罩 - 點擊可關閉 Action Bar
                        Color.black.opacity(0.3)
                            .ignoresSafeArea()
                            .onTapGesture {
                                dismissActionBar()
                            }
                        
                        // Action Bar 顯示在螢幕上方
                        VStack {
                            CategoryActionBar(
                                category: category,
                                onEdit: { 
                                    dismissActionBar()
                                    homeCoordinator?.showCategoryEdit($0) 
                                },
                                onDelete: { 
                                    dismissActionBar()
                                    homeCoordinator?.showCategoryDeleteConfirmation(for: $0) 
                                },
                                onDismiss: { dismissActionBar() }
                            )
                            .padding(.top, 120) // 調整距離頂部的位置
                            
                            Spacer()
                        }
                    }
                    .animation(.easeInOut(duration: 0.3), value: showActionBar)
                }
            }
        )
    }
    
    
    /// 處理分類選擇
    private func handleCategorySelection(_ index: Int) {
        withAnimation(.easeInOut(duration: 0.3)) {
            selectedCategoryIndex = index
        }
    }
    
    /// 顯示 Action Bar
    private func showActionBarForCategory(_ category: Category) {
        actionBarCategory = category
        withAnimation(.easeInOut(duration: 0.3)) {
            showActionBar = true
        }
    }
    
    /// 隱藏 Action Bar
    private func dismissActionBar() {
        withAnimation(.easeInOut(duration: 0.3)) {
            showActionBar = false
        }
        // 延遲清除 category 以保持動畫效果
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            actionBarCategory = nil
        }
    }
    
    /// 切換待辦事項完成狀態
    private func toggleTodoCompletion(_ todo: TodoItem) {
        withAnimation(.easeInOut(duration: 0.2)) {
            todo.toggleCompleted()
            
            // 如果完成了待辦事項，移除通知
            if todo.isCompleted {
                Task {
                    await notificationManager.removeNotification(for: todo)
                }
            } else if todo.reminderDate != nil {
                // 如果取消完成且有提醒時間，重新排程通知
                Task {
                    await notificationManager.scheduleNotification(for: todo)
                }
            }
        }
    }
    
    /// 處理滑動手勢
    private func handleSwipeGesture(_ gesture: DragGesture.Value) {
        let minimumSwipeDistance: CGFloat = 50
        let horizontalDistance = gesture.translation.width
        let verticalDistance = abs(gesture.translation.height)
        
        // 確保是水平滑動且距離足夠
        guard abs(horizontalDistance) > minimumSwipeDistance,
              abs(horizontalDistance) > verticalDistance * 2 else {
            return
        }
        
        if horizontalDistance > 0 {
            // 右滑 - 切換到上一個類別
            switchToPreviousCategory()
        } else {
            // 左滑 - 切換到下一個類別
            switchToNextCategory()
        }
    }
    
    /// 切換到上一個類別
    private func switchToPreviousCategory() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if selectedCategoryIndex > 0 {
                selectedCategoryIndex -= 1
            } else {
                // 如果在第一個類別，切換到最後一個
                selectedCategoryIndex = totalCategoryCount - 1
            }
        }
    }
    
    /// 切換到下一個類別
    private func switchToNextCategory() {
        withAnimation(.easeInOut(duration: 0.3)) {
            if selectedCategoryIndex < totalCategoryCount - 1 {
                selectedCategoryIndex += 1
            } else {
                // 如果在最後一個類別，切換到第一個
                selectedCategoryIndex = 0
            }
        }
    }
    
}